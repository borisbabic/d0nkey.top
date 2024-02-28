defmodule FunctionComponents.Hints do
  use BackendWeb, :component

  attr :options, :list, default: [:patreon, :discord, :card_stats, :deck_customization]
  # attr :options, :list, default: [:patreon]
  attr :to_show, :atom, required: false

  def random_text_hint(assigns) do
    assigns = assigns |> assign_new(:to_show, fn -> Enum.random(assigns.options) end)

    ~H"""
    <.discord :if={:discord == @to_show} />
    <.patreon :if={:patreon == @to_show} />
    <.card_stats :if={:card_stats == @to_show} />
    <.deck_customization :if={:deck_customization == @to_show} />
    """
  end

  def deck_customization(assigns) do
    ~H"""
    <div class="is-info">
      Did you know you can customize the look of decks on the site? Login and open settings
    </div>
    """
  end

  def card_stats(assigns) do
    ~H"""
    <div class="is-info">
      Did you know you can view mulligan info on the site? Open a list and scroll to the bottom and click on card stats.
    </div>
    """
  end

  def discord(assigns) do
    ~H"""
    <div class="is-info">
      Found a bug or have a suggestion? Let me know in my <Components.Socials.discord link={~p"/discord"} />
    </div>
    """
  end

  def patreon(assigns) do
    ~H"""
    <div class="is-info">
      Don't like ads but appreciate the site? Consider becoming a <Components.Socials.patreon link={~p"/patreon"} /> and reclaiming space reserved for ads
    </div>
    """
  end
end
