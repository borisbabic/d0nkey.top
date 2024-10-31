defmodule Components.Filter.ForceFreshDropdown do
  @moduledoc false
  use Surface.LiveComponent
  alias Components.LivePatchDropdown

  def render(assigns) do
    ~F"""
      <span>
        <LivePatchDropdown
          options={[{nil, "Aggregated Data"}, {"yes", Components.Helper.warning_triangle(%{before: "Fresh Data"})}]}
          title={"Force Fresh?"}
          param={"force_fresh"}
          selected_as_title={true}
        />
      </span>
    """
  end
end
