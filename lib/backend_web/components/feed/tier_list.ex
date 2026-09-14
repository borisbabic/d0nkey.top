defmodule Components.Feed.TierList do
  @moduledoc "Tier list for the front page"
  use BackendWeb, :surface_component

  alias Components.WinrateTag

  prop(stats, :list, default: nil)

  def render(assigns) do
    stats = assigns.stats || get_tier_list()
    assigns = assign(assigns, stats: stats)

    ~F"""
    <div
      :if={@stats && Enum.any?(@stats)}
      class="card tw-bg-[#232a2a] tw-border tw-border-slate-700/80 tw-rounded-xl tw-shadow-xl hover:tw-border-slate-600/80 tw-transition-all tw-duration-200 tw-overflow-hidden tw-flex tw-flex-col"
      style="width: calc(2*(var(--decklist-width) - 15px));"
    >
      <!-- Header -->
      <div class="tw-flex tw-items-center tw-justify-between tw-px-3.5 tw-py-2.5 tw-border-b tw-border-slate-700/70 tw-bg-[#1b2020]/60">
        <div class="tw-flex tw-items-center tw-gap-2">
          <div class="tw-p-1.5 tw-rounded-lg tw-bg-amber-500/10 tw-text-amber-400 tw-border tw-border-amber-500/20">
            <svg class="tw-w-3.5 tw-h-3.5" viewBox="0 0 24 24" fill="currentColor">
              <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
            </svg>
          </div>
          <div>
            <h3 class="tw-text-xs tw-font-bold tw-text-white tw-tracking-tight">Top Archetypes</h3>
            <p class="tw-text-[10px] tw-text-slate-400">Diamond–Legend • Last 2 Days</p>
          </div>
        </div>
        <a
          href="/meta"
          class="tw-inline-flex tw-items-center tw-gap-1 tw-px-2.5 tw-py-1 tw-rounded-lg tw-text-xs tw-font-semibold tw-bg-slate-800/90 hover:tw-bg-slate-700 tw-text-slate-200 tw-border tw-border-slate-700 hover:tw-border-slate-600 tw-transition-all tw-duration-150"
        >
          <span>Meta</span>
          <svg class="tw-w-3 tw-h-3 tw-text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
          </svg>
        </a>
      </div>

      <div class="tw-overflow-y-auto tw-max-h-[480px]">
        <.table id="feed_tier_list_table">
          <.thead>
            <.trh>
              <.th class="tw-text-xs tw-w-8 tw-text-center">#</.th>
              <.th class="tw-text-xs">Archetype</.th>
              <.th class="tw-text-xs tw-text-right">Winrate</.th>
            </.trh>
          </.thead>
          <.tbody>
            <.trb :for={{stat, idx} <- Enum.with_index(@stats)}>
              <.td class="tw-text-xs tw-text-center tw-font-mono tw-text-slate-500">{idx + 1}</.td>
              <.td class="tw-text-xs">
                <a href={~p"/archetype/#{stat.archetype}"} class="tw-text-slate-200 hover:tw-text-sky-300 tw-font-medium tw-transition-colors">
                  {stat.archetype}
                </a>
              </.td>
              <.td class="tw-text-xs tw-text-right"><WinrateTag winrate={stat.winrate} /></.td>
            </.trb>
          </.tbody>
        </.table>
      </div>
    </div>
    """
  end

  defp get_tier_list do
    Hearthstone.DeckTracker.archetype_stats([
      {"period", Components.Filter.PeriodDropdown.default(:public, 2)},
      :diamond_to_legend,
      {"format", 2}
    ])
    |> Enum.sort_by(& &1.total, :desc)
    |> Enum.take(25)
    |> Enum.sort_by(& &1.winrate, :desc)
  end
end
