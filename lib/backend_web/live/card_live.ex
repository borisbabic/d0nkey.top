defmodule BackendWeb.CardLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.Card
  alias Components.CardInfo
  alias Backend.Hearthstone

  data(user, :any)
  data(card_id, :any)
  data(card, :any)

  def mount(_params, session, socket),
    do: {:ok, socket |> assign_defaults(session) |> put_user_in_context() |> assign_meta()}

  def handle_params(%{"card_id" => card_id}, _session, socket) do
    card = Hearthstone.card(card_id)

    {
      :noreply,
      socket
      |> assign(card: card, card_id: card_id)
      |> assign_meta()
    }
  end

  def render(%{card: nil} = assigns) do
    ~F"""
    <div class="title is-3">
      Oops! No card found for {@card_id}, did you tamper with the url? Or copy it partially?
    </div>
    """
  end

  def render(assigns) do
    ~F"""
      <div>
        <div class="title is-2">{@card.name}</div>
        <div class="subtitle is-5">
          <a href={"https://hearthstone.wiki.gg/wiki/#{@card.name}"}>Wiki</a>
          | <a href={"https://hearthstone.blizzard.com/cards/#{@card.id}"}>Official Site</a>
          | <a href={~p"/decks?player_deck_includes[]=#{Hearthstone.canonical_id(@card.id)}"}>Find Decks</a>
          | <a href={~p"/streamer-decks?#{%{include_cards: %{Hearthstone.canonical_id(@card.id) => true}}}"}>Find Streamer Decks</a>
          <span :if={Backend.UserManager.User.can_access?(@user, :kaffy)}>
          | <a href={~p"/admin/kaffy/hearthstone/card/#{@card.id}"}>Kaffy</a>
          </span>
        </div>
        <Card id={"card_#{@card.id}"} card={@card} />
        <FunctionComponents.Ads.below_title/>
        <Card :for={child <- Hearthstone.child_cards(@card)} id={"card_#{child.id}"} card={child} />
        <CardInfo id={"card_info_{@card.id}"} card={@card}/>
      </div>
    """
  end

  def assign_meta(socket = %{assigns: %{card: card = %{name: name}}}) do
    socket
    |> assign_meta_tags(%{
      title: name |> add_card_set(card),
      description: Map.get(card, :flavor_text)
    })
  end

  def assign_meta(socket), do: socket

  defp add_card_set(base, %{card_set: %{name: name}}), do: "#{base} #{name}"
  defp add_card_set(base, _), do: base
end
