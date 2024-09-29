defmodule FunctionComponents.Ads do
  @moduledoc "Components for ad placements"

  use Phoenix.Component

  attr :leaderboard, :boolean, default: true
  attr :mobile_video_mode, :atom, default: :floating
  attr :ad_blocking_hint, :boolean, default: false
  attr :br, :boolean, default: true

  def below_title(assigns) do
    ~H"""
      <.below_title_leaderboard :if={@leaderboard} ad_blocking_hint={@ad_blocking_hint} />
      <.mobile_video :if={:enabled == @mobile_video_mode} />
      <.mobile_video_floating :if={:floating == @mobile_video_mode} />
      <br :if={@br}/>
    """
  end

  attr :ad_blocking_hint, :boolean, default: false

  def below_title_leaderboard(assigns) do
    ~H"""
      <div phx-update="ignore" id="nitropay-below-title-leaderboard">
        <.ad_blocking_hint :if={@ad_blocking_hint} />
      </div>
    """
  end

  attr :hint_type, :atom, default: :text_only

  def ad_blocking_hint(assigns) do
    ~H"""
      <div class="is-hidden-mobile">
        <div class="is-shown-ad-blocking" style="height: 100vh">
          <div style="z-index: 0; position: sticky; top: 20px;">
            <div :if={:text_only == @hint_type}>
              <FunctionComponents.Hints.patreon />
              <br>
              <br>
              <FunctionComponents.Hints.discord />
            </div>
          </div>
        </div>
      </div>
    """
  end

  def mobile_video(assigns) do
    ~H"""
      <div phx-update="ignore" id="nitropay-video-mobile"></div>
    """
  end

  def mobile_video_floating(assigns) do
    ~H"""
      <div phx-update="ignore" id="nitropay-floating-video-mobile-container"></div>
    """
  end
end
