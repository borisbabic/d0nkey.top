defmodule BackendWeb.BattlefyMatchLive do
  @moduledoc false
  use BackendWeb, :surface_live_view

  data(user, :any)
  data(tournament, :map)
  data(match, :map)
  data(top_decks, :list)
  data(bottom_decks, :list)

  alias Backend.Battlefy
  alias Backend.Battlefy.Match
  alias Backend.Battlefy.MatchTeam
  alias Backend.Hearthstone.Deck
  alias Components.CompactLineup
  alias Components.ExpandableDecklist
  import FunctionComponents.Battlefy, only: [match_table: 1]

  def mount(_params, session, socket) do
    {:ok, socket |> assign_defaults(session) |> put_user_in_context()}
  end

  def render(assigns) do
    ~F"""
      <div>
        <.page_header title={title(@match)} link={Battlefy.get_match_url(@tournament, @match)}>
          <:meta_info>
            {subtitle(@match)}
          </:meta_info>
        </.page_header>
        <FunctionComponents.Ads.below_title/>
        <.match_table match={@match} tournament_id={@tournament.id} top_decks={@top_decks} bottom_decks={@bottom_decks} />
      </div>
    """
  end

  def subtitle(%{top: top, bottom: bottom}) do
    if Enum.all?([top, bottom], & &1.banned_at) do
      banned_at =
        if :gt == NaiveDateTime.compare(top.banned_at, bottom.banned_at) do
          top.banned_at
        else
          bottom.banned_at
        end

      "Banned #{Util.from_now(banned_at)}"
    else
      "Banning not done"
    end
  end

  def render_decks(decks, id, fallback \\ "")

  def render_decks([deck], id, _fallback) do
    assigns = %{deck: deck, id: id}

    ~F"""
    <ExpandableDecklist id={@id} deck={@deck}/>
    """
  end

  def render_decks([], _id, fallback), do: fallback

  def render_decks(decks, id, _fallback) do
    assigns = %{decks: decks, id: id}

    ~F"""
    <CompactLineup id={@id} extra_decks={@decks}/>
    """
  end

  def title(assigns) do
    ~H"""
      {@top |> MatchTeam.get_name()} vs {@bottom |> MatchTeam.get_name()}<HeroIcons.external_link size={nil}/>
    """
  end

  def handle_params(%{"match_id" => match_id, "tournament_id" => tournament_id}, _uri, socket) do
    tournament = Battlefy.get_tournament(tournament_id)

    match =
      case Integer.parse(match_id) do
        {match_num, ""} ->
          tournament
          |> Battlefy.get_tournament_matches()
          |> Match.find(match_num)

        _ ->
          Battlefy.get_match!(match_id)
      end

    {top_decks, bottom_decks} = get_decks(tournament, match)

    {:noreply,
     socket
     |> assign(
       match: match,
       tournament: tournament,
       top_decks: top_decks,
       bottom_decks: bottom_decks
     )}
  end

  defp get_decks(%{id: tournament_id}, %{id: match_id}) do
    case Battlefy.get_match_deckstrings(tournament_id, match_id) do
      %{top: top, bottom: bottom} -> {decks(top), decks(bottom)}
      _ -> {[], []}
    end
  end

  defp decks(strings) do
    for s <- strings, {:ok, deck} <- [Deck.decode(s)], do: deck
  end
end
