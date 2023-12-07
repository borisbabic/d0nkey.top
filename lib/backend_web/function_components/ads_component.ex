defmodule FunctionComponents.Ads do
  use Phoenix.Component

  attr :leaderboard, :boolean, default: true
  attr :mobile_video, :boolean, default: false
  attr :mobile_video_floating, :boolean, default: false
  attr :br, :boolean, default: true

  def below_title(assigns) do
    ~H"""
      <.below_title_leaderboard :if={@leaderboard} />
      <.mobile_video :if={@mobile_video} />
      <.mobile_video_floating :if={@mobile_video_floating} />
      <br :if={@br}/>
    """
  end

  def below_title_leaderboard(assigns) do
    ~H"""
      <div phx-update="ignore" id="nitropay-below-title-leaderboard"></div>
    """
  end

  def mobile_video(assigns) do
    ~H"""
      <div phx-update="ignore" id="nitropay-video-mobile"></div>
    """
  end

  def mobile_video_floating(assigns) do
    ~H"""
      <div phx-update="ignore" id="nitropay-video-mobile-floating"></div>
    """
  end
end
