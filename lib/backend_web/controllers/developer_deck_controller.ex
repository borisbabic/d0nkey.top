defmodule BackendWeb.DeveloperDeckController do
  use Phoenix.Controller, formats: [:json]

  alias Backend.Api.Decks

  action_fallback BackendWeb.DeveloperApiFallbackController

  def index(conn, params) do
    with {:ok, payload} <- Decks.latest(params) do
      json(conn, %{data: payload})
    end
  end
end
