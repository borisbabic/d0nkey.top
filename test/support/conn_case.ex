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
        {:ok, user} = create_auth_user(tags)

        conn =
          Phoenix.ConnTest.build_conn()
          |> Plug.Session.call(@signing_opts)
          |> Plug.Conn.fetch_session()
          |> Backend.UserManager.Guardian.Plug.sign_in(user)

        {conn, user}
      else
        {Phoenix.ConnTest.build_conn(), nil}
      end

    {:ok, conn: conn, user: user}
  end

  defp create_auth_user(tags) do
    roles = tags |> Map.keys() |> Enum.filter(&Backend.UserManager.User.is_role?/1)

    %{
      battletag: "test_user",
      admin_roles: roles |> Enum.map(&to_string/1),
      bnet_id: 1
    }
    |> Backend.UserManager.create_user()
  end
end
