defprotocol Backend.Tournaments.Tournament do
  @spec id(t) :: String.t()
  def id(tournament)
  @spec name(t) :: String.t()
  def name(tournament)
end

defimpl Backend.Tournaments.Tournament, for: Backend.Battlefy.Tournament do
  def id(%{id: id}), do: id
  def name(%{name: name}), do: name
end
