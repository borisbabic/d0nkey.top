defmodule BackendWeb.DeckTrackerLive do
  @moduledoc "For self reporting deck stuff"
  use BackendWeb, :surface_live_view
  alias Components.ExpandableDecklist
  alias Components.Form.RankSelect
  alias Components.WinrateTag
  alias Hearthstone.Enums.GameType
  alias Hearthstone.Enums.Format
  alias Hearthstone.DeckTracker
  alias Hearthstone.DeckTracker.GameDto
  alias Backend.Hearthstone.Deck
  alias Backend.Hearthstone

  data(user, :any)
  data(deck, :any)
  data(form_values, :map)
  data(message, :string)
  data(error_message, :string)
  data(wins, :number)
  data(losses, :number)
  data(valid, :boolean)
  data(winrate, :number)

  def mount(_params, session, socket),
    do: {
      :ok,
      socket
      |> assign_defaults(session)
      |> put_user_in_context()
      |> assign(error_message: nil, message: nil, valid: false)
    }

  def handle_params(params = %{"deck" => deck_parts}, session, socket) when is_list(deck_parts) do
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

  defp assign_default_form_values(%{assigns: %{deck: deck}} = socket, additional_values) do
    form_values = Map.merge(additional_values, default_form_values(deck))

    socket
    |> assign(:form_values, form_values)
  end

  defp assign_meta(socket = %{assigns: %{deck: deck = %{id: _id}}}) do
    socket
    |> assign_meta_tags(%{
      description: Deck.deckcode(deck),
      page_title: "Track #{Deck.class_name(deck)}",
      title: "Track #{Deck.class_name(deck)}"
    })
  end

  defp assign_meta(socket), do: socket

  defp assign_stats(socket = %{assigns: assigns}) do
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
  def render(assigns = %{user: %{id: _}}) do
    ~F"""
      <.form for={%{}} as={:game} id="deck_tracker_form" phx-submit="submit" phx-change="validate">
        <br>
        <div class="">
          <div class="columns is-mobile is-multiline is-vcentered is-centered">
              <span class=" is-narrow">{@wins}-{@losses}<WinrateTag winrate={@winrate}/></span>
              <div :if={@message} class=" is-narrow tag is-info">{@message}</div>
              <div :if={@error_message} class=" is-narrow tag is-error">{@error_message}</div>
          </div>
          <div class="columns is-mobile is-vcentered is-centered" style="z-index: 3;">
            <button type="submit" class=" is-narrow button is-success" disabled={!@valid}>Save</button>
            <ExpandableDecklist deck={@deck} id={"deck_tracker_expanded_deck"}/>
          </div>
        </div>
        <br>
        <div class="columns is-mobile is-multiline is-vcentered is-centered has-text-black">
          <div class=" is-narrow">
            <select class="select has-text-black " name="game[result]" id="result">
              <option value="">Result</option>
              <option value="WIN" selected={Map.get(@form_values, "result") == "WIN"}>Win</option>
              <option value="LOSS" selected={Map.get(@form_values, "result") == "LOSS"}>Loss</option>
              <option value="DRAW" selected={Map.get(@form_values, "result") == "DRAW"}>Tie</option>
            </select>
          </div>
          <div class=" is-narrow">
            <select class="select has-text-black " name="game[opponent_class]" id="opponent_class">
              <option :for={{label, value} <- class_options()} value={value} selected={Map.get(@form_values, "opponent_class") == value}>{label}</option>
          </select>
          </div>
          <div class=" is-narrow">
            <select class="select has-text-black " name="game[game_type]" id="game_type">
              <option :for={{label, value} <- game_type_options()} value={value} selected={Map.get(@form_values, "game_type", GameType.ranked()) == value}>{label}</option>
            </select>
          </div>
          <div class=" is-narrow">
            <select class="select has-text-black " name="game[format]" id="format">
              <option :for={{label, value} <- format_options()} value={value} selected={Map.get(@form_values, "format", @deck.format) == value}>{label}</option>
            </select>
          </div>
        </div>
        <div class="columns is-mobile is-vcentered is-centered">
          <label class="label">Optional:</label>
        </div>
        <div class="columns is-mobile is-multiline is-vcentered is-centered has-text-black">
          <select class="select has-text-black " name="game[coin]" id="coin">
            <option value="">On Coin?</option>
            <option value="true" selected={Map.get(@form_values, "coin") == "true"}>Coin</option>
            <option value="false" selected={Map.get(@form_values, "coin") == "false"}>No Coin</option>
          </select>
          <select name="game[turns]" class="select has-text-black " id="turns">
            <option value="">Turns</option>
            <option :for={t <- 1..45} value={t} selected={Map.get(@form_values, "turns") == t}>{t}</option>
          </select>
          <input name="game[opponent_battletag]" value={Map.get(@form_values, "opponent_battletag")} class="input has-text-black  is-small" placeholder="Opponent Battletag" style="width: 200px;" />
          <RankSelect rank_title={"Player Rank"} id="player_rank" rank_field={:player_rank} rank={@form_values["player_rank"]} legend_rank_field={:player_legend_rank} legend_rank={@form_values["player_legend_rank"]} />
          <RankSelect rank_title={"Opponent Rank"} id="opponent_rank" rank_field={:opponent_rank} rank={@form_values["opponent_rank"]} legend_rank_field={:opponent_legend_rank} legend_rank={@form_values["opponent_legend_rank"]} />
        </div>
        <input type="hidden" name="game[game_id]" value={Map.get(@form_values, "game_id")} />
        <input type="hidden" name="game[source]" value="Self Report" />
        <input type="hidden" name="game[source_version]" value="0" />
      </.form>
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

  defp game_type_options() do
    [
      GameType.ranked(),
      GameType.casual(),
      GameType.vs_friend(),
      GameType.arena(),
      GameType.tavernbrawl()
    ]
    |> Enum.map(&{GameType.name(&1), &1})
  end

  defp format_options() do
    Format.all()
    |> Enum.map(fn {val, name} -> {name, val} end)
  end

  defp class_options() do
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

  defp reset_form_values(socket = %{assigns: %{form_values: form_values, deck: deck}}) do
    new_values =
      form_values
      |> Map.take(["player_rank", "player_legend_rank", "opponent_rank", "opponent_legend_rank"])
      |> Map.merge(default_form_values(deck))

    socket |> assign(form_values: new_values, valid: false)
  end

  def get_message(:win),
    do:
      ["Good Job", "Nice Highroll", "Well Played", "ggwp", "GG WP", "ggwp no re"] |> Enum.random()

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
        socket = %{assigns: %{user: user, deck: deck}}
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
    valid =
      case game_raw do
        %{"result" => r, "opponent_class" => c} when byte_size(r) > 0 and byte_size(c) > 0 ->
          true

        _ ->
          false
      end

    {:noreply, assign(socket, valid: valid, form_values: game_raw)}
  end

  def handle_event("deck_copied", _, socket) do
    {:noreply, socket}
  end

  def handle_event("deck_expanded", _, socket) do
    {:noreply, socket}
  end

  @spec url(Deck.t()) :: String.t()
  def url(%{id: id}) when is_integer(id), do: "/deck-tracker/#{id}"
  def url(deck), do: "/deck-tracker/#{Deck.deckcode(deck)}"
end
