defmodule Components.OmniBarHelp do
  @moduledoc false
  use BackendWeb, :surface_live_component
  alias Components.Modal
  prop(show_modal, :boolean, default: false)
  prop(title, :string, default: "Omni Bar")

  def render(assigns) do
    ~F"""
    <span>
      <Modal
      id={"modal_#{@id}"}
      button_title={HeroIcons.info_circle(%{})}
      title={@title} >
        <div>
          Type or paste something to get relevant links. Currently supported:
        </div>
        <ul :for={thing <- ["Battlefy link", "Deckcode", "Battletags"]}>
          <li>{thing}</li>
        </ul>
        <div>
          More is planned! If you have an idea join my discord to share it after checking the pinned post
        </div>
      </Modal>
    </span>
    """
  end
end
