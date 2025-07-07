defmodule Components.UpcomingTournaments do
  @moduledoc false
  use BackendWeb, :surface_live_component
  alias Backend.Battlefy
  alias BobsLeague.Api, as: BobsLeague
  alias Backend.Tournaments.Tournament
  alias FunctionComponents.TournamentsTable

  prop(title, :string, default: nil)
  prop(hours_ago, :integer, default: 0)
  prop(user, :any)
  data(user_tournaments, :any)
  data(tournaments, :any)
  data(full_tournaments, :any)

  def render(assigns) do
    ~F"""
      <div>
        <div :if={@title} class="title is-4">{@title}</div>
        <TournamentsTable.table :if={tournaments = !@full_tournaments.ok? && @tournaments.ok? && @tournaments.result} tournaments={tournaments} user_tournaments={if @user_tournaments.ok?, do: @user_tournaments.result, else: []}/>
        <TournamentsTable.table :if={tournaments = @full_tournaments.ok? && @full_tournaments.result} tournaments={tournaments} user_tournaments={if @user_tournaments.ok?, do: @user_tournaments.result, else: []} />
        <div :if={@tournaments.loading && @full_tournaments.loading}>Loading tournaments...</div>
      </div>
    """
  end

  def update(assigns, socket) do
    hours_ago = assigns.hours_ago
    user = assigns.user

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign_async(:tournaments, fn -> fetch_tournaments(hours_ago) end)
      |> assign_async(:full_tournaments, fn -> fetch_full_tournaments(hours_ago) end)
      |> assign_async(:user_tournaments, fn ->
        case user do
          %{battlefy_slug: slug} when is_binary(slug) ->
            t = Backend.Infrastructure.BattlefyCommunicator.get_user_tournaments(slug, 1)

            {:ok, %{user_tournaments: t}}

          _ ->
            {:ok, %{user_tournaments: []}}
        end
      end)
    }
  end

  def tournaments(%{ok: true, result: result}) when is_list(result) do
    result
  end

  def tournaments(_), do: []

  @spec fetch_tournaments(integer()) :: {:ok, [Backend.Battlefy.Tournament.t()]}
  def fetch_tournaments(hours_ago) do
    battlefy = Battlefy.upcoming_hearthstone_tournaments(hours_ago)

    tournaments =
      Enum.sort_by(
        bobsleague(hours_ago) ++ battlefy,
        &Tournament.start_time/1,
        {:asc, NaiveDateTime}
      )

    {:ok, %{tournaments: tournaments}}
  end

  @spec fetch_full_tournaments(integer()) :: {:ok, [Backend.Battlefy.Tournament.t()]}
  def fetch_full_tournaments(hours_ago) do
    battlefy =
      Battlefy.upcoming_hearthstone_tournaments(hours_ago)
      |> Enum.map(&Battlefy.get_tournament(&1.id))

    tournaments =
      Enum.sort_by(
        bobsleague(hours_ago) ++ battlefy,
        &Tournament.start_time/1,
        {:asc, NaiveDateTime}
      )

    {:ok, %{full_tournaments: tournaments}}
  end

  defp bobsleague(hours_ago) do
    case BobsLeague.tournaments() do
      {:ok, b} ->
        Backend.Tournaments.filter_newest(b, hours_ago)

      _ ->
        []
    end
  end
end
