defmodule Components.PonyDojoPlayer do
  use BackendWeb, :surface_component
  prop(num, :integer, required: true)
  prop(player, :map, required: true)
  alias Backend.PonyDojo
  alias Components.PlayerName
  def render(assigns) do

    ~F"""
      <div class="card" style="width: 340px;">
        <header class="card-header">
          <div class="card-header-title title is-4 level">
            <p class="level-item level-left">
              <PlayerName shorten={true} player={@player.battletag}/>
            </p>
            <p class="level-item level-right">#{@num}</p>
          </div>
        </header>
        <div class="card-image">
          <figure :if={@player.image_url} class="image is-1by1">
            <img src={@player.image_url}>
          </figure>
        </div>
        <div class="content">
          <div class="subtitle is-5 has-text-centered">
            戦闘能力・Power level<br>
            {PonyDojo.total(@player)}
          </div>
        </div>
      </div>
    """
  end
end
