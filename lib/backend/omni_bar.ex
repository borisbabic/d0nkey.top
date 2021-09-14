defmodule OmniBar do
  @moduledoc "Backend behind the omni bar, orchestrates searches"

  def providers(), do: [BackendWeb.DeckcodeSearchProvider]

  def search(term, reply) do
    Enum.each(providers(), &apply(&1, :search, [term, reply]))
  end
end
