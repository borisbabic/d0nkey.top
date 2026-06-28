# Mix.Utils.extract_files(["test/support"], [:ex]) |> Enum.each(&Code.require_file/1)
ExUnit.configure(exclude: [:external])
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Backend.Repo, :manual)

# Ecto.Adapters.SQL.Sandbox.mode(Backend.Repo, {:shared, self()})
# Ecto.Adapters.SQL.Sandbox.mode(Backend.Repo, :manual)
