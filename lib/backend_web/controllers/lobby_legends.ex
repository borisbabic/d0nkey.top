defmodule Backend.LobbyLegends do

  defmacro is_lobby_legends(season) do
    quote do
      unquote(season) in [5]
    end
  end

end
