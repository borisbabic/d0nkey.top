defmodule Components.ClassStatsModal do
  @moduledoc false
  use BackendWeb, :surface_live_component
  alias Components.Modal
  alias Components.ClassStatsTable

  prop(show_modal, :boolean, default: false)
  prop(title, :string, required: false)
  prop(button_title, :string, required: false)
  prop(modal_title, :string, required: false)
  prop(get_stats, :fun, required: true)
  prop(class, :css_class)
  data(default_title, :string, default: "Class Stats")

  def render(assigns) do
    ~F"""
    <span>
      <Modal
      id={"modal_#{@id}"}
      button_title={@button_title || @title || @default_title}
      title={@modal_title || @title || @default_title}
      >
        <ClassStatsTable stats={@get_stats.()} />
      </Modal>
    </span>
    """
  end
end
