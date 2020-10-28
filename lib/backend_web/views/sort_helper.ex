defmodule BackendWeb.SortHelper do
  def opposite(:desc), do: :asc
  def opposite(_), do: :desc
  def symbol(:asc), do: "↓"
  def symbol(_), do: "↑"
end
