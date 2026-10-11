defmodule Components.Filter.RarityDropdown do
  @moduledoc false
  use Surface.LiveComponent
  alias Components.LivePatchDropdown

  prop(title, :string, default: "Rarity")
  prop(icon, :atom, default: :rarity)
  prop(param, :string, default: "rarity")
  prop(include_any?, :boolean, default: true)
  prop(options, :list, default: nil)

  def render(assigns) do
    ~F"""
    <span>
      <LivePatchDropdown
        icon={@icon}
        options={options(@options, @include_any?)}
        title={@title}
        param={@param} />
    </span>
    """
  end

  def options(nil, include_any?) do
    Backend.Hearthstone.rarity_options()
    |> Enum.sort_by(&elem(&1, 1), :asc)
    |> options(include_any?)
  end

  def options(options, include_any?) when is_list(options) do
    if include_any? do
      [{nil, "Any Rarity"} | options]
    else
      options
    end
  end
end
