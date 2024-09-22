defmodule FunctionComponents.Dropdown do
  @moduledoc false

  use Phoenix.Component

  attr :title, :any, required: false
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def menu(assigns) do
    ~H"""
      <div class={["has-dropdown", "dropdown", "is-hoverable", @class]} @mouseleave="if(window.canCloseDropdown($event)) open=false;" x-data="{open: false}" x-bind:class="{'is-active': open}" x-bind:aria-expanded="open" @keydown.esc={"open=false"}>
          <.title :if={@title} title={@title} />
          <div class="dropdown-menu" role="menu">
            <div class="dropdown-content">
              <%= render_slot(@inner_block) %>
            </div>
          </div>
      </div>
    """
  end

  attr :title, :any, required: true
  attr :class, :string, default: "button"
  attr :aria_controls, :string, default: "dropdown-menu"

  def title(assigns) do
    ~H"""
      <.link aria-haspopup="true" aria-controls={@aria_controls} tabindex="0" @keydown.up.prevent="open=false" @keydown.down.prevent="if(open){$event.target.nextElementSibling.firstElementChild.firstElementChild.focus()} else {open=true}" @keydown.space.prevent="open=!open" @keydown.enter.prevent="open=!open" @mouseover="open=true" class={@class}>
        <%= @title %>
      </.link>
    """
  end

  attr :rest, :global
  attr :class, :string, default: nil
  attr :selected, :boolean, default: nil
  attr :base_class, :string, default: "dropdown-item"
  slot :inner_block, required: true

  def item(assigns) do
    ~H"""
    <.link class={[@base_class, @class, @selected && "is-active"]} {@rest} tabindex="0" @keydown.space.prevent={"$event.target.click()"} @keydown.enter.prevent={"$event.target.click()"} aria-selected={@selected} @keydown.up.prevent={"if (sibl = $event.target.previousElementSibling) { sibl.focus()} else if (parent = $event.target.parentElement.parentElement.previousElementSibling) { parent.focus()}"} @keydown.down.prevent={"if (sibl = $event.target.nextElementSibling) {sibl.focus()}"} @keydown.esc={"if (parent = $event.target.parentElement.parentElement.previousElementSibling) { parent.focus()}"}>
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end
end
