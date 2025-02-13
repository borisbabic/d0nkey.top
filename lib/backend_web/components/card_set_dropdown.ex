defmodule Components.Filter.CardSetDropdown do
  @moduledoc false
  use Surface.LiveComponent
  alias Components.LivePatchDropdown
  prop(title, :string, default: "Card Set")
  prop(param, :string, default: "card_set_id")

  def render(assigns) do
    ~F"""
    <span>
      <LivePatchDropdown options={options()}
      title={@title}
      param={@param}/>
    </span>
    """
  end

  def options() do
    options =
      Backend.Hearthstone.latest_sets_with_release_dates()
      |> Enum.map(&{to_string(&1.id), &1.name})

    [{nil, "Any"} | options]
  end
end
