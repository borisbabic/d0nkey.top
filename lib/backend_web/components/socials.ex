defmodule Components.Socials do
  use Phoenix.Component

  def paypal(assigns = %{link: _link}) do
    ~H"""
      <a href={@link}>
        <img height="50px" class="image" alt="Paypal" src="https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif"/>
      </a>
    """
  end

  def discord(assigns = %{link: _link}) do
    ~H"""
      <a href={@link}>
        <img style="height: 30px;" class="image" alt="Discord" src="/images/brands/discord.svg"/>
      </a>
    """
  end

  def twitch(assigns = %{link: _link}) do
    ~H"""
      <a href={@link}>
        <img style="height: 30px;" class="image" alt="Twitch" src="/images/brands/twitch_extruded_wordmark_purple.svg"/>
      </a>
    """
  end

  def patreon(assigns = %{link: _link}) do
    ~H"""
      <a href={@link}>
        <img style="height: 30px;" class="image" alt="Patreon" src="/images/brands/patreon_wordmark_fierycoral.png"/>
      </a>
    """
  end

  def twitter_follow(assigns) do
    ~H"""
      <a class="twitter-follow-button"
        href={"https://twitter.com/#{@tag}"}
        data-show-screen-name="false"
        data-show-count="false">
      Follow</a>
    """
  end

end
