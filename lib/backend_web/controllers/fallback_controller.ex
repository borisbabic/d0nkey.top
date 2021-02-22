defmodule BackendWeb.FallbackController do
  use Phoenix.Controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(BackendWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(403)
    |> put_view(BackendWeb.ErrorView)
    |> render(:"403")
  end

  def unauthorized(conn), do: call(conn, {:error, :unauthorized})
  def not_found(conn), do: call(conn, {:error, :not_found})
end
