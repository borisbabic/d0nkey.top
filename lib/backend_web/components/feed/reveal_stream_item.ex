defmodule Components.Feed.RevealStreamItem do
  @moduledoc false
  use BackendWeb, :surface_component
  alias Backend.Feed.RevealStream
  alias FunctionComponents.DeckComponents

  prop(item, :map, required: true)

  def render(assigns) do
    ~F"""
    <span>
       <div :if={rs = RevealStream.get(@item.value)} class="card">
        <div class="card-header">
          <span class="card-header-title">
            <span :if={rs.display}>{rs.display}</span>
            <span class="" :for={class <- rs.classes}>
              <DeckComponents.class_icon class_slug={class}/>
            </span>
            <span class="tw-italic">
              {#if Twitch.HearthstoneLive.twitch_display_live?(rs.twitch_channel)}
                <p>Live Now!</p>
              {#else}
                <Components.Helper.relative_datetime datetime={rs.start_time}/>
              {/if}
            </span>
          </span>
        </div>
        <div class="card-content">
          <div class="content">
            <Components.Socials.twitch_channel :if={rs.twitch_channel} channel={rs.twitch_channel} show_live={false}/>
            <span :if={rs.drops}>(Drops!)</span>

            <.participant participant={rs.host} display_prefix={"Host: "}/>
            <.participant :for={dev <- rs.devs} participant={dev} display_prefix={"Dev: "}/>
            <.participant :for={guest <- rs.guests} participant={guest} display_prefix={"Guest: "}/>
          </div>
        </div>
       </div>
    </span>
    """
  end

  attr :participant, :map, required: true
  attr :display_prefix, :string, default: ""

  def participant(%{participant: nil} = assigns) do
    ~H"""
    <span class="empty_participant"></span>
    """
  end

  def participant(%{participant: %{link: link}} = assigns) when is_binary(link) do
    ~H"""
      <div>
        <a href={@participant.link}>{@display_prefix}{@participant.display}</a>
      </div>
    """
  end

  def participant(assigns) do
    ~H"""
      <div>{@display_prefix}{dbg(@participant).display}</div>
    """
  end
end
