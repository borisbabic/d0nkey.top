defmodule BackendWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      alias BackendWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint BackendWeb.Endpoint
    end
  end

  @default_opts [
    store: :cookie,
    key: "secretkey",
    encryption_salt: "encrypted cookie salt",
    signing_salt: "signing salt"
  ]
  @signing_opts Plug.Session.init(Keyword.put(@default_opts, :encrypt, false))

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Backend.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Backend.Repo, {:shared, self()})
    end

    {conn, user} =
      if tags[:authenticated] do
        {:ok, user} = create_auth_user_from_tags(tags, tags[:other_battletag])

        conn =
          user
          |> build_conn_with_user()

        {conn, user}
      else
        {Phoenix.ConnTest.build_conn(), nil}
      end

    {:ok, conn: conn, user: user}
  end

  @spec build_conn_with_user(Backend.UserManager.User.t()) :: Plug.Conn.t()
  def build_conn_with_user(user) do
    Phoenix.ConnTest.build_conn()
    |> Plug.Session.call(@signing_opts)
    |> Plug.Conn.fetch_session()
    |> Backend.UserManager.Guardian.Plug.sign_in(user)
  end

  defp create_auth_user_from_tags(tags, alt_battletag) do
    roles = tags |> Map.keys() |> Enum.filter(&Backend.UserManager.User.is_role?/1)
    more_attrs = if alt_battletag, do: %{battletag: "alt_battletag#4321"}, else: %{}
    attrs = %{admin_roles: roles} |> Map.merge(more_attrs)
    ensure_auth_user(attrs)
  end

  @spec ensure_auth_user(Map.t()) :: {:ok, User.t()} | {:error, any()}
  def ensure_auth_user(opts \\ %{}) when is_map(opts) do
    base_attrs = %{
      battletag: "test_user#1234",
      admin_roles: [],
      bnet_id: 1,
      hide_ads: false,
      decklist_options: %{border: nil, gradient: nil}
    }

    with attrs = %{battletag: btag} <- base_attrs |> Map.merge(opts),
         nil <- Backend.UserManager.get_by_btag(btag) do
      Backend.UserManager.create_user(attrs)
    else
      user = %{battletag: _} -> {:ok, user}
      _ -> {:error, "couldn't ensure user "}
    end
  end
end
