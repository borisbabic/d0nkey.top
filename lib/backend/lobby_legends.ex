defmodule Backend.LobbyLegends do
  @moduledoc false
  defmacro is_lobby_legends_points(season) do
    quote do
      unquote(season) in [8, 9, 10]
    end
  end

  defmacro is_lobby_legends(season) do
    ll = Enum.map(1..100, &"lobby_legends_#{&1}")
    check = [5, 6, 7 | ll]

    quote do
      unquote(season) in unquote(check)
    end
  end
end
