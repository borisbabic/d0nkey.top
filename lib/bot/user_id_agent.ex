defmodule Bot.UserIdAgent do
  use Agent

  def start_link(initial_value) do
    value = (initial_value || get_new_value()) |> Util.to_int_or_orig()
    Agent.start_link(fn -> value end, name: __MODULE__)
  end

  def get() do
    Agent.get(__MODULE__, & &1)
  end

  def get_new_value() do
    get_from_self() || get_from_application_information()
  end

  defp get_from_self() do
    t = Task.async(fn -> Nostrum.Api.Self.get() end)

    case Task.yield(t, 500) do
      {:ok, {:ok, %{id: id}}} ->
        id

      _ ->
        Task.shutdown(t)
        nil
    end
  end

  defp get_from_application_information() do
    t = Task.async(fn -> Nostrum.Api.Self.application_information() end)

    case Task.yield(t, 500) do
      {:ok, {:ok, %{bot: %{id: id}}}} ->
        id

      _ ->
        Task.shutdown(t)
        nil
    end
  end
end
