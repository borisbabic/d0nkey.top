defmodule Components.TwitchCommandsTable do
  use BackendWeb, :surface_live_component

  alias Backend.TwitchBot

  prop(user, :map, default: nil)
  prop(commands, :list, required: true)
  prop(view_advanced, :boolean, default: true)
  prop(fullwidth, :boolean, default: true)
  prop(striped, :boolean, default: true)

  def render(assigns) do
    ~F"""
    <table class={"table", "is-striped": @striped, "is-fullwidth": @fullwidth}>
      <thead>
        <th>Manage</th>
        <th>Type</th>
        <th>Message</th>
        <th>Sender</th>
        <th>Response</th>
        <th>Enabled</th>
      {#if @view_advanced}
        <th>Random Chance</th>
        <th>Message Regex</th>
        <th>Message Regex Flags</th>
        <th>Sender Regex</th>
        <th>Sender Regex Flags</th>
      {/if}
      </thead>
      <tbody>
        <tr :for={command <- @commands}>
          <td>
            {#if @user && TwitchBot.can_manage?(command, @user)}
            <button class="button" :if={{event, button_title} = enabled_button(command)} phx-value-id={command.id} :on-click={event}>{button_title}</button>
            <button class="button" phx-value-id={command.id} :on-click="delete">Delete</button>
            {/if}
          </td>
          <td>{command.type}</td>
          <td>{command.message}</td>
          <td>{command.sender}</td>
          <td>{command.response}</td>
          <td>{command.enabled}</td>
        {#if @view_advanced}
          <td>{command.random_chance}</td>
          <td>{command.message_regex}</td>
          <td>{command.message_regex_flags}</td>
          <td>{command.sender_regex}</td>
          <td>{command.sender_regex_flags}</td>
        {/if}
        </tr>
      </tbody>
    </table>
    """
  end

  def handle_event("enable", %{"id" => id}, socket = %{assigns: %{user: user}}) do
    new_command = TwitchBot.enable(id, user)
    {:noreply, socket |> assign_commands(new_command)}
  end
  def handle_event("disable", %{"id" => id}, socket = %{assigns: %{user: user}}) do
    new_command = TwitchBot.disable(id, user)
    {:noreply, socket |> assign_commands(new_command)}
  end
  def handle_event("delete", %{"id" => id}, socket = %{assigns: %{user: user, commands: old_commands}}) do
    commands = case TwitchBot.delete(id, user) do
      {:ok, _} -> Enum.filter(old_commands, & to_string(&1.id) != to_string(id))
      {:error, _} -> old_commands
    end
    {:noreply, socket |> assign(commands: commands)}
  end

  defp assign_commands(socket = %{assigns: %{commands: old_commands}}, new_command) do
    new_commands = update_commands(old_commands, new_command)
    socket |> assign(commands: new_commands)
  end

  defp update_commands(old_commands, {:error, _}), do: old_commands
  defp update_commands(old_commands, {:error}), do: old_commands
  defp update_commands(old_commands, :error), do: old_commands
  defp update_commands(old_commands, {:ok, command}), do: update_commands(old_commands, command)
  defp update_commands(old_commands, new_command) do
    old_commands
    |> Enum.map_reduce(false, fn com, upd ->
      if com.id == new_command.id do
        {new_command, true}
      else
        {com, upd}
      end
    end)
    |> case do
      {c, true} -> c
      {c, _} -> [new_command | c]
    end
  end

  defp enabled_button(%{enabled: true}) do
    {"disable", "Disable"}
  end
  defp enabled_button(_) do
    {"enable", "Enable"}
  end
end
