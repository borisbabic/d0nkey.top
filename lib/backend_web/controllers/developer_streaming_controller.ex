defmodule BackendWeb.DeveloperStreamingController do
  use Phoenix.Controller, formats: [:json]

  alias Backend.Api.Streaming

  action_fallback BackendWeb.DeveloperApiFallbackController

  def streamers(conn, params) do
    with {:ok, payload} <- Streaming.streamers(params) do
      json(conn, %{data: payload})
    end
  end

  def streamer_decks(conn, params) do
    with {:ok, payload} <- Streaming.streamer_decks(params) do
      json(conn, %{data: payload})
    end
  end

  def live_streams(conn, params) do
    with {:ok, payload} <- Streaming.live_streams(params) do
      json(conn, %{data: payload})
    end
  end
end
