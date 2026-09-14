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
  alias Components.AggLogSubtitle
  alias Backend.DeckInteractionTracker, as: Tracker

  data(deck, :any)
  data(streamer_decks, :any)
  data(user, :any)
  data(deck_stats_params, :map)
  data(filters, :any)

  def mount(_, session, socket) do
    {:ok, assign_defaults(socket, session) |> put_user_in_context()}
  end

  def handle_params(%{"deck" => deck_parts} = params, session, socket) when is_list(deck_parts) do
    new_deck = deck_parts |> Enum.join("/")

    params
    |> Map.put("deck", new_deck)
    |> handle_params(session, socket)
  end

  def handle_params(%{"deck" => deck_raw} = params, _session, socket) do
    deck =
      case extract_deck(deck_raw) do
        {:ok, deck} -> deck
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

  def extract_deck(deck_id) when is_integer(deck_id) do
    case Hearthstone.deck(deck_id) do
      %{id: _id} = deck -> {:ok, deck}
      _ -> :error
    end
  end

  def extract_deck(deckcode_or_id) when is_binary(deckcode_or_id) do
    case Integer.parse(deckcode_or_id) do
      {deck_id, _} when is_integer(deck_id) ->
        extract_deck(deck_id)

      _ ->
        with {:error, _} <- Hearthstone.create_or_get_deck(deckcode_or_id) do
          Deck.decode(deckcode_or_id)
        end
    end
  end

  def handle_info({:update_params, params}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, params))}
  end

  defp assign_filters(socket, params) do
    filters = ReplayExplorer.filter_relevant(params)

    socket
    |> assign(:filters, filters)
  end

  def render(%{deck: _} = assigns) do
    ~F"""
      <div>
        <.page_header title={"#{Deck.name(@deck)} #{Deck.format_name(@deck)}"}>
          <:nav_links :if={match?(%{id: id} when is_integer(id), @deck)}>
            <span><a href={~p"/deckbuilder?#{deck_builder_query_params(@deck)}"}>Edit</a></span>
            <a href={~p"/stats/explanation"} class="hover:tw-text-sky-400 tw-transition-colors">Stats Explanation</a>
            <span><a href={card_stats_url(@deck)}>Card Stats (Mulligan)</a></span>
            <span><a href={Decklist.deck_link(@deck, true)}>Archetype Stats</a></span>
            <span><a href={~p"/replays?#{add_games_filters(%{"has_replay_url" => true, "player_deck_id" => @deck.id}, @deck_stats_params)}"}>Replays</a> </span>
            <span :if={Deck.archetype(@deck)}><a href={~p"/replays?#{add_games_filters(%{"has_replay_url" => true, "archetype" => Deck.archetype(@deck)}, @deck_stats_params)}"}>Archetype Replays</a> </span>
          </:nav_links>
          <:meta_info>
            <AggLogSubtitle criteria={@filters} />
          </:meta_info>
        </.page_header>
        <FunctionComponents.Ads.below_title />
        <div :if={valid?(@deck)} class="columns is-multiline is-mobile is-narrow is-centered">
          <div class="column is-narrow-mobile">
            <DeckCard after_deck_class={"tw-flex tw-flex-wrap tw-items-center tw-gap-1.5 tw-p-1"}>
              <Decklist deck={@deck} archetype_as_name={true} link_to_archetype={true} />
              <:after_deck>
                <DeckStreamingInfo deck_id={@deck.id}/>
                <a
                  :if={@user}
                  class="tw-inline-flex tw-items-center tw-gap-1 tw-px-2 tw-py-0.5 tw-rounded-md tw-text-[11px] tw-font-semibold tw-bg-emerald-500/15 hover:tw-bg-emerald-500/25 tw-text-emerald-400 tw-border tw-border-emerald-500/30 tw-transition-colors"
                  href={BackendWeb.DeckTrackerLive.url(@deck)}
                >
                  <svg class="tw-w-3 tw-h-3 tw-text-emerald-400 tw-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4" />
                  </svg>
                  <span>Track Games</span>
                </a>
                <a
                  :if={nil != @deck.id}
                  class="tw-inline-flex tw-items-center tw-gap-1 tw-px-2 tw-py-0.5 tw-rounded-md tw-text-[11px] tw-font-semibold tw-bg-indigo-500/15 hover:tw-bg-indigo-500/25 tw-text-indigo-400 tw-border tw-border-indigo-500/30 tw-transition-colors"
                  href={card_stats_url(@deck)}
                >
                  <svg class="tw-w-3 tw-h-3 tw-text-indigo-400 tw-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                  </svg>
                  <span>Card Stats</span>
                </a>
                <DeckAdmin id={"deck_admin_#{@deck.id}"}:if={DeckAdmin.can_admin?(@user)} user={@user} deck={@deck}/>
              </:after_deck>
            </DeckCard>
          </div>
          <div :if={nil != @deck.id} class="column">
            <div class="subtitle is-4 has-text-centered-mobile">Stats</div>
            <OpponentStatsTable id="deck_stats" default_format={@deck.format} target={@deck.id} live_view={__MODULE__} path_params={[to_string(@deck.id)]} params={@deck_stats_params} />
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
        <.page_header :if={!valid?(@deck)} title="Not a valid deck." />
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

  defp deck_builder_query_params(deck) do
    %{
      "code" => Deck.deckcode(deck),
      "format" => deck.format,
      "deck_class" => Deck.class(deck)
    }
  end

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end

  def handle_event("deck_copied", _, socket), do: {:noreply, socket}

  def assign_meta(%{assigns: %{deck: %{id: _id} = deck}} = socket) do
    socket
    |> assign_meta_tags(%{
      description: Deck.deckcode(deck),
      title: "#{Deck.name(deck)} #{Deck.format_name(deck.format)} Deck"
    })
  end

  def assign_meta(socket), do: socket
end
