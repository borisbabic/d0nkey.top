defmodule Bot.MTMessageHandler do
  @moduledoc false
  import Bot.MessageHandlerUtil
  alias Backend.MastersTour

  def handle_qualifier_standings(msg = %{content: content}) do
    with {num, _} <- content |> get_options(:string) |> Integer.parse(),
         %{id: id} <- MastersTour.get_qualifier(num) do
      Bot.BattlefyMessageHandler.handle_tournament_standings(id, msg)
    else
      _ -> :ignore
    end
  end
end
