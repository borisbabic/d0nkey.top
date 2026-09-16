defmodule Components.Feed.RevealStreamItem do
  @moduledoc false
  use BackendWeb, :surface_component
  alias Backend.Feed.RevealStream
  alias FunctionComponents.DeckComponents

  prop(item, :map, required: true)

  def render(assigns) do
    ~F"""
    <span>
      <div
        :if={rs = RevealStream.get(@item.value)}
        class="card tw-bg-[#232a2a] tw-border tw-border-slate-700/80 tw-rounded-xl tw-shadow-xl hover:tw-border-slate-600/80 tw-transition-all tw-duration-200 tw-overflow-hidden tw-flex tw-flex-col"
        style="width: calc(var(--decklist-width) + 15px); min-width: 220px;"
      >
        <!-- Card Header -->
        <div class="tw-p-3 tw-border-b tw-border-slate-700/70 tw-bg-[#1b2020]/60 tw-space-y-2">
          <div class="tw-flex tw-items-center tw-justify-between tw-gap-2">
            <h3 :if={rs.display} class="tw-text-xs tw-font-bold tw-text-white tw-tracking-tight tw-truncate">{rs.display}</h3>
            <div class="tw-flex tw-items-center tw-gap-1 tw-shrink-0">
              <span :for={class <- rs.classes} class="tw-w-4 tw-h-4 tw-inline-flex tw-items-center tw-justify-center">
                <DeckComponents.class_icon class_slug={class}/>
              </span>
            </div>
          </div>
          <div class="tw-flex tw-flex-wrap tw-items-center tw-gap-1.5">
            {#if Twitch.HearthstoneLive.twitch_display_live?(rs.twitch_channel)}
              <span class="tw-inline-flex tw-items-center tw-gap-1 tw-px-2 tw-py-0.5 tw-rounded-md tw-text-[10px] tw-font-bold tw-bg-emerald-500/20 tw-text-emerald-400 tw-border tw-border-emerald-500/40">
                <span class="tw-w-1.5 tw-h-1.5 tw-rounded-full tw-bg-emerald-400 tw-animate-pulse"></span>
                Live Now
              </span>
            {#else}
              <span class="tw-inline-flex tw-items-center tw-gap-1 tw-px-2 tw-py-0.5 tw-rounded-md tw-text-[10px] tw-font-medium tw-bg-slate-800 tw-text-slate-300 tw-border tw-border-slate-700/60">
                <svg class="tw-w-3 tw-h-3 tw-text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
                </svg>
                <Components.Helper.relative_datetime datetime={rs.start_time}/>
              </span>
            {/if}
            <span :if={rs.drops} class="tw-inline-flex tw-items-center tw-gap-1 tw-px-2 tw-py-0.5 tw-rounded-md tw-text-[10px] tw-font-bold tw-bg-amber-500/15 tw-text-amber-400 tw-border tw-border-amber-500/30">
              Drops!
            </span>
          </div>
        </div>

        <!-- Card Content -->
        <div class="tw-p-3 tw-space-y-3">
          <div :if={rs.twitch_channel || rs.youtube_channel} class="tw-flex tw-items-center tw-gap-2">
            <Components.Socials.twitch :if={rs.twitch_channel} channel={rs.twitch_channel} />
          </div>
          <div :if={rs.youtube_channel} class="tw-flex tw-items-center tw-gap-2">
            <Components.Socials.youtube channel={rs.youtube_channel} />
          </div>

          <div
            :if={rs.host || (rs.devs && Enum.any?(rs.devs)) || (rs.guests && Enum.any?(rs.guests))}
            class="tw-bg-[#1b2020] tw-rounded-lg tw-p-2.5 tw-border tw-border-slate-700/70 tw-space-y-1.5"
          >
            <.participant participant={rs.host} role="Host"/>
            <.participant :for={dev <- rs.devs} participant={dev} role="Dev"/>
            <.participant :for={guest <- rs.guests} participant={guest} role="Guest"/>
          </div>
        </div>
      </div>
    </span>
    """
  end

  attr :participant, :map, required: true
  attr :role, :string, default: ""

  def participant(%{participant: nil} = assigns), do: ~H""

  def participant(%{participant: %{link: link}} = assigns) when is_binary(link) do
    ~H"""
    <div class="tw-flex tw-items-center tw-gap-1.5 tw-text-xs">
      <span class="tw-px-1.5 tw-py-0.5 tw-rounded tw-text-[10px] tw-font-bold tw-uppercase tw-tracking-wider tw-bg-slate-800 tw-text-slate-400 tw-border tw-border-slate-700/60">
        <%= @role %>
      </span>
      <a href={@participant.link} target="_blank" rel="noopener noreferrer" class="tw-text-sky-400 hover:tw-text-sky-300 tw-font-medium hover:tw-underline tw-truncate">
        <%= @participant.display %>
      </a>
    </div>
    """
  end

  def participant(assigns) do
    ~H"""
    <div class="tw-flex tw-items-center tw-gap-1.5 tw-text-xs">
      <span class="tw-px-1.5 tw-py-0.5 tw-rounded tw-text-[10px] tw-font-bold tw-uppercase tw-tracking-wider tw-bg-slate-800 tw-text-slate-400 tw-border tw-border-slate-700/60">
        <%= @role %>
      </span>
      <span class="tw-text-slate-200 tw-font-medium tw-truncate">
        <%= @participant.display %>
      </span>
    </div>
    """
  end
end
