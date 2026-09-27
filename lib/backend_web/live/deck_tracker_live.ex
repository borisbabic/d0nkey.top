defmodule BackendWeb.DeckTrackerLive do
  @moduledoc """
  Self-report form for tracking games with a deck.

  Designed to be kept open in a small popup or Picture-in-Picture browser window alongside the
  game itself, so the layout stays chromeless (see the `:deck_tracker` `live_session` in the
  router) and the common path (pick a result, pick the opponent's class, hit Save) is reachable
  with big tap targets and no native `<select>` popovers.
  """
  use BackendWeb, :surface_live_view
  alias Components.ExpandableDecklist
  alias Components.Decklist
  alias Components.Form.RankSelect
  alias Components.WinrateTag
  alias FunctionComponents.DeckComponents
  alias Hearthstone.Enums.GameType
  alias Hearthstone.Enums.Format
  alias Hearthstone.DeckTracker
  alias Hearthstone.DeckTracker.GameDto
  alias Backend.Hearthstone.Deck
  alias Backend.Hearthstone
  alias Backend.DeckInteractionTracker, as: Tracker

  data(user, :any)
  data(deck, :any)
  data(form_values, :map)
  data(message, :string)
  data(error_message, :string)
  data(wins, :number)
  data(losses, :number)
  data(valid, :boolean)
  data(winrate, :number)
  data(show_more, :boolean, default: false)

  def mount(_params, session, socket),
    do: {
      :ok,
      socket
      |> assign_defaults(session)
      |> put_user_in_context()
      |> assign(error_message: nil, message: nil, valid: false, show_more: false)
    }

  def handle_params(%{"deck" => deck_parts} = params, session, socket) when is_list(deck_parts) do
    new_deck = deck_parts |> Enum.join("/")

    params
    |> Map.put("deck", new_deck)
    |> handle_params(session, socket)
  end

  def handle_params(%{"deck" => deck_raw}, _session, socket) do
    latest_replay_result = latest_replay(socket)

    deck =
      with :error <- Integer.parse(deck_raw),
           {:ok, deck} <- Deck.decode(deck_raw) do
        Hearthstone.deck(deck) || deck
      else
        {deck_id, _} when is_integer(deck_id) ->
          Hearthstone.deck(deck_id)

        _ ->
          case latest_replay_result do
            {:ok, %{player_deck: deck}} -> deck
            _ -> nil
          end
      end

    {:noreply,
     socket
     |> assign(deck: deck)
     |> assign_default_form_values(additional_values(latest_replay_result))
     |> assign_stats()
     |> assign_meta()}
  end

  defp latest_replay(%{assigns: %{user: %{battletag: battletag}}}) do
    case DeckTracker.games([{"player_btag", battletag}, {"limit", 1}, :latest]) do
      [replay | _] -> {:ok, replay}
      _ -> {:error, :no_previous_replays}
    end
  end

  defp latest_replay(_) do
    {:error, :no_user_battletag}
  end

  defp additional_values({:ok, %{player_rank: rank}}) do
    %{"player_rank" => rank}
    # |> Map.put("region", Map.get(replay, "region"))
  end

  defp additional_values(_) do
    %{}
  end

  defp assign_default_form_values(%{assigns: %{deck: nil}} = socket, _additional_values) do
    socket |> assign(:form_values, %{})
  end

  defp assign_default_form_values(%{assigns: %{deck: deck}} = socket, additional_values) do
    form_values = Map.merge(additional_values, default_form_values(deck))

    socket
    |> assign(:form_values, form_values)
  end

  defp assign_meta(%{assigns: %{deck: %{id: _id} = deck}} = socket) do
    socket
    |> assign_meta_tags(%{
      description: Deck.deckcode(deck),
      page_title: "Track #{Deck.class_name(deck)}",
      title: "Track #{Deck.class_name(deck)}"
    })
  end

  defp assign_meta(socket), do: socket

  defp assign_stats(%{assigns: assigns} = socket) do
    socket
    |> assign(get_stats(assigns))
  end

  defp assign_stats(socket), do: socket

  defp default_form_values(deck),
    do: %{
      "game_type" => GameType.ranked(),
      "format" => deck.format,
      "result" => nil,
      "opponent_class" => nil,
      "game_id" => Ecto.UUID.generate()
    }

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(%{user: %{id: _}, deck: nil} = assigns) do
    ~F"""
      <div class="tw-flex tw-flex-col tw-gap-2 tw-text-sm">
        <div class="tw-text-base tw-font-semibold">No deck found</div>
        <div class="tw-text-slate-400">
          The link is missing a valid deckcode and you don't have a recent tracked game to fall back on.
          Grab a "Track Games" link from a deck page on <a class="tw-underline" href="/">HSGuru</a> and open that instead.
        </div>
      </div>
    """
  end

  def render(%{user: %{id: _}} = assigns) do
    ~F"""
      <div class="tw-flex tw-flex-col tw-gap-3 tw-text-sm">
        <div class="tw-flex tw-items-start tw-justify-between tw-gap-2">
          <div class="tw-flex tw-items-center tw-gap-2 tw-min-w-0">
            <DeckComponents.class_icon class_slug={String.downcase(Deck.class(@deck))} size={32} />
            <div class="tw-flex tw-flex-col tw-min-w-0">
              <a href={Decklist.deck_link(@deck, true)} class="tw-font-bold tw-leading-tight tw-truncate hover:tw-underline">
                {Decklist.deck_name(@deck, nil, true)}
              </a>
              <span class="tw-text-xs tw-text-slate-400">{Deck.format_name(@deck)}</span>
            </div>
          </div>
          <div class="tw-flex tw-items-center tw-gap-1.5 tw-font-semibold tw-whitespace-nowrap tw-pt-1">
            <span>{@wins}-{@losses}</span>
            <WinrateTag winrate={@winrate}/>
          </div>
        </div>

        <div :if={@message} class="tw-rounded-md tw-bg-emerald-500/15 tw-border tw-border-emerald-500/30 tw-text-emerald-300 tw-text-xs tw-px-3 tw-py-1.5">
          {@message}
        </div>
        <div :if={@error_message} class="tw-rounded-md tw-bg-red-500/15 tw-border tw-border-red-500/30 tw-text-red-300 tw-text-xs tw-px-3 tw-py-1.5">
          {@error_message}
        </div>

        <.form for={%{}} as={:game} id="deck_tracker_form" phx-submit="submit" phx-change="validate" class="tw-flex tw-flex-col tw-gap-3">
          <div class="tw-flex tw-flex-wrap tw-gap-3 tw-items-start">
            <div class="tw-flex-1 tw-min-w-[220px]">
              <ExpandableDecklist deck={@deck} id="deck_tracker_expanded_deck"/>
            </div>
            <div class="tw-w-full sm:tw-w-auto sm:tw-min-w-[160px]">
              <div class="tw-text-[11px] tw-uppercase tw-tracking-wide tw-text-slate-400 tw-mb-1">Player Rank</div>
              <RankSelect rank_title={"Player Rank"} id="player_rank" rank_field={:player_rank} rank={@form_values["player_rank"]} legend_rank_field={:player_legend_rank} legend_rank={@form_values["player_legend_rank"]} />
            </div>
          </div>

          <div>
            <div class="tw-text-[11px] tw-uppercase tw-tracking-wide tw-text-slate-400 tw-mb-1">Result</div>
            <div class="tw-grid tw-grid-cols-3 tw-gap-1.5" role="group" aria-label="Game result">
              <button
                :for={{label, value} <- result_options()}
                type="button"
                id={"result_#{value}"}
                phx-click="set_result"
                phx-value-result={value}
                aria-pressed={to_string(Map.get(@form_values, "result") == value)}
                class={result_button_class(value, Map.get(@form_values, "result"))}
              >
                {label}
              </button>
            </div>
          </div>

          <div>
            <div class="tw-text-[11px] tw-uppercase tw-tracking-wide tw-text-slate-400 tw-mb-1">Opponent Class</div>
            <div class="tw-flex tw-flex-wrap tw-gap-1.5" role="group" aria-label="Opponent class">
              <button
                :for={{label, value} <- class_options()}
                type="button"
                id={"opponent_class_#{value}"}
                phx-click="set_opponent_class"
                phx-value-class={value}
                title={label}
                aria-label={label}
                aria-pressed={to_string(Map.get(@form_values, "opponent_class") == value)}
                class={class_button_class(Map.get(@form_values, "opponent_class") == value)}
              >
                <DeckComponents.class_icon class_slug={String.downcase(value)} size={32} css_class="tw-pointer-events-none"/>
              </button>
            </div>
          </div>

          <div class="tw-grid tw-grid-cols-2 tw-gap-1.5">
            <div>
              <label class="tw-block tw-text-[11px] tw-uppercase tw-tracking-wide tw-text-slate-400 tw-mb-1" for="game_type">Game Type</label>
              <select class="select has-text-black tw-w-full" name="game[game_type]" id="game_type">
                <option :for={{label, value} <- game_type_options()} value={value} selected={to_string(Map.get(@form_values, "game_type", GameType.ranked())) == to_string(value)}>{label}</option>
              </select>
            </div>
            <div>
              <label class="tw-block tw-text-[11px] tw-uppercase tw-tracking-wide tw-text-slate-400 tw-mb-1" for="format">Format</label>
              <select class="select has-text-black tw-w-full" name="game[format]" id="format">
                <option :for={{label, value} <- format_options()} value={value} selected={to_string(Map.get(@form_values, "format", @deck.format)) == to_string(value)}>{label}</option>
              </select>
            </div>
          </div>

          <button type="submit" class="button is-success tw-w-full" disabled={!@valid}>Save Game</button>

          <button type="button" phx-click="toggle_more" class="tw-text-xs tw-text-slate-400 hover:tw-text-slate-200 tw-self-start tw-underline tw-underline-offset-2">
            {if @show_more, do: "Hide extra details", else: "Add extra details (coin, turns, opponent name & rank)"}
          </button>

          <div :if={@show_more} class="tw-flex tw-flex-col tw-gap-2 tw-pt-2 tw-border-t tw-border-slate-700/60">
            <div class="tw-grid tw-grid-cols-2 tw-gap-1.5">
              <select class="select has-text-black tw-w-full" name="game[coin]" id="coin" aria-label="On coin?">
                <option value="">On Coin?</option>
                <option value="true" selected={Map.get(@form_values, "coin") == "true"}>Coin</option>
                <option value="false" selected={Map.get(@form_values, "coin") == "false"}>No Coin</option>
              </select>
              <select name="game[turns]" class="select has-text-black tw-w-full" id="turns" aria-label="Turns">
                <option value="">Turns</option>
                <option :for={t <- 1..45} value={t} selected={to_string(Map.get(@form_values, "turns")) == to_string(t)}>{t}</option>
              </select>
            </div>
            <input name="game[opponent_battletag]" value={Map.get(@form_values, "opponent_battletag")} class="input has-text-black tw-w-full" placeholder="Opponent Battletag" aria-label="Opponent Battletag" />
            <RankSelect rank_title={"Opponent Rank"} id="opponent_rank" rank_field={:opponent_rank} rank={@form_values["opponent_rank"]} legend_rank_field={:opponent_legend_rank} legend_rank={@form_values["opponent_legend_rank"]} />
          </div>

          <input type="hidden" name="game[result]" value={Map.get(@form_values, "result")} />
          <input type="hidden" name="game[opponent_class]" value={Map.get(@form_values, "opponent_class")} />
          <input type="hidden" name="game[game_id]" value={Map.get(@form_values, "game_id")} />
          <input type="hidden" name="game[source]" value="Self Report" />
          <input type="hidden" name="game[source_version]" value="0" />
        </.form>
      </div>
    """
  end

  def render(assigns) do
    ~F"""
      <div>
        <div class="title is-3">Please login to Track your decks</div>
      </div>
    """
  end

  def get_stats(%{user: %{battletag: battletag}, deck: %{id: id}}) when is_integer(id) do
    criteria = [{"player_btag", battletag}, {"player_deck_id", id}]

    case DeckTracker.total_stats(criteria) do
      [%{losses: l, winrate: wr, wins: w}] when not is_nil(w) ->
        [wins: w, losses: l, winrate: wr]

      _ ->
        get_stats(nil)
    end
  end

  def get_stats(_), do: [wins: 0, losses: 0, winrate: 0.0]

  defp result_options, do: [{"Win", "WIN"}, {"Loss", "LOSS"}, {"Tie", "DRAW"}]

  defp result_button_class(value, selected) do
    base = "tw-rounded-md tw-py-2.5 tw-text-sm tw-font-semibold tw-transition-colors tw-border"

    if value == selected do
      base <> " " <> result_selected_class(value)
    else
      base <> " tw-bg-slate-800 tw-border-slate-700 tw-text-slate-300 hover:tw-border-slate-500"
    end
  end

  defp result_selected_class("WIN"), do: "tw-bg-emerald-500/20 tw-border-emerald-500 tw-text-emerald-300"
  defp result_selected_class("LOSS"), do: "tw-bg-red-500/20 tw-border-red-500 tw-text-red-300"
  defp result_selected_class(_), do: "tw-bg-slate-500/30 tw-border-slate-400 tw-text-slate-100"

  defp class_button_class(true),
    do: "tw-p-1 tw-rounded-lg tw-ring-2 tw-ring-sky-400 tw-bg-sky-500/10 tw-transition-colors"

  defp class_button_class(false),
    do:
      "tw-p-1 tw-rounded-lg tw-ring-1 tw-ring-slate-700 hover:tw-ring-slate-500 tw-bg-slate-800/60 tw-transition-colors"

  defp game_type_options do
    [
      GameType.ranked(),
      GameType.casual(),
      GameType.vs_friend(),
      GameType.arena(),
      GameType.tavernbrawl()
    ]
    |> Enum.map(&{GameType.name(&1), &1})
  end

  defp format_options do
    Format.all()
    |> Enum.map(fn {val, name} -> {name, val} end)
  end

  defp class_options do
    Deck.classes()
    |> Enum.map(&{Deck.class_name(&1), &1})
  end

  defp add_player(game_map, user, deck) do
    base = %{
      "battletag" => user.battletag,
      "class" => Deck.class(deck),
      "deckcode" => Deck.deckcode(deck)
    }

    player = for {"player_" <> key, val} <- game_map, into: base, do: {key, val}
    Map.put(game_map, "player", player)
  end

  defp add_opponent(game_map) do
    opponent = for {"opponent_" <> key, val} <- game_map, into: %{}, do: {key, val}
    Map.put(game_map, "opponent", opponent)
  end

  defp handle_result(socket, {:ok, %{status: status}}) do
    socket
    |> reset_form_values()
    |> set_message(status)
    |> assign_stats()
  end

  defp handle_result(socket, {:error, error}) do
    socket
    |> assign(:message, nil)
    |> assign(:error_message, error)
  end

  defp handle_result(socket, _) do
    socket
    |> assign(:message, nil)
    |> assign(:error_message, "Unknown error, prolly :shrug:")
  end

  defp set_message(socket, status) do
    message = get_message(status)

    socket
    |> assign(:error_message, nil)
    |> assign(:message, message)
  end

  defp reset_form_values(%{assigns: %{form_values: form_values, deck: deck}} = socket) do
    new_values =
      form_values
      |> Map.take(["player_rank", "player_legend_rank", "opponent_rank", "opponent_legend_rank"])
      |> Map.merge(default_form_values(deck))

    socket |> assign(form_values: new_values, valid: false)
  end

  def get_message(:win),
    do: ["Good Job", "Nice Highroll", "Well Played", "ggwp", "GG WP", "ggwp no re"] |> Enum.random()

  def get_message(:loss),
    do:
      ["Tough luck", "Better luck next time", "Next Ones The charm", "Time for a break?"]
      |> Enum.random()

  def get_message(:draw),
    do: ["A draw?!?!", "Woaah Legend-draw", "Legen-waitforit-DRAW?!?!?!"] |> Enum.random()

  def get_message(_), do: ["Weird Game", "What Happened?!?", "WTF?!"] |> Enum.random()

  def handle_event(
        "submit",
        %{"game" => game_raw},
        %{assigns: %{user: user, deck: deck}} = socket
      ) do
    game_map =
      game_raw
      |> add_player(user, deck)
      |> add_opponent()

    dto = GameDto.from_raw_map(game_map, nil)

    result = DeckTracker.handle_game(dto)
    {:noreply, socket |> handle_result(result)}
  end

  def handle_event("validate", %{"game" => game_raw}, socket) do
    {:noreply, assign(socket, valid: valid_form?(game_raw), form_values: game_raw)}
  end

  def handle_event("set_result", %{"result" => value}, %{assigns: %{form_values: form_values}} = socket) do
    new_values = Map.put(form_values, "result", value)
    {:noreply, assign(socket, form_values: new_values, valid: valid_form?(new_values))}
  end

  def handle_event(
        "set_opponent_class",
        %{"class" => class},
        %{assigns: %{form_values: form_values}} = socket
      ) do
    new_values = Map.put(form_values, "opponent_class", class)
    {:noreply, assign(socket, form_values: new_values, valid: valid_form?(new_values))}
  end

  def handle_event("toggle_more", _, %{assigns: %{show_more: show_more}} = socket) do
    {:noreply, assign(socket, show_more: !show_more)}
  end

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end

  def handle_event("deck_expanded", _, socket) do
    {:noreply, socket}
  end

  defp valid_form?(%{"result" => r, "opponent_class" => c}) when is_binary(r) and is_binary(c),
    do: byte_size(r) > 0 and byte_size(c) > 0

  defp valid_form?(_), do: false

  @spec url(Deck.t()) :: String.t()
  def url(%{id: id}) when is_integer(id), do: "/deck-tracker/#{id}"
  def url(deck), do: "/deck-tracker/#{Deck.deckcode(deck)}"
end
