defmodule Components.DecklistCard do
  @moduledoc false
  use BackendWeb, :surface_component
  alias Backend.HearthstoneJson
  alias Backend.Hearthstone.Card
  alias Backend.Hearthstone.CardBag
  alias Backend.Hearthstone.Deck
  alias Backend.UserManager.User.DecklistOptions
  prop(count, :integer, required: true)
  prop(card, :map, required: true)
  prop(deck, :map, default: %{})
  # currently just for zilliax delux 3000
  prop(use_deck_card_cost, :boolean, default: true)
  prop(deck_class, :string, default: "NEUTRAL")
  prop(sideboarded_in, :boolean, default: false)
  prop(show_mana_cost, :boolean, default: true)
  prop(decklist_options, :map, default: %{})

  defp rarity(nil), do: rarity("COMMON")
  defp rarity("FREE"), do: rarity("COMMON")
  defp rarity(rarity), do: rarity |> String.downcase()
  defp class(class), do: class |> String.downcase()

  defp color_option("rarity", %{rarity: rarity}), do: "var(--color-dark-#{rarity})"
  defp color_option("card_class", %{card_class: card_class}), do: "var(--color-#{card_class})"
  defp color_option("deck_class", %{deck_class: deck_class}), do: "var(--color-#{deck_class})"

  defp color_option("deck_format", %{deck_format: deck_format}),
    do: "var(--color-#{deck_format |> Deck.format_name() |> String.downcase()})"

  defp color_option(_, _), do: "var(--color-darker-grey)"

  defp colors(card, deck_class, opts, deck) do
    rarity = Card.rarity(card)
    filtered_opts = opts |> Map.to_list() |> Enum.filter(fn {_, v} -> v end) |> Map.new()

    %{border: border, gradient: gradient} =
      %{
        border: "dark_grey",
        gradient: "rarity"
      }
      |> Map.merge(filtered_opts)

    color_opts = %{
      rarity: rarity(rarity),
      card_class: card_class(card, deck_class) |> class(),
      deck_class: class(deck_class),
      deck_format: Map.get(deck, :format, 0)
    }

    %{
      border: color_option(border, color_opts),
      gradient: color_option(gradient, color_opts)
    }
  end

  defp card_class(card, deck_class) do
    case Card.class(card, deck_class) do
      {:ok, class} -> class
      _ -> "NEUTRAL"
    end
  end

  def render(assigns) do
    card = assigns[:card]
    html_id = "card-#{card.id}"

    {tile_url, card_url} = tile_card_url(card)
    id = Ecto.UUID.generate()

    %{border: border, gradient: gradient} =
      colors(card, assigns[:deck_class], assigns[:decklist_options], assigns[:deck])

    # rarity_color = "--color-dark-#{rarity(card.rarity)}"
    # deck_class_color = "--color-#{class(card.card_class)}"

    ~F"""
      <a href={~p"/card/#{@card}"}>
        <div onmouseover={"set_display('#{id}', 'flex')"} onmouseout={"set_display('#{id}', 'none')"}>
          <div style={"--color-border: #{border}; --color-gradient: #{gradient};"} class={"decklist-card-container decklist-card #{html_id} is-flex is-align-items-center"}>
            <span class="deck-text decklist-card-background" style=" padding-left: 0.5ch;"></span>
            <span :if={@show_mana_cost}class="card-number deck-text decklist-card-background is-unselectable has-text-left" style="width: 3ch;">{cost(card, @use_deck_card_cost, @deck)}</span>
            <div class="card-name deck-text decklist-card-gradient has-text-left is-clipped">
              <span style="font-size: 0;"># {@count}x ({Card.cost(@card)}) </span>
              <span :if={@sideboarded_in}><HeroIcons.chevron_right size="small"/></span>
              {card.name}
            </div>
            <div style={"background-image: url('#{tile_url}');"} class="decklist-card-tile">
            </div>
            <span style="padding-left:0.5ch; padding-right: 0.5ch; width: 1ch;" class="has-text-right card-number deck-text decklist-card-background is-unselectable">{count(@count, Card.rarity(@card), @decklist_options)}</span>
            <div id={"#{id}"} class="decklist-card-image" style={"background-image: url('#{card_url}'); background-size: 256px; background-repeat: no-repeat; pointer-events: none;"}></div>
          </div>
        </div>
        <div></div>
      </a>
    """
  end

  @spec cost(Card.t(), use_deck_card_cost :: boolean(), Deck.t()) :: integer()
  defp cost(card, true, deck) do
    Deck.card_mana_cost(deck, card)
  end

  defp cost(card, false, _deck) do
    Card.cost(card)
  end

  defp count(1, "LEGENDARY", decklist_options) do
    if DecklistOptions.show_one_for_legendaries(decklist_options) do
      1
    else
      "⋆"
    end
  end

  defp count(1, _, decklist_options) do
    if DecklistOptions.show_one(decklist_options) do
      1
    end
  end

  defp count(count, _, _), do: count
  @spec tile_card_url(Card.t() | Backend.HearthstoneJson.Card.t()) :: {String.t(), String.t()}
  defp tile_card_url(card) do
    dbf_id = Card.dbf_id(card)

    {tile_url, card_url} = CardBag.tile_card_url(dbf_id)
    {hsj_tile_url, hsj_card_url} = HearthstoneJson.tile_card_url(dbf_id)

    {
      tile_url || hsj_tile_url,
      card_url || hsj_card_url
    }
  end
end
