defmodule Components.DeckListingModal do
  @moduledoc false
  use BackendWeb, :surface_live_component
  alias Components.Modal
  alias Backend.Hearthstone
  alias Backend.Hearthstone.Deck
  alias Backend.Sheets
  alias Surface.Components.Form
  alias Surface.Components.Form.Label
  alias Surface.Components.Form.Field
  alias Surface.Components.Form.Submit
  alias Surface.Components.Form.TextInput
  alias Surface.Components.Form.Select

  prop(user, :any, required: true)
  prop(existing, :any, default: nil)
  prop(deck, :any, default: nil)
  prop(source, :string, default: nil)
  prop(sheet, :map, default: nil)
  prop(button_title, :any, default: nil)
  prop(button_class, :css_class, default: "button")

  data(modal_part_id, :string)

  def mount(socket) do
    {:ok, assign(socket, :modal_part_id, Ecto.UUID.generate())}
  end

  def render(assigns) do
    ~F"""
      <div>
      <Modal
        id={id(@existing, @deck) <> @modal_part_id}
        :if={can_contribute?(@sheet, @user)}
        button_title={button_title(@button_title, @existing)}
        button_class={@button_class}
        title={title(@existing)}>
        <Form for={:listing} submit="submit" opts={id: form_id(@existing, @deck)}>
          <Field name={:deckcode}>
            <Label class="label">Deckcode</Label>
            <TextInput class="input is-small" value={deckcode(@existing, @deck)} opts={disabled: !!@existing}/>
          </Field>
          <Field name={:sheet_id}>
            <Label class="label">Sheet</Label>
            <Select class="select" selected={sheet_id(@existing, @sheet)} options={sheet_options(@user)} opts={disabled: !!@existing}/>
          </Field>
          <Field name={:name}>
            <Label class="label">Name</Label>
            <TextInput class="input is-small" value={name(@existing)}/>
          </Field>
          <Field name={:source}>
            <Label class="label">Source</Label>
            <TextInput class="input is-small" value={source(@existing) || @source}/>
          </Field>
          <Field name={:comment}>
            <Label class="label">Comment</Label>
            <TextInput class="input is-small" value={comment(@existing)}/>
          </Field>
        </Form>
        <:footer>
          <Submit label="Save" class="button is-success" opts={form: form_id(@existing, @deck)}/>
        </:footer>
      </Modal>
      </div>
    """
  end

  defp title(%{name: name}) when is_binary(name), do: name
  defp title(_), do: "Add Deck to sheet"
  defp deckcode(%{deck: deck = %Deck{}}, _), do: Deck.deckcode(deck)
  defp deckcode(_, deck = %Deck{}), do: Deck.deckcode(deck)
  defp deckcode(_, code) when is_binary(code), do: code
  defp deckcode(_, _), do: nil

  defp name(%{name: name}), do: name
  defp name(_), do: nil

  defp source(%{source: source}), do: source
  defp source(_), do: nil

  defp comment(%{comment: comment}), do: comment
  defp comment(_), do: nil

  defp sheet_id(%{sheet_id: sheet_id}, _), do: sheet_id
  defp sheet_id(_, %{id: sheet_id}), do: sheet_id
  defp sheet_id(_, _), do: nil

  defp sheet_options(user) do
    Sheets.contributeable_sheets(user)
    |> Enum.map(&{&1.name, &1.id})
  end

  def form_id(existing, deck), do: "listing_form_#{id(existing, deck)}"
  defp id(%{id: id}, _), do: "editing_#{id}"
  defp id(_, %{deckcode: code}), do: "creating_for_#{code}"
  defp id(_, code) when is_binary(code), do: "creating_for_deck_#{code}"
  defp id(_, _), do: "creating_new"

  def handle_event(
        "submit",
        %{"listing" => attrs},
        socket = %{assigns: %{user: user, existing: existing, deck: deck, modal_part_id: id_part}}
      ) do
    if existing do
      Sheets.edit_deck_sheet_listing(existing, attrs, user)
    else
      with {deckcode, rest} <- Map.pop(attrs, "deckcode"),
           {:ok, deck} <- Hearthstone.create_or_get_deck(deckcode),
           {sheet_id, rest} <- Map.pop(rest, "sheet_id"),
           sheet = %{id: _} <- Sheets.get_sheet(sheet_id) do
        Sheets.create_deck_sheet_listing(sheet, deck, user, rest)
      end
    end
    |> Modal.handle_result(socket, id(existing, deck) <> id_part)

    {:noreply, socket}
  end

  defp button_title(nil, %{id: _id}), do: "Edit"
  defp button_title(nil, _), do: "New"
  defp button_title(title, _existing), do: title

  defp can_contribute?(nil, _), do: true
  defp can_contribute?(sheet, user), do: Sheets.can_contribute?(sheet, user)
end
