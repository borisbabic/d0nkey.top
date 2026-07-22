defmodule BackendWeb.DeveloperApiFallbackController do
  use Phoenix.Controller, formats: [:json]

  import Plug.Conn

  def call(conn, {:error, {:invalid_parameter, parameter, message}}) do
    conn
    |> put_status(:bad_request)
    |> json(%{
      error: %{
        code: "invalid_parameter",
        message: "#{parameter} #{message}",
        parameter: parameter
      }
    })
  end

  def call(conn, {:error, :filters_not_available}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{
      error: %{
        code: "filters_not_available",
        message: "The requested filter combination is not available in public aggregates"
      }
    })
  end

  def call(conn, {:error, :archetype_not_found}) do
    conn
    |> put_status(:not_found)
    |> json(%{error: %{code: "archetype_not_found", message: "Archetype was not found"}})
  end
end
