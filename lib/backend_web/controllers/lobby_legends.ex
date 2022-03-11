defmodule Backend.LobbyLegends do

  defmacro is_lobby_legends(season) do
    quote do
      unquote(season) in [5, "lobby_legends_1", "lobby_legends_2"]
    end
  end

end
