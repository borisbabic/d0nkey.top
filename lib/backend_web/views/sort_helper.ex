defmodule BackendWeb.SortHelper do
  def opposite(:desc), do: :asc
  def opposite(_), do: :desc
  def symbol(:asc), do: "↓"
  def symbol(_), do: "↑"

  def sort_name(sort_slug, field_name_getter) do
    case split_sort_slug(sort_slug) do
      {:asc, "inserted_at"} ->
        "Oldest"

      {:desc, "inserted_at"} ->
        "Latest"

      {direction, field_slug} ->
        field_name = field_name_getter.(field_slug)
        arrow = symbol(direction)
        "#{field_name} #{arrow}"
    end
  end

  @spec split_sort_slug(String.t()) :: {direction :: :asc | :desc, field_slug :: String.t()}
  def split_sort_slug(sort_slug) do
    case sort_slug do
      "asc_" <> field_slug -> {:asc, field_slug}
      "desc_" <> field_slug -> {:desc, field_slug}
    end
  end
end
