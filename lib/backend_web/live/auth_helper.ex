defmodule BackendWeb.AuthHelper do
  @moduledoc "Utility to handle auth in live views"
  alias Backend.UserManager.User
  alias Backend.UserManager.Guardian

  @spec load_user(Map.t() | any) :: User | nil
  def load_user(%{"guardian_default_token" => token}) do
    token
    |> Guardian.resource_from_token()
    |> case do
      {:ok, user, _} -> user
      _ -> nil
    end
  end

  def load_user(_), do: nil
end
