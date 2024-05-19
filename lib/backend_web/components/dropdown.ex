defmodule Components.Dropdown do
  @moduledoc false
  use Surface.Component

  slot(default, required: true)
  prop(title, :string)
  prop(class, :css_class, default: nil)

  def render(assigns) do
    ~F"""
      <div class={"dropdown", "is-hoverable", @class}>
          <div class="dropdown-trigger"><button aria-haspopup="true" aria-controls="dropdown-menu" class="button" type="button">{@title}</button></div>
          <div class="dropdown-menu" role="menu">
              <div class="dropdown-content">
                <#slot />
              </div>
          </div>
      </div>
    """
  end
end
