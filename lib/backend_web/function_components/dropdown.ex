defmodule FunctionComponents.Dropdown do
  @moduledoc false

  use BackendWeb, :component

  attr :title, :any, required: false
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def menu(assigns) do
    ~H"""
    <div
      class={["tw-relative tw-inline-block", @class]}
      x-on:mouseenter="if (window.matchMedia('(pointer: fine)').matches) open = true"
      x-on:mouseleave="if(window.canCloseDropdown($event)) open=false;"
      x-data="{open: false}"
      x-bind:aria-expanded="open"
      x-on:keydown.esc="open=false"
    >
      <.title :if={@title} title={@title} />
      
      <div 
        x-cloak
        x-show="open"
        x-transition:enter="tw-transition tw-ease-out tw-duration-100"
        x-transition:enter-start="tw-transform tw-opacity-0 tw-scale-95"
        x-transition:enter-end="tw-transform tw-opacity-100 tw-scale-100"
        x-transition:leave="tw-transition tw-ease-in tw-duration-75"
        x-transition:leave-start="tw-transform tw-opacity-100 tw-scale-100"
        x-transition:leave-end="tw-transform tw-opacity-0 tw-scale-95"
        class="tw-absolute tw-left-0 tw-z-30 tw-top-full tw-pt-1 tw-min-w-[12rem] tw-origin-top-left" 
        role="menu"
      >
        <div class="tw-bg-[#222222] tw-border tw-border-slate-700/60 tw-rounded-xl tw-p-1.5 tw-shadow-xl tw-shadow-black/50">
          {render_slot(@inner_block)}
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
    <.link
      aria-haspopup="true"
      tabindex="0"
      x-on:click.prevent="open=!open"
      x-on:keydown.up.prevent="open=false"
      x-on:keydown.down.prevent="if(open){$event.target.nextElementSibling.firstElementChild.firstElementChild.focus()} else {open=true}"
      x-on:keydown.space.prevent="open=!open"
      x-on:keydown.enter.prevent="open=!open"
      class={[
        @class,
        "tw-inline-flex tw-items-center tw-gap-2 tw-bg-slate-800/60 hover:tw-bg-slate-800 tw-text-slate-200 hover:tw-text-white tw-border tw-border-slate-700/60 tw-rounded-lg tw-px-3 tw-py-1.5 tw-text-xs tw-font-semibold tw-transition-all"
      ]}
    >
      {@title}
      <svg 
        class="tw-w-3.5 tw-h-3.5 tw-text-slate-400 tw-transition-transform tw-duration-200" 
        x-bind:class="open && 'tw-rotate-180'" 
        fill="none" 
        viewBox="0 0 24 24" 
        stroke="currentColor"
      >
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M19 9l-7 7-7-7" />
      </svg>
    </.link>
    """
  end

  attr :rest, :global, include: ~w(href)
  attr :class, :string, default: nil
  attr :selected, :boolean, default: nil
  attr :base_class, :string, default: nil
  slot :inner_block, required: true

  def item(assigns) do
    ~H"""
    <.link
      class={[
        @base_class,
        @class,
        "tw-flex tw-items-center tw-w-full tw-px-3 tw-py-2 tw-text-xs tw-font-medium tw-rounded-md tw-transition-colors tw-min-h-[32px]",
        @selected && "tw-bg-sky-500/10 tw-text-sky-400 tw-font-semibold",
        !@selected && "tw-text-slate-300 hover:tw-bg-slate-700/50 hover:tw-text-white"
      ]}
      {@rest}
      tabindex="0"
      x-on:click="open=false"
      x-on:keydown.space.prevent="$event.target.click()"
      x-on:keydown.enter.prevent="$event.target.click()"
      aria-selected={@selected}
      x-on:keydown.up.prevent="if (sibl = $event.target.previousElementSibling) { sibl.focus()} else if (parent = $event.target.parentElement.parentElement.previousElementSibling) { parent.focus()}"
      x-on:keydown.down.prevent="if (sibl = $event.target.nextElementSibling) {sibl.focus()}"
      x-on:keydown.esc="if (parent = $event.target.parentElement.parentElement.previousElementSibling) { parent.focus()}"
    >
      <div class="tw-flex-1 tw-truncate tw-inline-flex tw-items-center">
        {render_slot(@inner_block)}
      </div>
      <span :if={@selected} class="tw-h-1.5 tw-w-1.5 tw-rounded-full tw-bg-sky-400 tw-ml-2 tw-shrink-0"></span>
    </.link>
    """
  end
end
