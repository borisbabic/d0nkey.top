defmodule FunctionComponents.MiscComponents do
  use Phoenix.Component
  alias FunctionComponents.CoreComponents, as: Core
  @moduledoc "Function components that need a home"

  @doc """
  Renders a visual metric calculation block for a single stat event.
  """
  attr :title, :string, required: true
  attr :formula, :string, required: true
  attr :description, :string, required: true
  attr :count_name, :string, required: true
  attr :badge, :string, default: nil
  attr :badge_type, :string, default: "success", values: ["success", "info", "warning"]

  def stat_card(assigns) do
    ~H"""
    <div class="tw-p-5 has-background-dark tw-border tw-border-slate-800 tw-rounded-xl tw-shadow-sm tw-space-y-2">
      <div class="tw-flex tw-justify-between tw-items-start">
        <h4 class="tw-font-bold text-white"><%= @title %></h4>
        <%= if @badge do %>
          <span class={"tw-text-xs tw-px-2 tw-py-0.5 tw-rounded-full tw-font-medium tw-border tw-border-#{@badge_type}/20 has-text-#{@badge_type}"}>
            <%= @badge %>
          </span>
        <% end %>
      </div>
      <Core.code>
        {@formula}
      </Core.code>
      <p class="tw-text-sm tw-text-slate-400"><%= @description %></p>
      <div class="tw-text-xs tw-text-slate-500 tw-pt-1">
        Sample Size: <span class="tw-font-semibold tw-text-slate-300"><%= @count_name %></span>
      </div>
    </div>
    """
  end

  @doc """
  Renders text heavy documentation blocks such as text layout structures.
  """
  attr :title, :string, required: true
  attr :variant, :string, default: "default", values: ["default", "boxed"]
  slot :inner_block, required: true

  def section_block(assigns) do
    ~H"""
    <div class={[
      "tw-space-y-3",
      @variant == "boxed" && "tw-p-6 has-background-dark tw-rounded-2xl tw-border tw-border-slate-800",
      @variant == "default" && "tw-p-6 tw-border tw-border-slate-800 tw-rounded-2xl tw-bg-slate-800/20"
    ]}>
      <h2 class="tw-text-xl tw-font-bold text-white"><%= @title %></h2>
      <div class="tw-text-sm tw-text-slate-400 tw-leading-relaxed">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  @doc """
  Renders configuration variables, side-effects, or engine options.
  """
  attr :title, :string, required: true
  attr :example, :string, required: true
  slot :inner_block, required: true

  def filter_row(assigns) do
    ~H"""
    <div class="tw-p-5 tw-space-y-2">
      <h4 class="tw-font-bold has-text-success"><%= @title %></h4>
      <p class="tw-text-sm tw-text-slate-400">
        <%= render_slot(@inner_block) %>
      </p>
      <div class="tw-bg-black/30 tw-p-3 tw-rounded-lg tw-text-xs tw-text-slate-400 tw-border tw-border-slate-800 tw-border-dashed">
        <strong>Example:</strong> <%= @example %>
      </div>
    </div>
    """
  end

  @doc """
  Renders an onboarding or setup checklist with built-in state validation.
  """
  attr :title, :string, required: true
  attr :is_done, :boolean, default: false
  slot :inner_block, required: true

  def setup_step(assigns) do
    ~H"""
    <div class="tw-flex tw-items-start tw-gap-4 tw-p-5 has-background-dark tw-border tw-border-slate-800 tw-rounded-xl tw-shadow-sm">
      <div class="tw-flex-shrink-0 tw-mt-0.5">
        <%= if @is_done do %>
          <span class="tw-inline-flex tw-items-center tw-justify-center tw-w-6 tw-h-6 tw-rounded-full has-background-success has-text-dark tw-text-xs tw-font-bold">
            ✓
          </span>
        <% else %>
          <span class="tw-inline-flex tw-items-center tw-justify-center tw-w-6 tw-h-6 tw-rounded-full tw-bg-slate-800 tw-text-slate-400 tw-text-xs tw-font-bold tw-border tw-border-slate-700">
            !
          </span>
        <% end %>
      </div>
      <div class="tw-space-y-1">
        <h4 class={[
          "tw-font-bold tw-text-sm",
          @is_done && "tw-text-slate-400 tw-line-through",
          !@is_done && "text-white"
        ]}>
          <%= @title %>
        </h4>
        <p class="tw-text-sm tw-text-slate-400">
          <%= render_slot(@inner_block) %>
        </p>
      </div>
    </div>
    """
  end
end
