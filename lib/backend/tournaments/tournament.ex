defprotocol Backend.Tournaments.Tournament do
  @spec id(t) :: String.t()
  def id(tournament)
  @spec name(t) :: String.t()
  def name(tournament)
  @spec link(t) :: String.t()
  def link(tournament)
  @spec start_time(t) :: NaiveDateTime.t()
  def start_time(tournament)
  @spec standings_link(t) :: String.t()
  def standings_link(tournament)
  @spec tags(t) :: [:atom]
  def tags(tournament)
end

defimpl Backend.Tournaments.Tournament, for: Backend.Battlefy.Tournament do
  def id(%{id: id}), do: id
  def name(%{name: name}), do: name
  # def link(%{id: id})
  # def link(%{id: id}), do:
  def tags(tournament) do
    Backend.Battlefy.Tournament.tags(tournament)
  end

  def start_time(%{start_time: start_time}), do: start_time

  def standings_link(tournament) do
    BackendWeb.Router.Helpers.battlefy_path(BackendWeb.Endpoint, :tournament, tournament.id)
  end

  def link(tournament) do
    Backend.Battlefy.create_tournament_link(tournament)
  end
end
