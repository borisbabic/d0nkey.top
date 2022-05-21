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

  setup tags do
    setup_db(tags)

    :ok
  end

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
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Backend.Repo)

    # unless tags[:async] do
    # Ecto.Adapters.SQL.Sandbox.mode(Backend.Repo, {:shared, self()})
    # end

    # :ok

    # Ecto.Adapters.SQL.Sandbox.start_owner!(Backend.Repo, shared: not tags[:async])
    # on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
    # :ok
  end
end
