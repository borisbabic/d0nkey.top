defmodule Components.Filter.ForceFreshDropdown do
  @moduledoc false
  use Surface.LiveComponent
  alias Components.LivePatchDropdown

  def render(assigns) do
    ~F"""
      <span>
        <LivePatchDropdown
          options={[{nil, "No"}, {"yes", Components.Helper.warning_triangle(%{before: "Yes"})}]}
          title={"Force Fresh"}
          param={"force_fresh"}
          selected_as_title={false}
        />
      </span>
    """
  end
end
