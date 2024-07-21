defmodule Backend.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Backend.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Backend.DataCase

      def create_temp_user(attrs \\ %{}) do
        {:ok, user} =
          attrs
          |> Enum.into(%{
            battletag: Ecto.UUID.generate(),
            bnet_id: :rand.uniform(2_147_483_646)
          })
          |> Backend.UserManager.create_user()

        user
      end
    end
  end

  setup [:setup_db]
  # setup [:setup_db]
  # setup do
  #   raise "ttttttttttttttttttttttttt"
  # end
  # setup tags do
  #   setup_db(tags)

  #   :ok
  # end

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end

  def setup_db(tags) do
    # pid = Ecto.Adapters.SQL.Sandbox.start_owner!(MyApp.Repo, shared: not tags[:async])
    # on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
    # :ok = Ecto.Adapters.SQL.Sandbox.checkout(Backend.Repo)

    # IO.inspect(tags, label: :setup_db)
    # checkout_set_repo_mode(tags)
    # :
    if tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Backend.Repo, :manual)
    else
      if tags[:isolation] do
        :ok = Ecto.Adapters.SQL.Sandbox.checkout(Backend.Repo, isolation: tags[:isolation])
      else
        :ok = Ecto.Adapters.SQL.Sandbox.checkout(Backend.Repo)
      end

      pid = Ecto.Adapters.SQL.Sandbox.start_owner!(Backend.Repo, shared: !tags[:async])

      on_exit(fn ->
        Ecto.Adapters.SQL.Sandbox.stop_owner(pid)
        # checkout_set_repo_mode(tags)
        :ok
      end)
    end

    :ok
  end
end
