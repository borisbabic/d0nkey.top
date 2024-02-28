defmodule Components.Socials do
  use Phoenix.Component

  attr :link, :string, required: true

  def paypal(assigns) do
    ~H"""
      <a href={@link}>
        <img height="50px" class="image" alt="Paypal" src="https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif"/>
      </a>
    """
  end

  attr :link, :string, required: true

  def discord(assigns) do
    ~H"""
      <a href={@link}>
        <img style="height: 30px;" class="image" alt="Discord" src="/images/brands/discord.svg"/>
      </a>
    """
  end

  attr :link, :string, required: true

  def twitch(channel) when is_binary(channel),
    do: %{link: "https://www.twitch.tv/#{channel}"} |> twitch()

  def twitch(assigns) do
    ~H"""
      <a href={@link}>
        <img style="height: 30px;" class="image" alt="Twitch" src="/images/brands/twitch_extruded_wordmark_purple.svg" />
      </a>
    """
  end

  attr :link, :string, required: true

  def patreon(assigns) do
    ~H"""
      <a href={@link}>
        <.patreon_image />
      </a>
    """
  end

  def patreon_image(assigns) do
    ~H"""
      <img style="height: 30px;" class="image" alt="Patreon" src="/images/brands/patreon_wordmark_fierycoral.png" />
    """
  end

  attr :tag, :string, required: true

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
