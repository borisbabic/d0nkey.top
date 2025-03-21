defmodule Components.UpcomingTournaments do
  @moduledoc false
  use BackendWeb, :surface_live_component
  alias Backend.Battlefy
  alias Backend.Tournaments.Tournament
  alias FunctionComponents.TournamentsTable

  prop(title, :string, default: nil)
  prop(hours_ago, :integer, default: 0)
  data(tournaments, :any)
  data(full_tournaments, :any)

  def render(assigns) do
    ~F"""
      <div>
        <div :if={@title} class="title is-4">{@title}</div>
        <TournamentsTable.table :if={tournaments = !@full_tournaments.ok? && @tournaments.ok? && @tournaments.result} tournaments={tournaments} />
        <TournamentsTable.table :if={tournaments = @full_tournaments.ok? && @full_tournaments.result} tournaments={tournaments} />
        <div :if={@tournaments.loading && @full_tournaments.loading}>Loading tournaments...</div>
      </div>
    """
  end

  def update(assigns, socket) do
    hours_ago = assigns.hours_ago

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign_async(:tournaments, fn -> fetch_tournaments(hours_ago) end)
      |> assign_async(:full_tournaments, fn -> fetch_full_tournaments(hours_ago) end)
    }
  end

  def tournaments(%{ok: true, result: result}) when is_list(result) do
    result
  end

  def tournaments(_), do: []

  @spec fetch_tournaments(integer()) :: {:ok, [Backend.Battlefy.Tournament.t()]}
  def fetch_tournaments(hours_ago) do
    battlefy = Battlefy.upcoming_hearthstone_tournaments(hours_ago)
    tournaments = Enum.sort_by(battlefy, &Tournament.start_time/1, {:asc, NaiveDateTime})
    {:ok, %{tournaments: tournaments}}
  end

  @spec fetch_full_tournaments(integer()) :: {:ok, [Backend.Battlefy.Tournament.t()]}
  def fetch_full_tournaments(hours_ago) do
    battlefy =
      Battlefy.upcoming_hearthstone_tournaments(hours_ago)
      |> Enum.map(&Battlefy.get_tournament(&1.id))

    tournaments = Enum.sort_by(battlefy, &Tournament.start_time/1, {:asc, NaiveDateTime})
    {:ok, %{full_tournaments: tournaments}}
  end
end
