defmodule BackendWeb.WC2026Live do
  @moduledoc false
  use BackendWeb, :surface_live_view

  alias Components.TournamentLineupExplorer
  alias Components.Helper
  alias Backend.DeckInteractionTracker, as: Tracker

  data(has_lineups?, :boolean, default: false)
  data(show_bracket_predictions?, :boolean, default: false)
  data(battlefy_id, :string, default: nil)

  @groups [
    %{
      id: "A",
      name: "Group A",
      players: [
        %{index: 0, name: "McBanterFace", image: "mcbanterface", region: "Americas", region_key: :americas},
        %{index: 1, name: "Soyorin", image: "soyorin", region: "APAC", region_key: :apac},
        %{index: 2, name: "mlYanming", image: "mlyanming", region: "China", region_key: :china},
        %{index: 3, name: "hyosung", image: "hyosung", region: "APAC", region_key: :apac}
      ]
    },
    %{
      id: "B",
      name: "Group B",
      players: [
        %{index: 4, name: "maxiebon1234", image: "maxiebon", region: "APAC", region_key: :apac},
        %{index: 5, name: "WinBrownie", image: "winbrownie", region: "Americas", region_key: :americas},
        %{index: 6, name: "XiaoT", image: "xiaot", region: "China", region_key: :china},
        %{index: 7, name: "Fatty", image: "fatty", region: "Europe", region_key: :europe}
      ]
    },
    %{
      id: "C",
      name: "Group C",
      players: [
        %{index: 8, name: "Gaby59", image: "gaby", region: "Europe", region_key: :europe},
        %{index: 9, name: "Curfew", image: "curfew", region: "APAC", region_key: :apac},
        %{index: 10, name: "Xiaobai", image: "xiaobai", region: "China", region_key: :china},
        %{index: 11, name: "Kwanuu", image: "kwanuu", region: "APAC", region_key: :apac}
      ]
    },
    %{
      id: "D",
      name: "Group D",
      players: [
        %{index: 12, name: "OTGxhh", image: "otgxhh", region: "China", region_key: :china},
        %{index: 13, name: "Che0nsu", image: "che0nsu", region: "APAC", region_key: :apac},
        %{index: 14, name: "SAVOR", image: "savor", region: "Europe", region_key: :europe},
        %{index: 15, name: "Mesmile", image: "mesmile", region: "Americas", region_key: :americas}
      ]
    }
  ]

  data(groups, :list, default: @groups)

  def mount(_params, session, socket) do
    {
      :ok,
      socket
      |> assign_defaults(session)
      |> put_user_in_context()
      |> assign_has_lineups()
      |> assign_info_from_bracket_predictions()
    }
  end

  def render(assigns) do
    ~F"""
    <div
      id="wc-2026-page"
      class="tw-relative"
      x-data="{
        activeGroup: 'all',
        selectedIndex: null,
        zoomMode: true,
        touchStartX: 0,
        touchStartY: 0,
        players: [
          { name: 'McBanterFace', image: 'mcbanterface', region: 'Americas', region_key: 'americas', group: 'A' },
          { name: 'Soyorin', image: 'soyorin', region: 'APAC', region_key: 'apac', group: 'A' },
          { name: 'mlYanming', image: 'mlyanming', region: 'China', region_key: 'china', group: 'A' },
          { name: 'hyosung', image: 'hyosung', region: 'APAC', region_key: 'apac', group: 'A' },
          { name: 'maxiebon1234', image: 'maxiebon', region: 'APAC', region_key: 'apac', group: 'B' },
          { name: 'WinBrownie', image: 'winbrownie', region: 'Americas', region_key: 'americas', group: 'B' },
          { name: 'XiaoT', image: 'xiaot', region: 'China', region_key: 'china', group: 'B' },
          { name: 'Fatty', image: 'fatty', region: 'Europe', region_key: 'europe', group: 'B' },
          { name: 'Gaby59', image: 'gaby', region: 'Europe', region_key: 'europe', group: 'C' },
          { name: 'Curfew', image: 'curfew', region: 'APAC', region_key: 'apac', group: 'C' },
          { name: 'Xiaobai', image: 'xiaobai', region: 'China', region_key: 'china', group: 'C' },
          { name: 'Kwanuu', image: 'kwanuu', region: 'APAC', region_key: 'apac', group: 'C' },
          { name: 'OTGxhh', image: 'otgxhh', region: 'China', region_key: 'china', group: 'D' },
          { name: 'Che0nsu', image: 'che0nsu', region: 'APAC', region_key: 'apac', group: 'D' },
          { name: 'SAVOR', image: 'savor', region: 'Europe', region_key: 'europe', group: 'D' },
          { name: 'Mesmile', image: 'mesmile', region: 'Americas', region_key: 'americas', group: 'D' }
        ],
        open(idx) {
          this.selectedIndex = idx;
          document.body.classList.add('tw-overflow-hidden');
          this.resetScroll();
        },
        close() {
          this.selectedIndex = null;
          document.body.classList.remove('tw-overflow-hidden');
        },
        next() {
          if (this.selectedIndex !== null) {
            this.selectedIndex = (this.selectedIndex + 1) % this.players.length;
            this.resetScroll();
          }
        },
        prev() {
          if (this.selectedIndex !== null) {
            this.selectedIndex = (this.selectedIndex - 1 + this.players.length) % this.players.length;
            this.resetScroll();
          }
        },
        resetScroll() {
          this.$nextTick(() => {
            if (this.$refs.scrollArea) {
              this.$refs.scrollArea.scrollTop = 0;
            }
          });
        },
        toggleZoom() {
          this.zoomMode = !this.zoomMode;
        },
        current() {
          return this.selectedIndex !== null ? this.players[this.selectedIndex] : null;
        },
        regionClass() {
          const c = this.current();
          if (!c) return '';
          switch(c.region_key) {
            case 'americas': return 'tw-text-[#3298dc] tw-bg-[color:--color-americas]/20 tw-border-[color:--color-americas]/40';
            case 'europe': return 'tw-text-[#7faad8] tw-bg-[color:--color-europe]/25 tw-border-[color:--color-europe]/45';
            case 'apac': return 'tw-text-[#2ecc71] tw-bg-[color:--color-asia]/20 tw-border-[color:--color-asia]/40';
            case 'china': return 'tw-text-[#f1b70e] tw-bg-[color:--color-china]/20 tw-border-[color:--color-china]/40';
            default: return 'tw-text-slate-300 tw-bg-slate-800 tw-border-slate-700';
          }
        },
        handleTouchStart(e) {
          this.touchStartX = e.changedTouches[0].screenX;
          this.touchStartY = e.changedTouches[0].screenY;
        },
        handleTouchEnd(e) {
          const dx = e.changedTouches[0].screenX - this.touchStartX;
          const dy = e.changedTouches[0].screenY - this.touchStartY;
          if (Math.abs(dx) > Math.abs(dy) * 1.5 && Math.abs(dx) > 40) {
            if (dx > 0) {
              this.prev();
            } else {
              this.next();
            }
          }
        }
      }"
      x-init="$watch('selectedIndex', val => { if (val === null) document.body.classList.remove('tw-overflow-hidden'); })"
    >
      <div class="tw-space-y-8 tw-pb-10">
        <!-- Header Area -->
      <div>
        <.page_header title="Worlds 2026">
          <:nav_links>
            <a
              href="https://hearthstone.blizzard.com/news/24294372"
              target="_blank"
              rel="noopener noreferrer"
              class="tw-inline-flex tw-items-center tw-gap-1.5 tw-px-3 tw-py-1.5 tw-rounded-lg tw-text-xs tw-font-semibold tw-bg-slate-800/90 hover:tw-bg-slate-700 tw-text-slate-200 tw-border tw-border-slate-700 hover:tw-border-slate-600 tw-transition-all tw-duration-150"
            >
              <span>Viewer Guide</span>
              <HeroIcons.external_link class="tw-w-3.5 tw-h-3.5 tw-text-slate-400" />
            </a>

            <a
              :if={@battlefy_id}
              href={"/battlefy/tournament/#{@battlefy_id}"}
              class="tw-inline-flex tw-items-center tw-gap-1.5 tw-px-3 tw-py-1.5 tw-rounded-lg tw-text-xs tw-font-semibold tw-bg-slate-800/90 hover:tw-bg-slate-700 tw-text-slate-200 tw-border tw-border-slate-700 hover:tw-border-slate-600 tw-transition-all tw-duration-150"
            >
              <svg class="tw-w-3.5 tw-h-3.5 tw-text-amber-400" viewBox="0 0 24 24" fill="currentColor">
                <path d="M19 5h-2V3H7v2H5c-1.1 0-2 .9-2 2v1c0 2.55 1.92 4.63 4.39 4.94A5.01 5.01 0 0011 15.9V19H7v2h10v-2h-4v-3.1c1.9-.44 3.39-1.99 3.61-3.96C19.08 11.63 21 9.55 21 7V5h-2zm-12 5c-1.1 0-2-.9-2-2V7h2v3zm10 0V7h2v1c0 1.1-.9 2-2 2z"/>
              </svg>
              <span>Tournament</span>
            </a>

            <a
              href="https://www.twitch.tv/playhearthstone"
              target="_blank"
              rel="noopener noreferrer"
              class="tw-inline-flex tw-items-center tw-gap-1.5 tw-px-3 tw-py-1.5 tw-rounded-lg tw-text-xs tw-font-semibold tw-bg-[#9146ff]/15 hover:tw-bg-[#9146ff]/25 tw-text-[#bf94ff] tw-border tw-border-[#9146ff]/40 hover:tw-border-[#9146ff]/60 tw-transition-all tw-duration-150"
            >
              <svg class="tw-w-3.5 tw-h-3.5 tw-fill-current" viewBox="0 0 24 24">
                <path d="M11.571 4.714h1.715v5.143H11.57zm4.715 0H18v5.143h-1.714zM6 0L1.714 4.286v15.428h5.143V24l4.286-4.286h3.428L22.286 12V0zm14.571 11.143l-3.428 3.428h-3.429l-3 3v-3H6.857V1.714h13.714z"/>
              </svg>
              <span>Twitch</span>
            </a>

            <a
              href="https://www.youtube.com/Hearthstone"
              target="_blank"
              rel="noopener noreferrer"
              class="tw-inline-flex tw-items-center tw-gap-1.5 tw-px-3 tw-py-1.5 tw-rounded-lg tw-text-xs tw-font-semibold tw-bg-red-950/40 hover:tw-bg-red-900/40 tw-text-red-300 tw-border tw-border-red-700/50 hover:tw-border-red-600/60 tw-transition-all tw-duration-150"
            >
              <svg class="tw-w-3.5 tw-h-3.5 tw-fill-current" viewBox="0 0 24 24">
                <path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z"/>
              </svg>
              <span>YouTube</span>
            </a>
          </:nav_links>
          <:meta_info>
            <div class="tw-flex tw-flex-wrap tw-items-center tw-gap-2">
              <span class="tw-inline-flex tw-items-center tw-gap-1 tw-text-xs tw-text-slate-400">
                <svg class="tw-w-3.5 tw-h-3.5 tw-text-emerald-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/>
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/>
                </svg>
                BlizzCon • Anaheim, CA
              </span>
              <span class="tw-hidden sm:tw-inline tw-text-slate-600">•</span>
              <span class="tw-inline-flex tw-items-center tw-gap-1 tw-text-xs tw-text-amber-400 tw-font-mono">
                $500,000 Prize Pool
              </span>
              <span class="tw-hidden sm:tw-inline tw-text-slate-600">•</span>
              <span class="tw-text-xs tw-text-slate-400">
                4-Deck Bo5 Conquest (1 Ban)
              </span>
            </div>
          </:meta_info>
        </.page_header>

        <!-- Broadcast Talent Strip -->
        <div class="tw-mt-3 tw-flex tw-flex-wrap tw-items-center tw-gap-2.5 tw-py-2 tw-px-3.5 tw-rounded-xl tw-bg-[#232a2a] tw-border tw-border-slate-700/80 tw-text-xs tw-text-slate-300">
          <span class="tw-inline-flex tw-items-center tw-gap-1.5 tw-font-semibold tw-text-slate-200">
            <svg class="tw-w-3.5 tw-h-3.5 tw-text-sky-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z"/>
            </svg>
            Casters:
          </span>
          <div class="tw-flex tw-flex-wrap tw-items-center tw-gap-1.5">
            <span class="tw-px-2 tw-py-0.5 tw-rounded-md tw-bg-slate-800 tw-text-slate-200 tw-border tw-border-slate-700/60">Edelweiss</span>
            <span class="tw-px-2 tw-py-0.5 tw-rounded-md tw-bg-slate-800 tw-text-slate-200 tw-border tw-border-slate-700/60">Lorinda</span>
            <span class="tw-px-2 tw-py-0.5 tw-rounded-md tw-bg-slate-800 tw-text-slate-200 tw-border tw-border-slate-700/60">PocketTrain</span>
            <span class="tw-px-2 tw-py-0.5 tw-rounded-md tw-bg-slate-800 tw-text-slate-200 tw-border tw-border-slate-700/60">Raven</span>
            <span class="tw-px-2 tw-py-0.5 tw-rounded-md tw-bg-slate-800 tw-text-slate-200 tw-border tw-border-slate-700/60">Sottle</span>
            <span class="tw-px-2 tw-py-0.5 tw-rounded-md tw-bg-slate-800/60 tw-text-slate-400 tw-border tw-border-slate-700/40">& guests</span>
          </div>
        </div>
      </div>

      <!-- Promotional & Contest Callout Cards -->
      <div :if={not_started?()} class="tw-grid tw-grid-cols-1 lg:tw-grid-cols-2 tw-gap-6">
        <!-- Choose Your Champion Card -->
        <div class="tw-relative tw-overflow-hidden tw-rounded-2xl tw-border tw-border-amber-600/40 tw-bg-gradient-to-br tw-from-amber-950/30 tw-via-[#232a2a] tw-to-[#1c2222] tw-p-5 md:tw-p-6 tw-shadow-xl tw-transition-all tw-duration-200 hover:tw-border-amber-500/60 tw-flex tw-flex-col tw-justify-between tw-gap-4">
          <div class="tw-space-y-3">
            <div class="tw-flex tw-flex-wrap tw-items-center tw-justify-between tw-gap-2">
              <div class="tw-flex tw-items-center tw-gap-2">
                <span class="tw-inline-flex tw-items-center tw-gap-1 tw-px-2.5 tw-py-0.5 tw-rounded-full tw-text-xs tw-font-bold tw-uppercase tw-tracking-wider tw-bg-amber-500/15 tw-text-amber-400 tw-border tw-border-amber-500/30">
                  <svg class="tw-w-3.5 tw-h-3.5" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
                  </svg>
                  Choose Your Champion
                </span>
                <span class="tw-text-xs tw-text-slate-400">Earn Card Packs</span>
              </div>
              <span :if={cyc_open?()} class="tw-inline-flex tw-items-center tw-gap-1.5 tw-text-xs tw-font-medium tw-text-amber-300/90 tw-bg-amber-950/60 tw-px-2.5 tw-py-0.5 tw-rounded-md tw-border tw-border-amber-700/50">
                <svg class="tw-w-3.5 tw-h-3.5 tw-text-amber-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
                </svg>
                <span>Closes: <Helper.datetime datetime={~N[2026-09-08 13:00:00]} /></span>
              </span>
              <span :if={!cyc_open?()} class="tw-inline-flex tw-items-center tw-gap-1.5 tw-text-xs tw-font-medium tw-text-slate-400 tw-bg-slate-800/80 tw-px-2.5 tw-py-0.5 tw-rounded-md tw-border tw-border-slate-700/60">
                <span>Voting Closed</span>
              </span>
            </div>

            <h2 class="tw-text-xl tw-font-bold tw-text-white tw-tracking-tight">
              Vote for Your Champion
            </h2>
            <p class="tw-text-sm tw-text-slate-300">
              Pick your favorite player to earn in-game <em>Escape from Violet Hold</em> packs based on their performance, plus a Golden pack if your pick wins the title!
            </p>

            <div :if={!cyc_open?()} class="tw-flex tw-items-center tw-gap-2 tw-text-xs tw-text-slate-300 tw-bg-slate-900/60 tw-p-2.5 tw-rounded-xl tw-border tw-border-slate-800">
              <svg class="tw-w-4 tw-h-4 tw-text-slate-400 tw-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
              </svg>
              <span>
                <strong class="tw-text-white">Voting Closed:</strong> The deadline was Sep 8, 2026 at 1:00 PM UTC (<Helper.datetime datetime={~N[2026-09-08 13:00:00]} />). Picks are now locked.
              </span>
            </div>

            <p :if={!@has_lineups? and cyc_open?()} class="tw-text-xs tw-text-amber-300/80 tw-flex tw-items-center tw-gap-1.5 tw-pt-1">
              <svg class="tw-w-4 tw-h-4 tw-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
              </svg>
              <span>Tip: You may want to wait for deck lineups to be published before locking in your pick!</span>
            </p>
          </div>

          <div>
            <a
              :if={cyc_open?()}
              href="https://hearthstone.blizzard.com/vote/choose-your-champion"
              target="_blank"
              rel="noopener noreferrer"
              class="tw-inline-flex tw-items-center tw-gap-2 tw-px-4 tw-py-2 tw-rounded-xl tw-text-xs tw-font-bold tw-bg-amber-500 hover:tw-bg-amber-400 tw-text-slate-950 tw-shadow-lg tw-shadow-amber-500/20 tw-transition-all tw-duration-200 hover:tw-scale-[1.02]"
            >
              <span>Vote on hearthstone.blizzard.com</span>
              <HeroIcons.external_link class="tw-w-3.5 tw-h-3.5" />
            </a>

            <div :if={!cyc_open?()} class="tw-flex tw-items-center tw-gap-2">
              <span class="tw-inline-flex tw-items-center tw-gap-1.5 tw-px-3 tw-py-2 tw-rounded-xl tw-text-xs tw-font-semibold tw-bg-slate-800 tw-text-slate-400 tw-border tw-border-slate-700/80">
                <svg class="tw-w-3.5 tw-h-3.5 tw-text-slate-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
                </svg>
                <span>Voting Closed</span>
              </span>
              <a
                href="https://hearthstone.blizzard.com/vote/choose-your-champion"
                target="_blank"
                rel="noopener noreferrer"
                class="tw-inline-flex tw-items-center tw-gap-1.5 tw-px-3 tw-py-2 tw-rounded-xl tw-text-xs tw-font-medium tw-bg-slate-800/80 hover:tw-bg-slate-700 tw-text-slate-300 hover:tw-text-white tw-border tw-border-slate-700/60 tw-transition-all"
              >
                <span>View on Blizzard</span>
                <HeroIcons.external_link class="tw-w-3.5 tw-h-3.5" />
              </a>
            </div>
          </div>
        </div>

        <!-- Bracket Prediction Card -->
        <div :if={@show_bracket_predictions?} class="tw-relative tw-overflow-hidden tw-rounded-2xl tw-border tw-border-sky-600/40 tw-bg-gradient-to-br tw-from-sky-950/30 tw-via-[#232a2a] tw-to-[#1c2222] tw-p-5 md:tw-p-6 tw-shadow-xl tw-transition-all tw-duration-200 hover:tw-border-sky-500/60 tw-flex tw-flex-col tw-justify-between tw-gap-4">
          <div class="tw-space-y-2">
            <div class="tw-flex tw-items-center tw-gap-2">
              <span class="tw-inline-flex tw-items-center tw-gap-1 tw-px-2.5 tw-py-0.5 tw-rounded-full tw-text-xs tw-font-bold tw-uppercase tw-tracking-wider tw-bg-sky-500/15 tw-text-sky-400 tw-border tw-border-sky-500/30">
                <svg class="tw-w-3.5 tw-h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
                </svg>
                Community Contest
              </span>
              <span class="tw-text-xs tw-text-slate-400">Bundle Giveaway</span>
            </div>
            <h2 class="tw-text-xl tw-font-bold tw-text-white tw-tracking-tight">
              Bracket Prediction Contest
            </h2>
            <p class="tw-text-sm tw-text-slate-300">
              Predict every match winner from the Group Stage to the Finals. If at least 100 people fill out their bracket, 1st place wins an expansion bundle for the next expansion!
            </p>
          </div>
          <div>
            <a
              href="/bracket-predictions/tournaments/1"
              class="tw-inline-flex tw-items-center tw-gap-2 tw-px-4 tw-py-2 tw-rounded-xl tw-text-xs tw-font-bold tw-bg-sky-500 hover:tw-bg-sky-400 tw-text-slate-950 tw-shadow-lg tw-shadow-sky-500/20 tw-transition-all tw-duration-200 hover:tw-scale-[1.02]"
            >
              <span>Fill Out Your Bracket</span>
              <svg class="tw-w-3.5 tw-h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3"/>
              </svg>
            </a>
          </div>
        </div>
      </div>

      <!-- Schedule Section -->
      <div class="tw-space-y-4">
        <div class="tw-flex tw-items-center tw-justify-between">
          <div>
            <h2 class="tw-text-xl tw-font-bold tw-text-white tw-tracking-tight">Tournament Schedule</h2>
            <p class="tw-text-xs tw-text-slate-400">Match dates and times in your local timezone</p>
          </div>
          <span class="tw-text-xs tw-text-slate-400 tw-bg-slate-800/80 tw-px-3 tw-py-1 tw-rounded-lg tw-border tw-border-slate-700/60 tw-font-mono">
            5 Days • Sep 8–13
          </span>
        </div>

        <div class="tw-rounded-xl tw-border tw-border-slate-700/80 tw-bg-[#232a2a] tw-overflow-hidden tw-shadow-xl">
          <.accordion id="schedule_accordion">
            <:trigger>
              <div class="tw-flex tw-flex-wrap tw-items-center tw-justify-between tw-w-full tw-gap-2.5 tw-pr-2">
                <div class="tw-flex tw-items-center tw-gap-2.5">
                  <span class="tw-inline-flex tw-items-center tw-px-2 tw-py-0.5 tw-rounded-md tw-text-xs tw-font-bold tw-bg-sky-500/20 tw-text-sky-400 tw-border tw-border-sky-500/40">
                    Day 1
                  </span>
                  <span class="tw-text-sm tw-font-semibold tw-text-white">
                    (A–B) Initial & Winner matches
                  </span>
                </div>
                <div class="tw-flex tw-items-center tw-gap-2.5">
                  <span class="tw-hidden sm:tw-inline-flex tw-items-center tw-px-2 tw-py-0.5 tw-rounded-md tw-text-[11px] tw-font-medium tw-bg-slate-800 tw-text-slate-400 tw-border tw-border-slate-700/60">
                    6 Matches
                  </span>
                  <span class="tw-inline-flex tw-items-center tw-gap-1.5 tw-text-xs tw-font-medium tw-text-slate-300 tw-bg-slate-800/90 tw-px-2.5 tw-py-1 tw-rounded-md tw-border tw-border-slate-700/60">
                    <svg class="tw-w-3.5 tw-h-3.5 tw-text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
                    </svg>
                    <Helper.datetime datetime={~N[2026-09-08 16:00:00]} />
                  </span>
                </div>
              </div>
            </:trigger>
            <:panel>
              <.schedule_panel_content
                stage="Group Stage • Groups A & B"
                desc="Initial and Winners' matches for Group A and Group B. Winners advane to the Quarterfinals at BlizzCon on Saturday."
              />
            </:panel>

            <:trigger>
              <div class="tw-flex tw-flex-wrap tw-items-center tw-justify-between tw-w-full tw-gap-2.5 tw-pr-2">
                <div class="tw-flex tw-items-center tw-gap-2.5">
                  <span class="tw-inline-flex tw-items-center tw-px-2 tw-py-0.5 tw-rounded-md tw-text-xs tw-font-bold tw-bg-sky-500/20 tw-text-sky-400 tw-border tw-border-sky-500/40">
                    Day 2
                  </span>
                  <span class="tw-text-sm tw-font-semibold tw-text-white">
                    (C–D) Initial & Winner matches
                  </span>
                </div>
                <div class="tw-flex tw-items-center tw-gap-2.5">
                  <span class="tw-hidden sm:tw-inline-flex tw-items-center tw-px-2 tw-py-0.5 tw-rounded-md tw-text-[11px] tw-font-medium tw-bg-slate-800 tw-text-slate-400 tw-border tw-border-slate-700/60">
                    6 Matches
                  </span>
                  <span class="tw-inline-flex tw-items-center tw-gap-1.5 tw-text-xs tw-font-medium tw-text-slate-300 tw-bg-slate-800/90 tw-px-2.5 tw-py-1 tw-rounded-md tw-border tw-border-slate-700/60">
                    <svg class="tw-w-3.5 tw-h-3.5 tw-text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
                    </svg>
                    <Helper.datetime datetime={~N[2026-09-09 16:00:00]} />
                  </span>
                </div>
              </div>
            </:trigger>
            <:panel>
              <.schedule_panel_content
                stage="Group Stage • Groups C & D"
                desc="Initial and Winners' matches for Group C and Group D. Winners advance to the Quarterfinals at BlizzCon on Saturday."
              />
            </:panel>

            <:trigger>
              <div class="tw-flex tw-flex-wrap tw-items-center tw-justify-between tw-w-full tw-gap-2.5 tw-pr-2">
                <div class="tw-flex tw-items-center tw-gap-2.5">
                  <span class="tw-inline-flex tw-items-center tw-px-2 tw-py-0.5 tw-rounded-md tw-text-xs tw-font-bold tw-bg-sky-500/20 tw-text-sky-400 tw-border tw-border-sky-500/40">
                    Day 3
                  </span>
                  <span class="tw-text-sm tw-font-semibold tw-text-white">
                     Elimination & Decider matches
                  </span>
                </div>
                <div class="tw-flex tw-items-center tw-gap-2.5">
                  <span class="tw-hidden sm:tw-inline-flex tw-items-center tw-px-2 tw-py-0.5 tw-rounded-md tw-text-[11px] tw-font-medium tw-bg-slate-800 tw-text-slate-400 tw-border tw-border-slate-700/60">
                    8 Matches
                  </span>
                  <span class="tw-inline-flex tw-items-center tw-gap-1.5 tw-text-xs tw-font-medium tw-text-slate-300 tw-bg-slate-800/90 tw-px-2.5 tw-py-1 tw-rounded-md tw-border tw-border-slate-700/60">
                    <svg class="tw-w-3.5 tw-h-3.5 tw-text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
                    </svg>
                    <Helper.datetime datetime={~N[2026-09-10 16:00:00]} />
                  </span>
                </div>
              </div>
            </:trigger>
            <:panel>
              <.schedule_panel_content
                stage="Group Stage • Groups A through D"
                desc="Each match somebody gets eliminated!"
              />
            </:panel>

            <:trigger>
              <div class="tw-flex tw-flex-wrap tw-items-center tw-justify-between tw-w-full tw-gap-2.5 tw-pr-2">
                <div class="tw-flex tw-items-center tw-gap-2.5">
                  <span class="tw-inline-flex tw-items-center tw-px-2 tw-py-0.5 tw-rounded-md tw-text-xs tw-font-bold tw-bg-amber-500/20 tw-text-amber-400 tw-border tw-border-amber-500/40">
                    Day 4
                  </span>
                  <span class="tw-text-sm tw-font-semibold tw-text-white">
                    Quarterfinals
                  </span>
                </div>
                <div class="tw-flex tw-items-center tw-gap-2.5">
                  <span class="tw-hidden sm:tw-inline-flex tw-items-center tw-px-2 tw-py-0.5 tw-rounded-md tw-text-[11px] tw-font-medium tw-bg-slate-800 tw-text-slate-400 tw-border tw-border-slate-700/60">
                    4 Matches
                  </span>
                  <span class="tw-inline-flex tw-items-center tw-gap-1.5 tw-text-xs tw-font-medium tw-text-slate-300 tw-bg-slate-800/90 tw-px-2.5 tw-py-1 tw-rounded-md tw-border tw-border-slate-700/60">
                    <svg class="tw-w-3.5 tw-h-3.5 tw-text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
                    </svg>
                    <Helper.datetime datetime={~N[2026-09-12 19:00:00]} />
                  </span>
                </div>
              </div>
            </:trigger>
            <:panel>
              <.schedule_panel_content
                stage="Knockout Stage • Live at BlizzCon"
                desc="Back at Blizzcon! Who is making the final day and who is going home?"
              />
            </:panel>

            <:trigger>
              <div class="tw-flex tw-flex-wrap tw-items-center tw-justify-between tw-w-full tw-gap-2.5 tw-pr-2">
                <div class="tw-flex tw-items-center tw-gap-2.5">
                  <span class="tw-inline-flex tw-items-center tw-px-2 tw-py-0.5 tw-rounded-md tw-text-xs tw-font-bold tw-bg-emerald-500/20 tw-text-emerald-400 tw-border tw-border-emerald-500/40">
                    Day 5
                  </span>
                  <span class="tw-text-sm tw-font-semibold tw-text-white">
                    Semifinals & Grand Finals
                  </span>
                </div>
                <div class="tw-flex tw-items-center tw-gap-2.5">
                  <span class="tw-hidden sm:tw-inline-flex tw-items-center tw-px-2 tw-py-0.5 tw-rounded-md tw-text-[11px] tw-font-medium tw-bg-slate-800 tw-text-slate-400 tw-border tw-border-slate-700/60">
                    3 Matches
                  </span>
                  <span class="tw-inline-flex tw-items-center tw-gap-1.5 tw-text-xs tw-font-medium tw-text-slate-300 tw-bg-slate-800/90 tw-px-2.5 tw-py-1 tw-rounded-md tw-border tw-border-slate-700/60">
                    <svg class="tw-w-3.5 tw-h-3.5 tw-text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
                    </svg>
                    <Helper.datetime datetime={~N[2026-09-13 16:30:00]} />
                  </span>
                </div>
              </div>
            </:trigger>
            <:panel>
              <.schedule_panel_content
                stage="Championship Sunday • Live at BlizzCon"
                desc="Who will be crowned World Champion!"
              />
            </:panel>
          </.accordion>
        </div>
      </div>

      <!-- Lineup Explorer Section -->
      <div class="tw-space-y-4">
        <div :if={@has_lineups?} class="tw-space-y-3">
          <div>
            <h2 class="tw-text-xl tw-font-bold tw-text-white tw-tracking-tight">Tournament Lineups</h2>
          </div>
          <TournamentLineupExplorer id={"wc_2026_lineups"} tournament_id={"wc_2026"} tournament_source={"hsesports"} />
        </div>

        <div :if={!@has_lineups?} class="tw-rounded-2xl tw-border tw-border-slate-700/80 tw-bg-[#232a2a] tw-p-6 tw-shadow-xl tw-flex tw-flex-col sm:tw-flex-row sm:tw-items-center tw-gap-4">
          <div class="tw-p-3 tw-rounded-xl tw-bg-sky-500/10 tw-text-sky-400 tw-border tw-border-sky-500/20 tw-shrink-0">
            <svg class="tw-w-6 tw-h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/>
            </svg>
          </div>
          <div class="tw-space-y-1 tw-flex-1">
            <div class="tw-flex tw-items-center tw-gap-2">
              <h3 class="tw-text-base tw-font-bold tw-text-white">Tournament Lineups</h3>
              <span class="tw-text-[11px] tw-font-semibold tw-px-2 tw-py-0.5 tw-rounded-full tw-bg-slate-800 tw-text-slate-400 tw-border tw-border-slate-700">
                Awaiting Submission Deadline
              </span>
            </div>
            <p class="tw-text-sm tw-text-slate-300">
              Lineups will become available here shortly after the submission deadline
            </p>
          </div>
        </div>
      </div>

      <!-- Players Section -->
      <div class="tw-space-y-4">
        <div class="tw-flex tw-flex-col sm:tw-flex-row sm:tw-items-center sm:tw-justify-between tw-gap-3">
          <div>
            <h2 class="tw-text-xl tw-font-bold tw-text-white tw-tracking-tight">The 16 Competitors</h2>
          </div>

          <!-- Group Filter Tabs -->
          <div class="tw-flex tw-items-center tw-gap-1.5 tw-bg-[#232a2a] tw-p-1 tw-rounded-xl tw-border tw-border-slate-700/80">
            <button
              type="button"
              x-on:click="activeGroup = 'all'"
              x-bind:class="activeGroup === 'all' ? 'tw-bg-sky-600 tw-text-white tw-shadow-sm' : 'tw-text-slate-400 hover:tw-text-slate-200'"
              class="tw-px-3 tw-py-1 tw-rounded-lg tw-text-xs tw-font-semibold tw-transition-colors"
            >
              All (16)
            </button>
            <button
              type="button"
              x-on:click="activeGroup = 'A'"
              x-bind:class="activeGroup === 'A' ? 'tw-bg-sky-600 tw-text-white tw-shadow-sm' : 'tw-text-slate-400 hover:tw-text-slate-200'"
              class="tw-px-3 tw-py-1 tw-rounded-lg tw-text-xs tw-font-semibold tw-transition-colors"
            >
              Group A
            </button>
            <button
              type="button"
              x-on:click="activeGroup = 'B'"
              x-bind:class="activeGroup === 'B' ? 'tw-bg-sky-600 tw-text-white tw-shadow-sm' : 'tw-text-slate-400 hover:tw-text-slate-200'"
              class="tw-px-3 tw-py-1 tw-rounded-lg tw-text-xs tw-font-semibold tw-transition-colors"
            >
              Group B
            </button>
            <button
              type="button"
              x-on:click="activeGroup = 'C'"
              x-bind:class="activeGroup === 'C' ? 'tw-bg-sky-600 tw-text-white tw-shadow-sm' : 'tw-text-slate-400 hover:tw-text-slate-200'"
              class="tw-px-3 tw-py-1 tw-rounded-lg tw-text-xs tw-font-semibold tw-transition-colors"
            >
              Group C
            </button>
            <button
              type="button"
              x-on:click="activeGroup = 'D'"
              x-bind:class="activeGroup === 'D' ? 'tw-bg-sky-600 tw-text-white tw-shadow-sm' : 'tw-text-slate-400 hover:tw-text-slate-200'"
              class="tw-px-3 tw-py-1 tw-rounded-lg tw-text-xs tw-font-semibold tw-transition-colors"
            >
              Group D
            </button>
          </div>
        </div>

        <!-- Group Player Cards -->
        <div class="tw-space-y-6">
          <div
            :for={group <- @groups}
            x-show={"activeGroup === 'all' || activeGroup === '#{group.id}'"}
            class="tw-space-y-3"
          >
            <div class="tw-flex tw-items-center tw-gap-2 tw-pt-2">
              <span class="tw-px-2.5 tw-py-1 tw-rounded-lg tw-text-xs tw-font-bold tw-bg-slate-800 tw-text-slate-200 tw-border tw-border-slate-700/80">
                {group.name}
              </span>
              <span class="tw-text-xs tw-text-slate-400">
                4-Player Double Elim Group • Click any player to enlarge 
              </span>
            </div>

            <div class="tw-grid tw-grid-cols-2 sm:tw-grid-cols-2 md:tw-grid-cols-4 tw-gap-4">
              <.player_card
                :for={player <- group.players}
                name={player.name}
                image={player.image}
                region={player.region}
                region_key={player.region_key}
                group={group.id}
                index={player.index}
              />
            </div>
          </div>
        </div>

      </div>
    </div>

    <!-- Image Lightbox Modal with Full Viewport Fit, Vertical Scroll & Swipe Support -->
      <div
        id="player-image-lightbox"
        x-show="selectedIndex !== null"
        x-cloak
        x-on:keydown.escape.window="close()"
        x-on:keydown.arrow-left.window="prev()"
        x-on:keydown.arrow-right.window="next()"
        class="tw-fixed tw-inset-0 !tw-m-0 !tw-top-0 !tw-left-0 !tw-right-0 !tw-bottom-0 tw-z-[100] tw-flex tw-flex-col tw-bg-black/95 tw-backdrop-blur-md"
        style="margin: 0 !important; top: 0 !important; left: 0 !important; right: 0 !important; bottom: 0 !important;"
        x-transition:enter="tw-transition tw-ease-out tw-duration-200"
        x-transition:enter-start="tw-opacity-0"
        x-transition:enter-end="tw-opacity-100"
        x-transition:leave="tw-transition tw-ease-in tw-duration-150"
        x-transition:leave-start="tw-opacity-100"
        x-transition:leave-end="tw-opacity-0"
        role="dialog"
        aria-modal="true"
        aria-labelledby="lightbox-title"
      >
        <!-- Top Bar / Header: Always pinned to top, flush at y=0 with 0 margin -->
        <div class="tw-w-full tw-shrink-0 tw-px-3 sm:tw-px-6 tw-py-2.5 sm:tw-py-3 tw-bg-[#1b2020] tw-border-b tw-border-slate-700/80 tw-flex tw-items-center tw-justify-between tw-gap-2 sm:tw-gap-3 tw-z-30 tw-shadow-md">
          <div class="tw-flex tw-items-center tw-gap-2 sm:tw-gap-3 tw-min-w-0">
            <span
              x-show="current()"
              x-text="'Group ' + (current() ? current().group : '')"
              class="tw-px-2.5 tw-py-0.5 tw-rounded-md tw-text-xs tw-font-bold tw-bg-slate-800 tw-text-slate-200 tw-border tw-border-slate-700 tw-shrink-0"
            ></span>
            <h3
              id="lightbox-title"
              x-text="current() ? current().name : ''"
              class="tw-text-sm sm:tw-text-base md:tw-text-lg tw-font-bold tw-text-white tw-tracking-wide tw-truncate"
            ></h3>
            <span
              x-show="current()"
              x-text="current() ? current().region : ''"
              x-bind:class="regionClass()"
              class="tw-hidden sm:tw-inline-flex tw-px-2 tw-py-0.5 tw-rounded-md tw-text-xs tw-font-semibold tw-border tw-shrink-0"
            ></span>
            <span
              x-text="(selectedIndex !== null ? (selectedIndex + 1) : 0) + ' / ' + players.length"
              class="tw-px-2 tw-py-0.5 tw-rounded-md tw-text-[11px] tw-font-mono tw-text-slate-300 tw-bg-slate-800 tw-border tw-border-slate-700 tw-shrink-0"
              title="Player index in tournament"
            ></span>
          </div>

          <div class="tw-flex tw-items-center tw-gap-1.5 sm:tw-gap-2.5 tw-shrink-0">
            <!-- Previous / Next compact buttons in header -->
            <div class="tw-flex tw-items-center tw-bg-slate-800 tw-rounded-lg tw-border tw-border-slate-700/80 tw-p-0.5">
              <button
                type="button"
                x-on:click="prev()"
                class="tw-p-1.5 tw-rounded-md hover:tw-bg-slate-700 tw-text-slate-300 hover:tw-text-white tw-transition-colors"
                title="Previous player (Left Arrow / Swipe Right)"
                aria-label="Previous player"
              >
                <svg class="tw-w-4 tw-h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M15 19l-7-7 7-7"/>
                </svg>
              </button>
              <div class="tw-w-px tw-h-4 tw-bg-slate-700"></div>
              <button
                type="button"
                x-on:click="next()"
                class="tw-p-1.5 tw-rounded-md hover:tw-bg-slate-700 tw-text-slate-300 hover:tw-text-white tw-transition-colors"
                title="Next player (Right Arrow / Swipe Left)"
                aria-label="Next player"
              >
                <svg class="tw-w-4 tw-h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 5l7 7-7 7"/>
                </svg>
              </button>
            </div>

            <!-- View Mode Toggle: Zoom to Read vs Fit Screen -->
            <button
              type="button"
              x-on:click="toggleZoom()"
              class="tw-inline-flex tw-items-center tw-gap-1.5 tw-px-2.5 tw-py-1.5 tw-rounded-lg tw-text-xs tw-font-medium tw-bg-slate-800 hover:tw-bg-slate-700 tw-text-slate-300 hover:tw-text-white tw-border tw-border-slate-700/80 tw-transition-colors"
              x-bind:title="zoomMode ? 'Fit graphic to window (click or tap image to zoom out)' : 'Zoom in for large readable text (click or tap image to zoom in)'"
            >
              <template x-if="zoomMode">
                <span class="tw-flex tw-items-center tw-gap-1">
                  <svg class="tw-w-3.5 tw-h-3.5 tw-text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 8V4m0 0h4M4 4l5 5m11-1V4m0 0h-4m4 0l-5 5M4 16v4m0 0h4m-4 0l5-5m11 5l-5-5m5 5v-4m0 4h-4"/>
                  </svg>
                  <span class="tw-hidden sm:tw-inline">Fit Screen</span>
                </span>
              </template>
              <template x-if="!zoomMode">
                <span class="tw-flex tw-items-center tw-gap-1">
                  <svg class="tw-w-3.5 tw-h-3.5 tw-text-sky-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0zM10 7v3m0 0v3m0-3h3m-3 0H7"/>
                  </svg>
                  <span class="tw-hidden sm:tw-inline">Zoom to Read</span>
                </span>
              </template>
            </button>

            <a
              x-bind:href="current() ? ('/images/worlds_2026/' + current().image + '.jpg') : '#'"
              target="_blank"
              rel="noopener noreferrer"
              class="tw-inline-flex tw-items-center tw-gap-1 tw-px-2.5 tw-py-1.5 tw-rounded-lg tw-text-xs tw-font-medium tw-text-slate-300 hover:tw-text-white tw-bg-slate-800 hover:tw-bg-slate-700 tw-border tw-border-slate-700/80 tw-transition-colors"
              title="Open original 1080x1080 graphic in new tab"
            >
              <span class="tw-hidden xs:tw-inline">Full Res</span>
              <HeroIcons.external_link class="tw-w-3 tw-h-3 tw-text-slate-400" />
            </a>

            <button
              type="button"
              x-on:click="close()"
              class="tw-p-1.5 tw-rounded-lg tw-bg-slate-800 hover:tw-bg-rose-950/80 hover:tw-border-rose-700 tw-text-slate-300 hover:tw-text-rose-200 tw-border tw-border-slate-700/80 tw-transition-colors"
              aria-label="Close image preview (Escape)"
              title="Close (Esc)"
            >
              <svg class="tw-w-5 tw-h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
              </svg>
            </button>
          </div>
        </div>

        <!-- Main Scrollable Viewport Area: Allows scrolling through the entire graphic -->
        <div
          x-ref="scrollArea"
          class="tw-flex-1 tw-min-h-0 tw-w-full tw-overflow-y-auto tw-overscroll-contain tw-relative tw-touch-pan-y"
          x-on:touchstart="handleTouchStart($event)"
          x-on:touchend="handleTouchEnd($event)"
          x-on:click="close()"
        >
          <!-- Floating Desktop Prev Button (Fixed in viewport so it stays accessible while scrolling) -->
          <button
            type="button"
            x-on:click.stop="prev()"
            class="tw-hidden md:tw-flex tw-fixed tw-left-4 lg:tw-left-8 tw-top-1/2 -tw-translate-y-1/2 tw-z-40 tw-p-3.5 tw-rounded-full tw-bg-slate-900/90 hover:tw-bg-slate-800 tw-text-white tw-border tw-border-slate-700/80 tw-shadow-2xl hover:tw-scale-110 tw-transition-all"
            aria-label="Previous player"
            title="Previous player (Left Arrow)"
          >
            <svg class="tw-w-6 tw-h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M15 19l-7-7 7-7"/>
            </svg>
          </button>

          <!-- Floating Desktop Next Button (Fixed in viewport so it stays accessible while scrolling) -->
          <button
            type="button"
            x-on:click.stop="next()"
            class="tw-hidden md:tw-flex tw-fixed tw-right-4 lg:tw-right-8 tw-top-1/2 -tw-translate-y-1/2 tw-z-40 tw-p-3.5 tw-rounded-full tw-bg-slate-900/90 hover:tw-bg-slate-800 tw-text-white tw-border tw-border-slate-700/80 tw-shadow-2xl hover:tw-scale-110 tw-transition-all"
            aria-label="Next player"
            title="Next player (Right Arrow)"
          >
            <svg class="tw-w-6 tw-h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 5l7 7-7 7"/>
            </svg>
          </button>

          <!-- Centering Wrapper: Uses tw-my-auto to prevent flex overflow top-clipping bug -->
          <div class="tw-min-h-full tw-w-full tw-flex tw-flex-col tw-items-center tw-justify-center tw-p-3 sm:tw-p-6">
            <div
              class="tw-my-auto tw-relative tw-z-20 tw-flex tw-flex-col tw-items-center tw-transition-all tw-duration-200"
              x-on:click.stop
            >
              <img
                x-bind:src="current() ? ('/images/worlds_2026/' + current().image + '.jpg') : ''"
                x-bind:alt="current() ? current().name : ''"
                x-on:click="toggleZoom()"
                x-bind:class="zoomMode ? 'tw-w-full tw-max-w-2xl lg:tw-max-w-3xl tw-h-auto tw-cursor-zoom-out' : 'tw-max-h-[calc(100vh-130px)] tw-max-w-[calc(100vw-32px)] tw-w-auto tw-h-auto tw-cursor-zoom-in'"
                class="tw-object-contain tw-rounded-2xl tw-shadow-2xl tw-border tw-border-slate-700/80 tw-select-none"
              />

              <!-- Scroll indicator hint for large images in Zoom mode -->
              <div
                x-show="zoomMode"
                class="tw-mt-3 tw-flex tw-items-center tw-gap-1.5 tw-px-3 tw-py-1 tw-rounded-full tw-bg-slate-900/85 tw-border tw-border-slate-700/70 tw-text-[11px] tw-text-slate-300 tw-backdrop-blur-sm"
              >
                <svg class="tw-w-3.5 tw-h-3.5 tw-text-sky-400 tw-animate-bounce" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 14l-7 7m0 0l-7-7m7 7V3"/>
                </svg>
              </div>
            </div>
          </div>
        </div>

        <!-- Bottom Bar / Footer: Pinned at bottom, always visible -->
        <div class="tw-w-full tw-shrink-0 tw-px-4 sm:tw-px-6 tw-py-2 sm:tw-py-2.5 tw-bg-[#1b2020] tw-border-t tw-border-slate-700/80 tw-flex tw-items-center tw-justify-between tw-text-xs tw-text-slate-400 tw-z-30">
          <div class="tw-flex tw-items-center tw-gap-2">
            <span class="tw-hidden sm:tw-inline-flex tw-items-center tw-gap-1.5">
              <kbd class="tw-px-1.5 tw-py-0.5 tw-rounded tw-bg-slate-800 tw-text-[10px] tw-font-mono tw-text-slate-300 tw-border tw-border-slate-700">←</kbd>
              <kbd class="tw-px-1.5 tw-py-0.5 tw-rounded tw-bg-slate-800 tw-text-[10px] tw-font-mono tw-text-slate-300 tw-border tw-border-slate-700">→</kbd>
              <span class="tw-text-slate-400">Previous / Next</span>
            </span>
            <span class="tw-hidden sm:tw-inline tw-text-slate-600">•</span>
            <span class="tw-hidden sm:tw-inline-flex tw-items-center tw-gap-1.5">
              <kbd class="tw-px-1.5 tw-py-0.5 tw-rounded tw-bg-slate-800 tw-text-[10px] tw-font-mono tw-text-slate-300 tw-border tw-border-slate-700">Esc</kbd>
              <span class="tw-text-slate-400">Close</span>
            </span>
            <span class="is-hidden-tablet tw-text-slate-400">Swipe left / right to change player</span>
          </div>
          <div class="tw-flex tw-items-center tw-gap-2">
            <span class="tw-text-[11px] tw-text-slate-400">Click outside or press Esc to close</span>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp assign_has_lineups(socket) do
    has_lineups = Backend.Hearthstone.has_lineups?("wc_2026", "hsesports")

    socket
    |> assign(has_lineups: has_lineups)
  end

  attr :stage, :string, required: true
  attr :desc, :string, required: true

  def schedule_panel_content(assigns) do
    ~H"""
    <div class="tw-space-y-3 tw-py-1">
      <div class="tw-flex tw-flex-wrap tw-items-center tw-justify-between tw-gap-2 tw-text-xs">
        <span class="tw-px-2.5 tw-py-1 tw-rounded-md tw-bg-slate-800 tw-text-slate-300 tw-border tw-border-slate-700/60 tw-font-semibold">
          {@stage}
        </span>
        <span class="tw-text-slate-400">
          Format: 4-deck, Best-of-5 Conquest (1 Ban)
        </span>
      </div>
      <p class="tw-text-sm tw-text-slate-300">
        {@desc}
      </p>
      <div class="tw-flex tw-items-center tw-gap-2 tw-text-xs tw-text-slate-400 tw-bg-slate-900/60 tw-p-3 tw-rounded-lg tw-border tw-border-slate-800">
        <svg class="tw-w-4 tw-h-4 tw-text-sky-400 tw-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
        </svg>
        <span>Individual match schedule will be added when that info is available</span>
      </div>
    </div>
    """
  end

  attr :name, :string, required: true
  attr :image, :string, required: true
  attr :region, :string, required: true
  attr :region_key, :atom, required: true
  attr :group, :string, required: true
  attr :index, :integer, required: true

  def player_card(assigns) do
    ~H"""
    <div
      role="button"
      tabindex="0"
      aria-label={"View #{@name} profile graphic"}
      title={"Click to enlarge #{@name} profile"}
      x-on:click={"open(#{@index})"}
      x-on:keydown.enter={"open(#{@index})"}
      x-on:keydown.space.prevent={"open(#{@index})"}
      class="tw-group tw-flex tw-flex-col tw-rounded-xl tw-border tw-border-slate-700/80 tw-bg-[#232a2a] tw-overflow-hidden tw-transition-all tw-duration-200 hover:tw-border-sky-500/70 hover:tw-shadow-xl hover:tw-scale-[1.02] tw-cursor-pointer focus:tw-outline-none focus:tw-ring-2 focus:tw-ring-sky-500/60"
    >
      <div class="tw-relative tw-aspect-square tw-w-full tw-overflow-hidden tw-bg-[#1b2020]">
        <img
          class="tw-w-full tw-h-full tw-object-cover tw-transition-transform tw-duration-300 group-hover:tw-scale-105"
          alt={@name}
          loading="lazy"
          src={"/images/worlds_2026/#{@image}.jpg"}
        />
        <div class="tw-absolute tw-inset-0 tw-bg-gradient-to-t tw-from-[#232a2a] tw-via-transparent tw-to-transparent tw-opacity-80"></div>
        <span class="tw-absolute tw-top-2.5 tw-right-2.5 tw-px-2 tw-py-0.5 tw-rounded-md tw-text-[11px] tw-font-bold tw-bg-slate-900/85 tw-text-slate-300 tw-backdrop-blur-sm tw-border tw-border-slate-700/70">
          Group {@group}
        </span>

        <!-- Hover / Touch Zoom Affordance Badge -->
        <div class="tw-absolute tw-bottom-2.5 tw-right-2.5 tw-flex tw-items-center tw-gap-1 tw-px-2 tw-py-0.5 tw-rounded-md tw-text-[11px] tw-font-medium tw-bg-slate-900/80 tw-text-sky-300 tw-backdrop-blur-sm tw-border tw-border-slate-700/70 group-hover:tw-bg-sky-600 group-hover:tw-text-white group-hover:tw-border-sky-400/60 tw-transition-all tw-duration-200">
          <svg class="tw-w-3.5 tw-h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0zM10 7v3m0 0v3m0-3h3m-3 0H7"/>
          </svg>
          <span class="tw-text-[10px] tw-font-semibold tw-tracking-wide">Enlarge</span>
        </div>
      </div>
      <div class="tw-p-3.5 tw-flex tw-flex-col tw-justify-between tw-flex-1 tw-gap-2">
        <div>
          <h4 class="tw-text-base tw-font-bold tw-text-white tw-truncate group-hover:tw-text-sky-300 tw-transition-colors">
            {@name}
          </h4>
        </div>
        <div class="tw-flex tw-items-center tw-justify-between">
          <span class={region_badge_classes(@region_key)}>
            {@region}
          </span>
          <span class="tw-text-[11px] tw-text-slate-500 tw-font-medium">
            Competitor
          </span>
        </div>
      </div>
    </div>
    """
  end

  defp region_badge_classes(:americas) do
    "tw-inline-flex tw-items-center tw-px-2 tw-py-0.5 tw-rounded-md tw-text-xs tw-font-semibold tw-bg-[color:--color-americas]/20 tw-text-[#3298dc] tw-border tw-border-[color:--color-americas]/40"
  end

  defp region_badge_classes(:europe) do
    "tw-inline-flex tw-items-center tw-px-2 tw-py-0.5 tw-rounded-md tw-text-xs tw-font-semibold tw-bg-[color:--color-europe]/25 tw-text-[#7faad8] tw-border tw-border-[color:--color-europe]/45"
  end

  defp region_badge_classes(:apac) do
    "tw-inline-flex tw-items-center tw-px-2 tw-py-0.5 tw-rounded-md tw-text-xs tw-font-semibold tw-bg-[color:--color-asia]/20 tw-text-[#2ecc71] tw-border tw-border-[color:--color-asia]/40"
  end

  defp region_badge_classes(:china) do
    "tw-inline-flex tw-items-center tw-px-2 tw-py-0.5 tw-rounded-md tw-text-xs tw-font-semibold tw-bg-[color:--color-china]/20 tw-text-[#f1b70e] tw-border tw-border-[color:--color-china]/40"
  end

  defp region_badge_classes(_) do
    "tw-inline-flex tw-items-center tw-px-2 tw-py-0.5 tw-rounded-md tw-text-xs tw-font-semibold tw-bg-slate-800 tw-text-slate-300 tw-border tw-border-slate-700"
  end

  attr :alt, :string, required: true
  attr :image_part, :string, default: nil

  def player_img(assigns) do
    ~H"""
    <div class="tw-group tw-relative tw-aspect-square tw-overflow-hidden tw-rounded-xl tw-border tw-border-slate-700/80 tw-bg-[#232a2a]">
      <img
        class="tw-w-full tw-h-full tw-object-cover tw-transition-transform tw-duration-300 group-hover:tw-scale-105"
        alt={@alt}
        loading="lazy"
        src={"/images/worlds_2026/#{@image_part || String.downcase(@alt)}.jpg"}
      />
    </div>
    """
  end

  def tbd(assigns) do
    ~H"""
    <div class="tw-flex tw-items-center tw-gap-3 tw-rounded-xl tw-p-4 tw-border tw-border-sky-500/20 tw-bg-[#1b2020] tw-text-slate-300">
      <div class="tw-text-sky-400">
        <svg class="tw-w-5 tw-h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
        </svg>
      </div>
      <div>
        <h4 class="tw-text-xs tw-font-bold tw-uppercase tw-tracking-wider tw-text-sky-400">Schedule TBD</h4>
        <p class="tw-text-xs tw-text-slate-400 tw-mt-0.5">The exact match schedule is To Be Determined.</p>
      </div>
    </div>
    """
  end

  @cyc_deadline ~N[2026-09-08 13:00:00]

  defp cyc_open?, do: Util.after_now?(@cyc_deadline)

  defp not_started?, do: Util.after_now?(~N[2026-09-08 16:00:00])

  defp assign_info_from_bracket_predictions(socket) do
    new_assigns =
      Backend.BracketPredictions.get_tournament(1)
      |> assigns_from_bracket_predictions()

    socket
    |> assign(new_assigns)
  end

  defp assigns_from_bracket_predictions(%Backend.BracketPredictions.Tournament{} = tournament) do
    [
      show_bracket_predictions?: tournament.status == "open",
      battlefy_id: tournament.battlefy_tournament_id
    ]
  end

  defp assigns_from_bracket_predictions(_) do
    [show_bracket_predictions?: false, battlefy_id: nil]
  end

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end

  def handle_event("deck_copied", _, socket), do: {:noreply, socket}
end
