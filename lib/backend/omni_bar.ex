defmodule OmniBar do
  @moduledoc "Backend behind the omni bar, orchestrates searches"

  def providers(), do: [BackendWeb.DeckcodeSearchProvider]

  def search(term, reply) do
    Enum.each(providers(), fn p ->
      Task.start(fn ->
        apply(p, :search, [term, reply])
      end)
    end)
  end
end
