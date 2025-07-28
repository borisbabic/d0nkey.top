defmodule Components.NewTwitchCommand do
  use BackendWeb, :surface_live_component
  @moduledoc false

  alias FunctionComponents.Dropdown
  alias Backend.TwitchBot.TwitchCommand
  alias Backend.TwitchBot

  prop(user, :map, required: true)
  prop(changeset, :map, default: nil)
  prop(test_message, :string, default: nil)
  prop(current_attrs, :string)

  def render(assigns) do
    ~F"""
      <div>
        {#if @changeset}
        <.form for={@changeset} id="twitch_command_form" phx-submit="submit">
          <div class="field">
            <label class="label" for="type">Type</label>
            <input class="input has-text-black" type="text" name="twitch_command[type]" id="type" value={Phoenix.HTML.Form.input_value(@changeset, :type)} disabled />
          </div>
          <div class="field">
            <label class="label" for="message">Message</label>
            <input class="input has-text-black" type="text" name="twitch_command[message]" id="message" value={Phoenix.HTML.Form.input_value(@changeset, :message)} />
          </div>
          <div class="field">
            <label class="label" for="sender">Sender</label>
            <input class="input has-text-black" type="text" name="twitch_command[sender]" id="sender" value={Phoenix.HTML.Form.input_value(@changeset, :sender)} />
          </div>
          <div class="field">
            <label class="label" for="response">Response</label>
            <input class="input has-text-black" type="text" name="twitch_command[response]" id="response" value={Phoenix.HTML.Form.input_value(@changeset, :response)} />
          </div>
          <div class="field">
            <label class="label" for="random_chance">Random Chance (% chance it triggers)</label>
            <input class="input has-text-black" type="number" name="twitch_command[random_chance]" id="random_chance" value={Phoenix.HTML.Form.input_value(@changeset, :random_chance)} />
          </div>
          <div class="field">
            <label class="label" for="message_regex">Message Regex</label>
            <input type="checkbox" name="twitch_command[message_regex]" id="message_regex" value="true" checked={Phoenix.HTML.Form.input_value(@changeset, :message_regex)} />
          </div>
          <div class="field">
            <label class="label" for="message_regex_flags">Message Regex Flags</label>
            <input class="input has-text-black" type="text" name="twitch_command[message_regex_flags]" id="message_regex_flags" value={Phoenix.HTML.Form.input_value(@changeset, :message_regex_flags)} />
          </div>
          <div class="field">
            <label class="label" for="sender_regex">Sender Regex</label>
            <input type="checkbox" name="twitch_command[sender_regex]" id="sender_regex" value="true" checked={Phoenix.HTML.Form.input_value(@changeset, :sender_regex)} />
          </div>
          <div class="field">
            <label class="label" for="sender_regex_flags">Sender Regex Flags</label>
            <input class="input has-text-black" type="text" name="twitch_command[sender_regex_flags]" id="sender_regex_flags" value={Phoenix.HTML.Form.input_value(@changeset, :sender_regex_flags)} />
          </div>
          <button type="submit" class="button is-success">Save</button>
        </.form>
        {#else}
        <Dropdown.menu title="Pick Template">
          <Dropdown.item :for={{template, name} <- templates()} phx-target={@myself} phx-click={"template"} phx-value-template={template}>
            {name}
          </Dropdown.item>
        </Dropdown.menu>
        {/if}
      </div>
    """
  end

  def response(_, _), do: :bla

  def handle_event(
        "submit",
        %{"twitch_command" => raw_attrs},
        socket = %{assigns: %{user: %{id: id}}}
      ) do
    attrs = Map.put(raw_attrs, "user_id", id)
    TwitchBot.create_twitch_command(attrs)
    {:noreply, socket |> push_navigate(to: "/twitch/bot")}
  end

  def handle_event("template", %{"template" => template_name}, socket) do
    template = get_template(template_name)
    changeset = %TwitchCommand{} |> TwitchCommand.changeset(template)
    {:noreply, socket |> assign(changeset: changeset)}
  end

  defp get_template("leaderboard"),
    do: %{
      type: "custom",
      message: "^!ldb (?<ldb_player>\\w+)",
      message_regex: true,
      message_regex_flags: "u",
      response: "{{ ldb_player }} is on the following leaderboards: {{ leaderboard_status }}"
    }

  defp get_template("ronkapoo"),
    do: %{
      type: "custom",
      response: "RonkaPoo : \"{{ message }}\"",
      sender: "goofyronak",
      random_chance: 13
    }

  defp get_template("streamer_decks"),
    do: %{
      type: "custom",
      response: "You can view all my decks at {{ streamer_decks_url }}",
      message: "!decks"
    }

  defp get_template("deck"),
    do: %{type: "deck", response: "View {{ sender }}'s deck at {{ deck_url }} "}

  defp get_template("replay"),
    do: %{
      type: "custom",
      message: "!replay",
      response: "My latest replay: {{ latest_replay_url }} "
    }

  defp get_template(_),
    do: %{type: "custom", message: "!quote_me", response: "{{ sender }}: \"{{ message }}\""}

  defp templates() do
    [
      {
        "custom",
        "Custom"
      },
      {
        "streamer_decks",
        "Streamer Decks"
      },
      {
        "replay",
        "Latest Replay"
      },
      {
        "leaderboard",
        "Leaderboard"
      },
      {
        "ronkapoo",
        "RonkaPoo"
      },
      {
        "deck",
        "Deck Code"
      }
    ]
  end
end
