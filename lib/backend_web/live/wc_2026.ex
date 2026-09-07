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
        %{name: "McBanterFace", image: "mcbanterface", region: "Americas", region_key: :americas},
        %{name: "Soyorin", image: "soyorin", region: "APAC", region_key: :apac},
        %{name: "mlYanming", image: "mlyanming", region: "China", region_key: :china},
        %{name: "hyosung", image: "hyosung", region: "APAC", region_key: :apac}
      ]
    },
    %{
      id: "B",
      name: "Group B",
      players: [
        %{name: "maxiebon1234", image: "maxiebon", region: "APAC", region_key: :apac},
        %{name: "WinBrownie", image: "winbrownie", region: "Americas", region_key: :americas},
        %{name: "XiaoT", image: "xiaot", region: "China", region_key: :china},
        %{name: "Fatty", image: "fatty", region: "Europe", region_key: :europe}
      ]
    },
    %{
      id: "C",
      name: "Group C",
      players: [
        %{name: "Gaby59", image: "gaby", region: "Europe", region_key: :europe},
        %{name: "Curfew", image: "curfew", region: "APAC", region_key: :apac},
        %{name: "Xiaobai", image: "xiaobai", region: "China", region_key: :china},
        %{name: "Kwanuu", image: "kwanuu", region: "APAC", region_key: :apac}
      ]
    },
    %{
      id: "D",
      name: "Group D",
      players: [
        %{name: "OTGxhh", image: "otgxhh", region: "China", region_key: :china},
        %{name: "Che0nsu", image: "che0nsu", region: "APAC", region_key: :apac},
        %{name: "SAVOR", image: "savor", region: "Europe", region_key: :europe},
        %{name: "Mesmile", image: "mesmile", region: "Americas", region_key: :americas}
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
          <div class="tw-space-y-2">
            <div class="tw-flex tw-items-center tw-gap-2">
              <span class="tw-inline-flex tw-items-center tw-gap-1 tw-px-2.5 tw-py-0.5 tw-rounded-full tw-text-xs tw-font-bold tw-uppercase tw-tracking-wider tw-bg-amber-500/15 tw-text-amber-400 tw-border tw-border-amber-500/30">
                <svg class="tw-w-3.5 tw-h-3.5" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
                </svg>
                Choose Your Champion
              </span>
              <span class="tw-text-xs tw-text-slate-400">Earn Card Packs</span>
            </div>
            <h2 class="tw-text-xl tw-font-bold tw-text-white tw-tracking-tight">
              Vote for Your Champion
            </h2>
            <p class="tw-text-sm tw-text-slate-300">
              Pick your favorite player to earn in-game <em>Escape from Violet Hold</em> packs based on their performance, plus a Golden pack if your pick wins the title!
            </p>
            <p :if={!@has_lineups?} class="tw-text-xs tw-text-amber-300/80 tw-flex tw-items-center tw-gap-1.5 tw-pt-1">
              <svg class="tw-w-4 tw-h-4 tw-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
              </svg>
              <span>Tip: You may want to wait for deck lineups to be published before locking in your pick!</span>
            </p>
          </div>
          <div>
            <a
              href="https://hearthstone.blizzard.com/vote/choose-your-champion"
              target="_blank"
              rel="noopener noreferrer"
              class="tw-inline-flex tw-items-center tw-gap-2 tw-px-4 tw-py-2 tw-rounded-xl tw-text-xs tw-font-bold tw-bg-amber-500 hover:tw-bg-amber-400 tw-text-slate-950 tw-shadow-lg tw-shadow-amber-500/20 tw-transition-all tw-duration-200 hover:tw-scale-[1.02]"
            >
              <span>Vote on hearthstone.blizzard.com</span>
              <HeroIcons.external_link class="tw-w-3.5 tw-h-3.5" />
            </a>
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
                    (A–D) Elimination & Decider matches
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
                stage="Group Stage • Groups A through D • 8 matches"
                desc="Each match somebody get's eliminated!"
              />
            </:panel>

            <:trigger>
              <div class="tw-flex tw-flex-wrap tw-items-center tw-justify-between tw-w-full tw-gap-2.5 tw-pr-2">
                <div class="tw-flex tw-items-center tw-gap-2.5">
                  <span class="tw-inline-flex tw-items-center tw-px-2 tw-py-0.5 tw-rounded-md tw-text-xs tw-font-bold tw-bg-amber-500/20 tw-text-amber-400 tw-border tw-border-amber-500/40">
                    Day 4
                  </span>
                  <span class="tw-text-sm tw-font-semibold tw-text-white">
                    (Top 8 Single Elimination)
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
                stage="Knockout Stage • Live at BlizzCon • 4 Matches"
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
                stage="Championship Sunday • Live at BlizzCon • 3 Matches"
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
            <h2 class="tw-text-xl tw-font-bold tw-text-white tw-tracking-tight">Deck Lineups</h2>
            <p class="tw-text-xs tw-text-slate-400">Inspect decks, archetypes, and copy deck codes for all competitors</p>
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
                Awaiting Deck Submission
              </span>
            </div>
            <p class="tw-text-sm tw-text-slate-300">
              Lineups will become available here shortly after submission
            </p>
          </div>
        </div>
      </div>

      <!-- Players Section -->
      <div class="tw-space-y-4" x-data="{ activeGroup: 'all' }">
        <div class="tw-flex tw-flex-col sm:tw-flex-row sm:tw-items-center sm:tw-justify-between tw-gap-3">
          <div>
            <h2 class="tw-text-xl tw-font-bold tw-text-white tw-tracking-tight">The 16 Competitors</h2>
            <p class="tw-text-xs tw-text-slate-400">Four groups of four world-class players fighting for the Championship</p>
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
            </div>

            <div class="tw-grid tw-grid-cols-2 sm:tw-grid-cols-2 md:tw-grid-cols-4 tw-gap-4">
              <.player_card
                :for={player <- group.players}
                name={player.name}
                image={player.image}
                region={player.region}
                region_key={player.region_key}
                group={group.id}
              />
            </div>
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
        <span>Individual match timing and broadcast running order will be added when that info is available</span>
      </div>
    </div>
    """
  end

  attr :name, :string, required: true
  attr :image, :string, required: true
  attr :region, :string, required: true
  attr :region_key, :atom, required: true
  attr :group, :string, required: true

  def player_card(assigns) do
    ~H"""
    <div class="tw-group tw-flex tw-flex-col tw-rounded-xl tw-border tw-border-slate-700/80 tw-bg-[#232a2a] tw-overflow-hidden tw-transition-all tw-duration-200 hover:tw-border-slate-500 hover:tw-shadow-xl hover:tw-scale-[1.02]">
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
