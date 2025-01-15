defmodule Components.Filter.FactionDropdown do
  @moduledoc false
  use Surface.LiveComponent
  alias Components.LivePatchDropdown
  prop(title, :string, default: "Faction")
  prop(param, :string, default: "faction")
  prop(include_any?, :boolean, default: true)
  prop(options, :list, default: nil)

  def render(assigns) do
    ~F"""
    <span>
      <LivePatchDropdown
        options={options(@options, @include_any?)}
        title={@title}
        param={@param} />
    </span>
    """
  end

  def options(nil, include_any?) do
    Backend.Hearthstone.faction_options()
    |> Enum.sort_by(&elem(&1, 1), :asc)
    |> options(include_any?)
  end

  def options(options, include_any?) when is_list(options) do
    if include_any? do
      [{nil, "Any Faction"} | options]
    else
      options
    end
  end
end
