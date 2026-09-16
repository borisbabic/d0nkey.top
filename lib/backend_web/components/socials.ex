defmodule Components.Socials do
  @moduledoc "Social media linking components"
  use BackendWeb, :component

  defp live_indicator(assigns) do
    ~H"""
    <span class="tw-inline-flex tw-items-center tw-gap-1 tw-px-1.5 tw-py-0.5 tw-rounded tw-text-[8px] tw-uppercase tw-tracking-wider tw-bg-red-500/20 tw-text-red-400 tw-border tw-border-red-500/40">
      <span class="tw-relative tw-flex tw-h-1.5 tw-w-1.5">
        <span class="tw-animate-ping tw-absolute tw-inline-flex tw-h-full tw-w-full tw-rounded-full tw-bg-red-400 tw-opacity-75"></span>
        <span class="tw-relative tw-inline-flex tw-rounded-full tw-h-1.5 tw-w-1.5 tw-bg-red-500"></span>
      </span>
      Live
    </span>
    """
  end

  defp twitch_live?(assigns) do
    if is_nil(assigns[:live?]) do
      assigns[:channel] && Map.get(assigns, :show_live, true) &&
        Twitch.HearthstoneLive.twitch_display_live?(assigns[:channel])
    else
      assigns.live?
    end
  end

  attr :link, :string, default: nil
  attr :user, :string, default: nil
  attr :label, :string, default: nil
  attr :class, :string, default: nil
  attr :target, :string, default: "_blank"
  attr :rel, :string, default: "noopener noreferrer"

  def paypal(assigns) do
    ~H"""
    <a
      href={@link || (if @user, do: "https://paypal.me/#{@user}", else: "https://paypal.com")}
      target={@target}
      rel={@rel}
      aria-label="PayPal Donation"
      class={[
        "tw-inline-flex tw-items-center tw-gap-1.5 tw-px-3 tw-py-1.5 tw-rounded-lg tw-text-xs tw-font-semibold tw-border tw-transition-all tw-duration-150",
        "tw-bg-[#0079c1]/15 hover:tw-bg-[#0079c1]/25 tw-text-[#38bdf8] tw-border-[#0079c1]/40 hover:tw-border-[#0079c1]/60",
        @class
      ]}
    >
      <svg class="tw-w-3.5 tw-h-3.5 tw-fill-current tw-shrink-0" viewBox="0 0 384 512">
        <path d="M111.4 295.9c-3.5 19.2-17.4 108.7-21.5 134-.3 1.8-1 2.5-3 2.5H12.3c-7.6 0-13.1-6.6-12.1-13.9L58.8 46.6c1.5-9.6 10.1-16.9 20-16.9 152.3 0 165.1-3.7 204 11.4 60.1 23.3 65.6 79.5 44 140.3-21.5 62.6-72.5 89.5-140.1 90.3-43.4.7-69.5-7-75.3 24.2zM357.1 152c-1.8-1.3-2.5-1.8-3 1.3-2 11.4-5.1 22.5-8.8 33.6-39.9 113.8-150.5 103.9-204.5 103.9-6.1 0-10.1 3.3-10.9 9.4-22.6 140.4-27.1 169.7-27.1 169.7-1 7.1 3.5 12.9 10.6 12.9h63.5c8.6 0 15.7-6.3 17.4-14.9.7-5.4-1.1 6.1 14.4-91.3 4.6-22 14.3-19.7 29.3-19.7 71 0 126.4-28.8 142.9-112.3 6.5-34.8 4.6-71.4-23.8-92.6z"/>
      </svg>
      <span>{@label || "PayPal"}</span>
    </a>
    """
  end

  attr :link, :string, default: nil
  attr :server, :string, default: nil
  attr :label, :string, default: nil
  attr :class, :string, default: nil
  attr :target, :string, default: "_blank"
  attr :rel, :string, default: "noopener noreferrer"

  def discord(assigns) do
    ~H"""
    <a
      href={@link || (if @server, do: "https://discord.gg/#{@server}", else: "https://discord.com")}
      target={@target}
      rel={@rel}
      aria-label="Discord Community"
      class={[
        "tw-inline-flex tw-items-center tw-gap-1.5 tw-px-3 tw-py-1.5 tw-rounded-lg tw-text-xs tw-font-semibold tw-border tw-transition-all tw-duration-150",
        "tw-bg-[#5865F2]/15 hover:tw-bg-[#5865F2]/25 tw-text-[#9aa5f4] tw-border-[#5865F2]/40 hover:tw-border-[#5865F2]/60",
        @class
      ]}
    >
      <svg class="tw-w-3.5 tw-h-3.5 tw-fill-current tw-shrink-0" viewBox="0 0 448 512">
        <path d="M297.216 243.2c0 15.616-11.52 28.416-26.112 28.416-14.336 0-26.112-12.8-26.112-28.416s11.52-28.416 26.112-28.416c14.592 0 26.112 12.8 26.112 28.416zm-119.552-28.416c-14.592 0-26.112 12.8-26.112 28.416s11.776 28.416 26.112 28.416c14.592 0 26.112-12.8 26.112-28.416.256-15.616-11.52-28.416-26.112-28.416zM448 52.736V512c-64.494-56.994-43.868-38.128-118.784-107.776l13.568 47.36H52.48C23.552 451.584 0 428.032 0 398.848V52.736C0 23.552 23.552 0 52.48 0h343.04C424.448 0 448 23.552 448 52.736zm-72.96 242.688c0-82.432-36.864-149.248-36.864-149.248-36.864-27.648-71.936-26.88-71.936-26.88l-3.584 4.096c43.52 13.312 63.744 32.512 63.744 32.512-60.811-33.329-132.244-33.335-191.232-7.424-9.472 4.352-15.104 7.424-15.104 7.424s21.248-20.224 67.328-33.536l-2.56-3.072s-35.072-.768-71.936 26.88c0 0-36.864 66.816-36.864 149.248 0 0 21.504 37.12 78.08 38.912 0 0 9.472-11.52 17.152-21.248-32.512-9.728-44.8-30.208-44.8-30.208 3.766 2.636 9.976 6.053 10.496 6.4 43.21 24.198 104.588 32.126 159.744 8.96 8.96-3.328 18.944-8.192 29.44-15.104 0 0-12.8 20.992-46.336 30.464 7.68 9.728 16.896 20.736 16.896 20.736 56.576-1.792 78.336-38.912 78.336-38.912z"/>
      </svg>
      <span>{@label || "Discord"}</span>
    </a>
    """
  end

  def twitch(channel) when is_binary(channel) do
    twitch(%{channel: channel})
  end

  def twitch(assigns) when is_map(assigns) do
    defaults = %{
      link: nil,
      channel: nil,
      label: nil,
      show_live: true,
      live?: nil,
      height: nil,
      class: nil,
      target: "_blank",
      rel: "noopener noreferrer"
    }

    assigns =
      case assigns do
        %{__changed__: _} ->
          defaults
          |> Map.merge(assigns)
          |> assign(:live?, twitch_live?(assigns))

        _ ->
          defaults
          |> Map.merge(assigns)
          |> Map.put(:__changed__, nil)
          |> Map.put(:live?, twitch_live?(assigns))
      end

    ~H"""
    <a
      href={@link || "https://www.twitch.tv/#{@channel}"}
      target={@target}
      rel={@rel}
      aria-label={"Twitch Channel #{@channel || @label || "Twitch"}"}
      class={[
        "tw-inline-flex tw-items-center tw-gap-1.5 tw-px-3 tw-py-1.5 tw-rounded-lg tw-text-xs tw-font-semibold tw-border tw-transition-all tw-duration-150",
        "tw-bg-[#9146ff]/15 hover:tw-bg-[#9146ff]/25 tw-text-[#bf94ff] tw-border-[#9146ff]/40 hover:tw-border-[#9146ff]/60",
        @class
      ]}
    >
      <svg class="tw-w-3.5 tw-h-3.5 tw-fill-current tw-shrink-0" viewBox="0 0 24 24">
        <path d="M11.571 4.714h1.715v5.143H11.57zm4.715 0H18v5.143h-1.714zM6 0L1.714 4.286v15.428h5.143V24l4.286-4.286h3.428L22.286 12V0zm14.571 11.143l-3.428 3.428h-3.429l-3 3v-3H6.857V1.714h13.714z"/>
      </svg>
      <span>{@label || @channel || "Twitch"}</span>
      <.live_indicator :if={@live?} />
    </a>
    """
  end

  attr :link, :string, default: nil
  attr :channel, :string, default: nil
  attr :label, :string, default: nil
  attr :live?, :boolean, default: false
  attr :class, :string, default: nil
  attr :target, :string, default: "_blank"
  attr :rel, :string, default: "noopener noreferrer"

  def youtube(assigns) do
    ~H"""
    <a
      href={@link || "https://www.youtube.com/#{@channel}"}
      target={@target}
      rel={@rel}
      aria-label={"YouTube Channel #{@channel || @label || "YouTube"}"}
      class={[
        "tw-inline-flex tw-items-center tw-gap-1.5 tw-px-3 tw-py-1.5 tw-rounded-lg tw-text-xs tw-font-semibold tw-border tw-transition-all tw-duration-150",
        "tw-bg-red-950/40 hover:tw-bg-red-900/40 tw-text-red-300 tw-border-red-700/50 hover:tw-border-red-600/60",
        @class
      ]}
    >
      <svg class="tw-w-3.5 tw-h-3.5 tw-fill-current tw-shrink-0" viewBox="0 0 24 24">
        <path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z"/>
      </svg>
      <span>{@label || @channel || "YouTube"}</span>
      <.live_indicator :if={@live?} />
    </a>
    """
  end

  attr :link, :string, default: nil
  attr :creator, :string, default: nil
  attr :label, :string, default: nil
  attr :class, :string, default: nil
  attr :target, :string, default: "_blank"
  attr :rel, :string, default: "noopener noreferrer"

  def patreon(assigns) do
    ~H"""
    <a
      href={@link || (if @creator, do: "https://www.patreon.com/#{@creator}", else: "https://www.patreon.com")}
      target={@target}
      rel={@rel}
      aria-label="Patreon"
      class={[
        "tw-inline-flex tw-items-center tw-gap-1.5 tw-px-3 tw-py-1.5 tw-rounded-lg tw-text-xs tw-font-semibold tw-border tw-transition-all tw-duration-150",
        "tw-bg-[#ff424d]/15 hover:tw-bg-[#ff424d]/25 tw-text-[#ff8a90] tw-border-[#ff424d]/40 hover:tw-border-[#ff424d]/60",
        @class
      ]}
    >
      <svg class="tw-w-3.5 tw-h-3.5 tw-fill-current tw-shrink-0" viewBox="0 0 512 512">
        <path d="M512 194.8c0 101.3-82.4 183.8-183.8 183.8-101.7 0-184.4-82.4-184.4-183.8 0-101.6 82.7-184.3 184.4-184.3C429.6 10.5 512 93.2 512 194.8zM0 501.5h90v-491H0v491z"/>
      </svg>
      <span>{@label || "Patreon"}</span>
    </a>
    """
  end

  def patreon_image(assigns) do
    ~H"""
    <img style="height: 30px;" class="image" alt="Patreon" src="/images/brands/patreon_wordmark_fierycoral.png" />
    """
  end

  attr :tag, :string, default: nil
  attr :link, :string, default: nil
  attr :label, :string, default: nil
  attr :class, :string, default: nil
  attr :target, :string, default: "_blank"
  attr :rel, :string, default: "noopener noreferrer"

  def x(assigns) do
    ~H"""
    <a
      href={@link || (if @tag, do: "https://x.com/#{@tag}", else: "https://x.com")}
      target={@target}
      rel={@rel}
      aria-label={"X #{@tag || @label || ""}"}
      class={[
        "tw-inline-flex tw-items-center tw-gap-1.5 tw-px-3 tw-py-1.5 tw-rounded-lg tw-text-xs tw-font-semibold tw-border tw-transition-all tw-duration-150",
        "tw-bg-slate-800/60 hover:tw-bg-slate-700/60 tw-text-slate-200 tw-border-slate-700/70 hover:tw-border-slate-600/80",
        @class
      ]}
    >
      <svg class="tw-w-3.5 tw-h-3.5 tw-fill-current tw-shrink-0" viewBox="0 0 24 24">
        <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/>
      </svg>
      <span>{@label || (if @tag, do: "@#{@tag}", else: "X")}</span>
    </a>
    """
  end

  def twitter(assigns), do: x(assigns)

  attr :link, :string, default: nil
  attr :handle, :string, default: nil
  attr :label, :string, default: nil
  attr :class, :string, default: nil
  attr :target, :string, default: "_blank"
  attr :rel, :string, default: "noopener noreferrer"

  def bluesky(assigns) do
    ~H"""
    <a
      href={@link || (if @handle, do: "https://bsky.app/profile/#{ensure_bluesky_domain(@handle)}", else: "https://bsky.app")}
      target={@target}
      rel={@rel}
      aria-label={"Bluesky #{@handle || @label || ""}"}
      class={[
        "tw-inline-flex tw-items-center tw-gap-1.5 tw-px-3 tw-py-1.5 tw-rounded-lg tw-text-xs tw-font-semibold tw-border tw-transition-all tw-duration-150",
        "tw-bg-[#0285ff]/15 hover:tw-bg-[#0285ff]/25 tw-text-[#60a5fa] tw-border-[#0285ff]/40 hover:tw-border-[#0285ff]/60",
        @class
      ]}
    >
      <svg class="tw-w-3.5 tw-h-3.5 tw-fill-current tw-shrink-0" viewBox="0 0 568 501">
        <path d="M123.121 33.664C188.241 82.553 258.281 181.68 284 234.873c25.719-53.192 95.759-152.32 160.879-201.21C491.866-1.611 568-28.906 568 57.947c0 17.346-9.945 145.713-15.778 166.555-20.275 72.453-94.155 90.933-159.875 79.748C507.222 323.8 536.444 388.56 473.333 453.32c-119.86 122.992-172.272-30.859-185.702-70.281-2.462-7.227-3.614-10.608-3.631-7.733-.017-2.875-1.169.506-3.631 7.733-13.43 39.422-65.842 193.273-185.702 70.281-63.111-64.76-33.89-129.52 80.986-149.071-65.72 11.185-139.6-7.295-159.875-79.748C9.945 203.659 0 75.291 0 57.946 0-28.906 76.135-1.612 123.121 33.664Z"/>
      </svg>
      <span>{@label || (if @handle, do: "@#{@handle}", else: "Bluesky")}</span>
    </a>
    """
  end

  defp ensure_bluesky_domain(handle) do
    if String.contains?(handle, ".") do
      handle
    else
      handle <> ".bsky.social"
    end
  end

  attr :link, :string, default: nil
  attr :channel, :string, default: nil
  attr :label, :string, default: nil
  attr :live?, :boolean, default: false
  attr :class, :string, default: nil
  attr :target, :string, default: "_blank"
  attr :rel, :string, default: "noopener noreferrer"

  def tiktok(assigns) do
    ~H"""
    <a
      href={@link || (if @channel, do: "https://www.tiktok.com/@#{@channel}", else: "https://www.tiktok.com")}
      target={@target}
      rel={@rel}
      aria-label={"TikTok #{@channel || @label || ""}"}
      class={[
        "tw-inline-flex tw-items-center tw-gap-1.5 tw-px-3 tw-py-1.5 tw-rounded-lg tw-text-xs tw-font-semibold tw-border tw-transition-all tw-duration-150",
        "tw-bg-[#fe2c55]/15 hover:tw-bg-[#fe2c55]/25 tw-text-[#ff6b8b] tw-border-[#fe2c55]/40 hover:tw-border-[#fe2c55]/60",
        @class
      ]}
    >
      <svg class="tw-w-3.5 tw-h-3.5 tw-fill-current tw-shrink-0" viewBox="0 0 448 512">
        <path d="M448,209.91a210.06,210.06,0,0,1-122.77-39.25V349.38A162.55,162.55,0,1,1,185,188.31V278.2a74.62,74.62,0,1,0,52.23,71.18V0l88,0a121.18,121.18,0,0,0,1.86,22.17h0A122.18,122.18,0,0,0,381,102.39a121.43,121.43,0,0,0,67,20.14Z"/>
      </svg>
      <span>{@label || (if @channel, do: "@#{@channel}", else: "TikTok")}</span>
      <.live_indicator :if={@live?} />
    </a>
    """
  end

  attr :link, :string, default: nil
  attr :channel, :string, default: nil
  attr :label, :string, default: nil
  attr :live?, :boolean, default: false
  attr :class, :string, default: nil
  attr :target, :string, default: "_blank"
  attr :rel, :string, default: "noopener noreferrer"

  def kick(assigns) do
    ~H"""
    <a
      href={@link || (if @channel, do: "https://kick.com/#{@channel}", else: "https://kick.com")}
      target={@target}
      rel={@rel}
      aria-label={"Kick Channel #{@channel || @label || "Kick"}"}
      class={[
        "tw-inline-flex tw-items-center tw-gap-1.5 tw-px-3 tw-py-1.5 tw-rounded-lg tw-text-xs tw-font-semibold tw-border tw-transition-all tw-duration-150",
        "tw-bg-[#53FC18]/15 hover:tw-bg-[#53FC18]/25 tw-text-[#53FC18] tw-border-[#53FC18]/40 hover:tw-border-[#53FC18]/60",
        @class
      ]}
    >
      <svg class="tw-w-3.5 tw-h-3.5 tw-fill-current tw-shrink-0" viewBox="0 0 24 24">
        <path d="M3 0h6v6h3V3h3V1.5h3V0h5v7h-3v2h-3v3h3v2h3v8h-5v-1.5h-3V19h-3v-3H9v8H3V0z"/>
      </svg>
      <span>{@label || @channel || "Kick"}</span>
      <.live_indicator :if={@live?} />
    </a>
    """
  end

  attr :link, :string, default: nil
  attr :channel, :string, default: nil
  attr :label, :string, default: nil
  attr :live?, :boolean, default: false
  attr :class, :string, default: nil
  attr :target, :string, default: "_blank"
  attr :rel, :string, default: "noopener noreferrer"

  def instagram(assigns) do
    ~H"""
    <a
      href={@link || (if @channel, do: "https://www.instagram.com/#{@channel}", else: "https://www.instagram.com")}
      target={@target}
      rel={@rel}
      aria-label={"Instagram #{@channel || @label || ""}"}
      class={[
        "tw-inline-flex tw-items-center tw-gap-1.5 tw-px-3 tw-py-1.5 tw-rounded-lg tw-text-xs tw-font-semibold tw-border tw-transition-all tw-duration-150",
        "tw-bg-[#e4405f]/15 hover:tw-bg-[#e4405f]/25 tw-text-[#f472b6] tw-border-[#e4405f]/40 hover:tw-border-[#e4405f]/60",
        @class
      ]}
    >
      <svg class="tw-w-3.5 tw-h-3.5 tw-fill-current tw-shrink-0" viewBox="0 0 448 512">
        <path d="M224.1 141c-63.6 0-114.9 51.3-114.9 114.9s51.3 114.9 114.9 114.9S339 319.5 339 255.9 287.7 141 224.1 141zm0 189.6c-41.1 0-74.7-33.5-74.7-74.7s33.5-74.7 74.7-74.7 74.7 33.5 74.7 74.7-33.6 74.7-74.7 74.7zm146.4-194.3c0 14.9-12 26.8-26.8 26.8-14.9 0-26.8-12-26.8-26.8s12-26.8 26.8-26.8 26.8 12 26.8 26.8zm76.1 27.2c-1.7-35.9-9.9-67.7-36.2-93.9-26.2-26.2-58-34.4-93.9-36.2-37-2.1-147.9-2.1-184.9 0-35.8 1.7-67.6 9.9-93.9 36.1s-34.4 58-36.2 93.9c-2.1 37-2.1 147.9 0 184.9 1.7 35.9 9.9 67.7 36.2 93.9s58 34.4 93.9 36.2c37 2.1 147.9 2.1 184.9 0 35.9-1.7 67.7-9.9 93.9-36.2 26.2-26.2 34.4-58 36.2-93.9 2.1-37 2.1-147.8 0-184.8zM398.8 388c-7.8 19.6-22.9 34.7-42.6 42.6-29.5 11.7-99.5 9-132.1 9s-102.7 2.6-132.1-9c-19.6-7.8-34.7-22.9-42.6-42.6-11.7-29.5-9-99.5-9-132.1s-2.6-102.7 9-132.1c7.8-19.6 22.9-34.7 42.6-42.6 29.5-11.7 99.5-9 132.1-9s102.7-2.6 132.1 9c19.6 7.8 34.7 22.9 42.6 42.6 11.7 29.5 9 99.5 9 132.1z"/>
      </svg>
      <span>{@label || (if @channel, do: "@#{@channel}", else: "Instagram")}</span>
      <.live_indicator :if={@live?} />
    </a>
    """
  end

  attr :link, :string, default: nil
  attr :subreddit, :string, default: nil
  attr :user, :string, default: nil
  attr :label, :string, default: nil
  attr :class, :string, default: nil
  attr :target, :string, default: "_blank"
  attr :rel, :string, default: "noopener noreferrer"

  def reddit(assigns) do
    ~H"""
    <a
      href={
        @link ||
          cond do
            @subreddit -> "https://www.reddit.com/r/#{@subreddit}"
            @user -> "https://www.reddit.com/u/#{@user}"
            true -> "https://www.reddit.com"
          end
      }
      target={@target}
      rel={@rel}
      aria-label="Reddit"
      class={[
        "tw-inline-flex tw-items-center tw-gap-1.5 tw-px-3 tw-py-1.5 tw-rounded-lg tw-text-xs tw-font-semibold tw-border tw-transition-all tw-duration-150",
        "tw-bg-[#ff4500]/15 hover:tw-bg-[#ff4500]/25 tw-text-[#ff8053] tw-border-[#ff4500]/40 hover:tw-border-[#ff4500]/60",
        @class
      ]}
    >
      <svg class="tw-w-3.5 tw-h-3.5 tw-fill-current tw-shrink-0" viewBox="0 0 512 512">
        <path d="M201.5 305.5c-13.8 0-24.9-11.1-24.9-24.6 0-13.8 11.1-24.9 24.9-24.9 13.6 0 24.6 11.1 24.6 24.9 0 13.6-11.1 24.6-24.6 24.6zM504 256c0 137-111 248-248 248S8 393 8 256 119 8 256 8s248 111 248 248zm-132.3-41.2c-9.4 0-17.7 3.9-23.8 10-22.4-15.5-52.6-25.5-86.1-26.6l17.4-78.3 55.4 12.5c0 13.6 11.1 24.6 24.6 24.6 13.8 0 24.9-11.3 24.9-24.9s-11.1-24.9-24.9-24.9c-9.7 0-18 5.8-22.1 13.8l-61.2-13.6c-3-.8-6.1 1.4-6.9 4.4l-19.1 86.4c-33.2 1.4-63.1 11.3-85.5 26.8-6.1-6.4-14.7-10.2-24.1-10.2-34.9 0-46.3 46.9-14.4 62.8-1.1 5-1.7 10.2-1.7 15.5 0 52.6 59.2 95.2 132 95.2 73.1 0 132.3-42.6 132.3-95.2 0-5.3-.6-10.8-1.9-15.8 31.3-16 19.8-62.5-14.9-62.5zM302.8 331c-18.2 18.2-76.1 17.9-93.6 0-2.2-2.2-6.1-2.2-8.3 0-2.5 2.5-2.5 6.4 0 8.6 22.8 22.8 87.3 22.8 110.2 0 2.5-2.2 2.5-6.1 0-8.6-2.2-2.2-6.1-2.2-8.3 0zm7.7-75c-13.6 0-24.6 11.1-24.6 24.9 0 13.6 11.1 24.6 24.6 24.6 13.8 0 24.9-11.1 24.9-24.6 0-13.8-11-24.9-24.9-24.9z"/>
      </svg>
      <span>
        {@label ||
          cond do
            @subreddit -> "r/#{@subreddit}"
            @user -> "u/#{@user}"
            true -> "Reddit"
          end}
      </span>
    </a>
    """
  end

  attr :link, :string, default: nil
  attr :repo, :string, default: nil
  attr :user, :string, default: nil
  attr :label, :string, default: nil
  attr :class, :string, default: nil
  attr :target, :string, default: "_blank"
  attr :rel, :string, default: "noopener noreferrer"

  def github(assigns) do
    ~H"""
    <a
      href={
        @link ||
          cond do
            @repo -> "https://github.com/#{@repo}"
            @user -> "https://github.com/#{@user}"
            true -> "https://github.com"
          end
      }
      target={@target}
      rel={@rel}
      aria-label="GitHub"
      class={[
        "tw-inline-flex tw-items-center tw-gap-1.5 tw-px-3 tw-py-1.5 tw-rounded-lg tw-text-xs tw-font-semibold tw-border tw-transition-all tw-duration-150",
        "tw-bg-slate-800/60 hover:tw-bg-slate-700/60 tw-text-slate-200 tw-border-slate-700/70 hover:tw-border-slate-600/80",
        @class
      ]}
    >
      <svg class="tw-w-3.5 tw-h-3.5 tw-fill-current tw-shrink-0" viewBox="0 0 496 512">
        <path d="M165.9 397.4c0 2-2.3 3.6-5.2 3.6-3.3.3-5.6-1.3-5.6-3.6 0-2 2.3-3.6 5.2-3.6 3-.3 5.6 1.3 5.6 3.6zm-31.1-4.5c-.7 2 1.3 4.3 4.3 4.9 2.6 1 5.6 0 6.2-2s-1.3-4.3-4.3-5.2c-2.6-.7-5.5.3-6.2 2.3zm44.2-1.7c-2.9.7-4.9 2.6-4.6 4.9.3 2 2.9 3.3 5.9 2.6 2.9-.7 4.9-2.6 4.6-4.6-.3-1.9-3-3.2-5.9-2.9zM244.8 8C106.1 8 0 113.3 0 252c0 110.9 69.8 205.8 169.5 239.2 12.8 2.3 17.3-5.6 17.3-12.1 0-6.2-.3-40.4-.3-61.4 0 0-70 15-84.7-29.8 0 0-11.4-29.1-27.8-36.6 0 0-22.9-15.7 1.6-15.4 0 0 24.9 2 38.6 25.8 21.9 38.6 58.6 27.5 72.9 20.9 2.3-16 8.8-27.1 16-33.7-55.9-6.2-112.3-14.3-112.3-110.5 0-27.5 7.6-41.3 23.6-58.9-2.6-6.5-11.1-33.3 2.6-67.9 20.9-6.5 69 27 69 27 20-5.6 41.5-8.5 62.8-8.5s42.8 2.9 62.8 8.5c0 0 48.1-33.6 69-27 13.7 34.7 5.2 61.4 2.6 67.9 16 17.7 25.8 31.5 25.8 58.9 0 96.5-58.9 104.2-114.8 110.5 9.2 7.9 17 22.9 17 46.4 0 33.7-.3 75.4-.3 83.6 0 6.5 4.6 14.4 17.3 12.1C428.2 457.8 496 362.9 496 252 496 113.3 383.5 8 244.8 8zM97.2 352.9c-1.3 1-1 3.3.7 5.2 1.6 1.6 3.9 2.3 5.2 1 1.3-1 1-3.3-.7-5.2-1.6-1.6-3.9-2.3-5.2-1zm-10.8-8.1c-.7 1.3.3 2.9 2.3 3.9 1.6 1 3.6.7 4.3-.7.7-1.3-.3-2.9-2.3-3.9-2-.6-3.6-.3-4.3.7zm32.4 35.6c-1.6 1.3-1 4.3 1.3 6.2 2.3 2.3 5.2 2.6 6.5 1 1.3-1.3.7-4.3-1.3-6.2-2.2-2.3-5.2-2.6-6.5-1zm-11.4-14.7c-1.6 1-1.6 3.6 0 5.9 1.6 2.3 4.3 3.3 5.6 2.3 1.6-1.3 1.6-3.9 0-6.2-1.4-2.3-4-3.3-5.6-2z"/>
      </svg>
      <span>{@label || @repo || @user || "GitHub"}</span>
    </a>
    """
  end

  attr :link, :string, default: nil
  attr :page, :string, default: nil
  attr :label, :string, default: nil
  attr :live?, :boolean, default: false
  attr :class, :string, default: nil
  attr :target, :string, default: "_blank"
  attr :rel, :string, default: "noopener noreferrer"

  def facebook(assigns) do
    ~H"""
    <a
      href={@link || (if @page, do: "https://www.facebook.com/#{@page}", else: "https://www.facebook.com")}
      target={@target}
      rel={@rel}
      aria-label="Facebook"
      class={[
        "tw-inline-flex tw-items-center tw-gap-1.5 tw-px-3 tw-py-1.5 tw-rounded-lg tw-text-xs tw-font-semibold tw-border tw-transition-all tw-duration-150",
        "tw-bg-[#1877f2]/15 hover:tw-bg-[#1877f2]/25 tw-text-[#60a5fa] tw-border-[#1877f2]/40 hover:tw-border-[#1877f2]/60",
        @class
      ]}
    >
      <svg class="tw-w-3.5 tw-h-3.5 tw-fill-current tw-shrink-0" viewBox="0 0 320 512">
        <path d="M279.14 288l14.22-92.66h-88.91v-60.13c0-25.35 12.42-50.06 52.24-50.06h40.42V6.26S260.43 0 225.36 0c-73.22 0-121.08 44.38-121.08 124.72v70.62H22.89V288h81.39v224h100.17V288z"/>
      </svg>
      <span>{@label || @page || "Facebook"}</span>
      <.live_indicator :if={@live?} />
    </a>
    """
  end

  attr :link, :string, default: nil
  attr :handle, :string, default: nil
  attr :label, :string, default: nil
  attr :class, :string, default: nil
  attr :target, :string, default: "_blank"
  attr :rel, :string, default: "noopener noreferrer"

  def threads(assigns) do
    ~H"""
    <a
      href={@link || (if @handle, do: "https://www.threads.net/@#{@handle}", else: "https://www.threads.net")}
      target={@target}
      rel={@rel}
      aria-label={"Threads #{@handle || @label || ""}"}
      class={[
        "tw-inline-flex tw-items-center tw-gap-1.5 tw-px-3 tw-py-1.5 tw-rounded-lg tw-text-xs tw-font-semibold tw-border tw-transition-all tw-duration-150",
        "tw-bg-slate-800/60 hover:tw-bg-slate-700/60 tw-text-slate-200 tw-border-slate-700/70 hover:tw-border-slate-600/80",
        @class
      ]}
    >
      <svg class="tw-w-3.5 tw-h-3.5 tw-fill-current tw-shrink-0" viewBox="0 0 24 24">
        <path d="M12.186 24h-.007C5.463 23.974 0 18.513 0 11.79 0 5.079 5.463-.38 12.179-.38c6.685 0 12.179 5.437 12.179 12.17 0 .54-.038 1.087-.113 1.618a1.205 1.205 0 0 1-1.353 1.026 1.207 1.207 0 0 1-1.026-1.354c.06-.432.09-.877.09-1.29 0-5.385-4.403-9.768-9.78-9.768-5.39 0-9.774 4.398-9.774 9.778 0 5.378 4.384 9.768 9.774 9.768 2.658 0 5.176-1.06 7.087-2.985a1.203 1.203 0 0 1 1.708 1.696C18.66 22.76 15.546 24 12.186 24zm4.847-11.83a7.354 7.354 0 0 0-4.854-1.92c-3.79 0-6.22 2.668-6.22 6.077 0 3.39 2.404 6.088 6.22 6.088 2.378 0 4.29-.982 5.38-2.766a1.205 1.205 0 0 0-.395-1.666 1.208 1.208 0 0 0-1.668.397c-.687 1.12-1.932 1.624-3.317 1.624-2.483 0-3.818-1.74-3.818-3.677 0-1.95 1.353-3.675 3.818-3.675 1.48 0 2.665.578 3.338 1.627a3.84 3.84 0 0 1 .472 2.052c0 .92-.375 1.68-1.028 2.143-.518.368-1.242.56-2.096.56-1.464 0-2.433-.762-2.433-1.914 0-.895.666-1.66 1.76-1.795.62-.078 1.267-.02 1.892.172a1.204 1.204 0 0 0 1.498-.79 1.207 1.207 0 0 0-.79-1.498 6.236 6.236 0 0 0-2.593-.207c-2.316.286-4.17 2.025-4.17 4.12 0 2.454 2.08 4.324 4.836 4.324 1.408 0 2.634-.36 3.543-1.042 1.182-.888 1.854-2.28 1.854-3.824 0-1.033-.312-2.314-1.22-3.654z"/>
      </svg>
      <span>{@label || (if @handle, do: "@#{@handle}", else: "Threads")}</span>
    </a>
    """
  end
end
