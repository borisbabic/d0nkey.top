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

      def create_temp_user(attrs \\ %{}) do
        {:ok, user} =
          attrs
          |> Enum.into(
          %{
            battletag: Ecto.UUID.generate(),
            bnet_id: :rand.uniform(2147483646)
          })
          |> Backend.UserManager.create_user()

        user
      end
    end
  end

  @default_opts [
    store: :cookie,
    key: "secretkey",
    encryption_salt: "encrypted cookie salt",
    signing_salt: "signing salt"
  ]
  @signing_opts Plug.Session.init(Keyword.put(@default_opts, :encrypt, false))

  # setup_all tags do
  # end
  setup tags do

    Backend.DataCase.setup_db(tags)
    opts =
      [conn: Phoenix.ConnTest.build_conn()]
      |> setup_user(tags)
      |> setup_api_user(tags)

    # {conn, user, api_user} =
    # cond do
    # tags[:authenticated] ->
    # {:ok, user} = create_auth_user_from_tags(tags, tags[:other_battletag])

    # conn =
    # user
    # |> build_conn_with_user()

    # {conn, user, nil}
    # tags[:api_user] ->
    # true ->
    # {Phoenix.ConnTest.build_conn(), nil, nil}

    # end
    # if tags[:authenticated] do
    # else
    # end

    {:ok, opts}
  end

  defp setup_user(carry, tags) do
    if tags[:authenticated] do
      {:ok, user} = create_auth_user_from_tags(tags, tags[:other_battletag])
      conn = user |> build_conn_with_user(tags[:conn])

      carry
      |> Keyword.merge(conn: conn, user: user)
    else
      carry
    end
  end

  defp setup_api_user(carry, tags) do
    if tags[:api_user] do
      {:ok, conn, api_user} = build_conn_with_api_user(tags[:conn])

      carry
      |> Keyword.merge(conn: conn, api_user: api_user)
    else
      carry
    end
  end

  @spec build_conn_with_user(Backend.UserManager.User.t()) :: Plug.Conn.t()
  def build_conn_with_user(user, conn \\ nil) do
    conn
    |> ensure_conn()
    |> Plug.Session.call(@signing_opts)
    |> Plug.Conn.fetch_session()
    |> Backend.UserManager.Guardian.Plug.sign_in(user)
  end

  defp build_conn_with_api_user(conn) do
    with {:ok, api_user} <-
           Backend.Api.create_api_user(%{username: "test_api_user", password: "new_password"}) do
      new_conn =
        conn
        |> ensure_conn()
        |> Plug.Conn.put_req_header(
          "authorization",
          "Basic " <> Base.encode64("test_api_user:new_password")
        )

      {:ok, new_conn, api_user}
    end
  end

  defp create_auth_user_from_tags(tags, alt_battletag) do
    roles = tags |> Map.keys() |> Enum.filter(&Backend.UserManager.User.is_role?/1)
    more_attrs = if alt_battletag, do: %{battletag: "alt_battletag#4321"}, else: %{}
    attrs = %{admin_roles: roles} |> Map.merge(more_attrs)
    ensure_auth_user(attrs)
  end

  defp ensure_conn(nil), do: Phoenix.ConnTest.build_conn()
  defp ensure_conn(conn), do: conn

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
