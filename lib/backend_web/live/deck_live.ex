defmodule BackendWeb.DeckLive do
  @moduledoc false
  use BackendWeb, :surface_live_view_no_layout
  alias Backend.Hearthstone
  alias Backend.Hearthstone.Deck
  alias Components.DeckStreamingInfo
  alias Components.Decklist
  alias Components.DeckCard
  alias Components.OpponentStatsTable
  alias Components.ReplayExplorer
  alias Components.DeckAdmin
  alias Backend.DeckInteractionTracker, as: Tracker

  data(deck, :any)
  data(streamer_decks, :any)
  data(user, :any)
  data(deck_stats_params, :map)
  data(filters, :any)

  def mount(_, session, socket) do
    {:ok, assign_defaults(socket, session) |> put_user_in_context()}
  end

  def handle_params(params = %{"deck" => deck_parts}, session, socket) when is_list(deck_parts) do
    new_deck = deck_parts |> Enum.join("/")

    params
    |> Map.put("deck", new_deck)
    |> handle_params(session, socket)
  end

  def handle_params(params = %{"deck" => deck_raw}, _session, socket) do
    deck =
      with :error <- Integer.parse(deck_raw),
           {:ok, deck_actual} <- Deck.decode(deck_raw) do
        Hearthstone.deck(deck_actual) || deck_actual
      else
        {deck_id, _} when is_integer(deck_id) -> Hearthstone.deck(deck_id)
        _ -> []
      end

    deck_stats_params = params |> Map.take(OpponentStatsTable.param_keys())

    {
      :noreply,
      socket
      |> assign(deck: deck)
      |> assign_meta()
      |> assign(:deck_stats_params, deck_stats_params)
      |> assign_filters(params)
    }
  end

  def handle_info({:update_params, params}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, params))}
  end

  defp assign_filters(socket, params) do
    filters = ReplayExplorer.filter_relevant(params)

    socket
    |> assign(:filters, filters)
  end

  def render(assigns = %{deck: _}) do
    ~F"""
      <div>
        <div class="title is-2">{Deck.name(@deck)} {Deck.format_name(@deck)}</div>
        <div class="subtitle is-6" :if={match?(%{id: id} when is_integer(id), @deck)}>
          <span><a href={card_stats_url(@deck)}>Card Stats (Mulligan)</a> | </span>
          <span><a href={Decklist.deck_link(@deck, true)}>Archetype Stats</a> | </span>
          <span><a href={~p"/replays?#{add_games_filters(%{"has_replay_url" => true, "player_deck_id" => @deck.id}, @deck_stats_params)}"}>Replays</a> </span>
          <span :if={Deck.archetype(@deck)}> | <a href={~p"/replays?#{add_games_filters(%{"has_replay_url" => true, "archetype" => Deck.archetype(@deck)}, @deck_stats_params)}"}>Archetype Replays</a> </span>
        </div>
        <FunctionComponents.Ads.below_title />
        <div :if={valid?(@deck)} class="columns is-multiline is-mobile is-narrow is-centered">
          <div class="column is-narrow-mobile">
            <DeckCard>
              <Decklist deck={@deck} archetype_as_name={true} link_to_archetype={true} />
              <:after_deck>
                <DeckStreamingInfo deck_id={@deck.id}/>
                <a :if={@user} class="tag column is-link" href={BackendWeb.DeckTrackerLive.url(@deck)}>Track Games</a>
                <a :if={nil != @deck.id} class="tag column is-link" href={card_stats_url(@deck)}>Card Stats</a>
                <DeckAdmin id={"deck_admin_#{@deck.id}"}:if={DeckAdmin.can_admin?(@user)} user={@user} deck={@deck}/>
              </:after_deck>
            </DeckCard>
          </div>
          <div :if={nil != @deck.id} class="column">
            <div class="subtitle is-4 has-text-centered-mobile">Stats</div>
            <OpponentStatsTable id="deck_stats" target={@deck.id} live_view={__MODULE__} path_params={[to_string(@deck.id)]} params={@deck_stats_params} />
          </div>
          <div :if={false and nil != @deck.id} class="column is-narrow-mobile">
            <div class="subtitle is-4 has-text-centered-mobile">Replays</div>
            <ReplayExplorer
              id="deck_replays"
              additional_params={replay_params(@deck)}
              path_params={[to_string(@deck.id)]}
              params={@filters}
              show_deck={false}
              show_opponent={false}
              format_filter={false}
              player_class_filter={false}
              includes_filter={false}
              excludes_filter={false}
              class_stats_modal={false}
              search_filter={false}
              live_view={__MODULE__} />
          </div>
        </div>
        <div :if={!valid?(@deck)} class="title is-2">
          Not a valid deck.
        </div>
      </div>
    """
  end

  def render(assigns) do
    ~F"""
    <h2>Whooops</h2>
    Invalid deck, please go back, queue wild, or try again
    """
  end

  defp card_stats_url(deck) do
    ~p"/card-stats?deck_id=#{deck.id}&format=#{deck.format}"
  end

  defp replay_params(deck) do
    %{"public" => true, "player_deck_id" => deck.id, "has_replay_url" => true}
  end

  defp valid?(%{id: _id}), do: true
  defp valid?(_), do: false

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end

  def handle_event("deck_copied", _, socket), do: {:noreply, socket}

  def assign_meta(socket = %{assigns: %{deck: deck = %{id: _id}}}) do
    socket
    |> assign_meta_tags(%{
      description: Deck.deckcode(deck),
      title: "#{Deck.name(deck)} #{Deck.format_name(deck.format)} Deck"
    })
  end

  def assign_meta(socket), do: socket
end
