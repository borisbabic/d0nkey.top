defmodule BackendWeb.DeveloperStatsController do
  use Phoenix.Controller, formats: [:json]

  alias Backend.Api.Stats

  action_fallback BackendWeb.DeveloperApiFallbackController

  def archetypes(conn, params) do
    with {:ok, payload} <- Stats.archetypes(params) do
      json(conn, %{data: payload})
    end
  end

  def meta(conn, params) do
    with {:ok, payload} <- Stats.meta(params) do
      json(conn, %{data: payload})
    end
  end

  def archetype(conn, %{"archetype" => archetype} = params) do
    with {:ok, payload} <- Stats.archetype(archetype, params) do
      json(conn, %{data: payload})
    end
  end
end
