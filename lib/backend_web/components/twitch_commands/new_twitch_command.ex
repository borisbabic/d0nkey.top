defmodule Components.NewTwitchCommand do
  use BackendWeb, :surface_live_component

  alias Components.Dropdown
  alias Surface.Components.Form
  alias Surface.Components.Form.Checkbox
  alias Surface.Components.Form.Label
  alias Surface.Components.Form.Field
  alias Surface.Components.Form.TextInput
  alias Surface.Components.Form.NumberInput
  alias Surface.Components.Form.Submit
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
        <Form for={@changeset} submit="submit">
          <Submit label="Save" class="button is-success" />
          <Field name={:type}>
            <Label class="label">Type</Label>
            <TextInput class="input" disabled/>
          </Field>
          <Field name={:message}>
            <Label class="label">Message</Label>
            <TextInput class="input"/>
          </Field>
          <Field name={:sender}>
            <Label class="label">Sender</Label>
            <TextInput class="input"/>
          </Field>
          <Field name={:response}>
            <Label class="label">Response</Label>
            <TextInput class="input"/>
          </Field>
          <Field name={:random_chance}>
            <Label class="label">Random Chance (% chance it triggers)</Label>
            <NumberInput class="input"/>
          </Field>
          <Field name={:message_regex}>
            <Label class="label">Message Regex</Label>
            <Checkbox />
          </Field>
          <Field name={:message_regex_flags}>
            <Label class="label">Message Regex Flags</Label>
            <TextInput class="input"/>
          </Field>
          <Field name={:sender_regex}>
            <Label class="label">Sender Regex</Label>
            <Checkbox />
          </Field>
          <Field name={:sender_regex_flags}>
            <Label class="label">Sender Regex Flags</Label>
            <TextInput class="input"/>
          </Field>
        </Form>
        {#else}
        <Dropdown title="Pick Template">
          <a class="dropdown-item" :for={{template, name} <- templates()} :on-click={"template"} phx-value-template={template}>
            {name}
          </a>
        </Dropdown>
        {/if}
      </div>
    """
  end

  def response(_, _), do: :bla

  def handle_event("submit", %{"twitch_command" => raw_attrs}, socket = %{assigns: %{user: %{id: id}}}) do
    attrs = Map.put(raw_attrs, "user_id", id)
    TwitchBot.create_twitch_command(attrs)
    {:noreply, socket |> push_redirect(to: "/twitch/bot")}
  end
  def handle_event("template", %{"template" => template_name}, socket) do
    template = get_template(template_name)
    changeset = %TwitchCommand{} |> TwitchCommand.changeset(template)
    {:noreply, socket |> assign(changeset: changeset)}
  end
  defp get_template("leaderboard"), do:
  %{
    type: "custom",
    message: "^!ldb (?<ldb_player>\\w+)",
    message_regex: true,
    message_regex_flags: "u",
    response: "{{ ldb_player }} is on the following leaderboards: {{ leaderboard_status }}"
  }
  defp get_template("ronkapoo"), do: %{type: "custom", response: "RonkaPoo : \"{{ message }}\"", sender: "goofyronak", random_chance: 13}
  defp get_template("streamer_decks"), do: %{type: "custom", response: "You can view all my decks at {{ streamer_decks_url }}", message: "!decks"}
  defp get_template("deck"), do: %{type: "deck", response: "View {{ sender }}'s deck at {{ deck_url }} "}
  defp get_template("replay"), do: %{type: "custom", message: "!replay", response: "My latest replay: {{ latest_replay_url }} "}
  defp get_template(_), do: %{type: "custom", message: "!quote_me", response: "{{ sender }}: \"{{ message }}\""}
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
