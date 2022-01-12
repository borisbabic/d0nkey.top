defmodule Components.MaxNations2022LineupName do
  use Surface.Component
  prop(lineup_name, :string, required: true)
  alias Components.MaxNations2022NationPlayerName, as: NationPlayerName
  def render(assigns) do
    ~F"""
    <span :if={@lineup_name == parse(@lineup_name)}>{@lineup_name}</span>
    <span :if={%{player_name: player_name, country_name: country_name} = parse(@lineup_name)}>
      <NationPlayerName player={player_name} nation={country_name}/>
    </span>
    """
  end

  def parse(name) do
    case Regex.run(~r/{(.*)} (.*)/, name) do
      [_, country_name, player_name] -> %{player_name: player_name, country_name: country_name}
      _ -> name
    end
  end

end
