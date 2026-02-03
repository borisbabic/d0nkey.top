defmodule Bot.CardMessageHandler do
  @moduledoc false
  alias Backend.Hearthstone
  alias Backend.Hearthstone.Card
  alias Backend.Hearthstone.CardAggregate
  alias Nostrum.Struct.Embed
  import Bot.MessageHandlerUtil

  @default_cards_criteria [
    {"collectible", "yes"},
    {"limit", 3},
    {"order_by", "latest"}
  ]

  @default_card_stats_criteria [
    {"collectible", "yes"},
    {"format", "standard"}
  ]

  def handle_card_stats(msg) do
    reply = create_card_stats_message(msg)

    message = """
    ```
    #{reply}
    ```
    """

    send_message(message, msg.channel_id)
  end

  def handle_cards(msg) do
    {criteria, _rest} = get_criteria(msg.content)

    cards =
      criteria
      |> add_default_criteria(@default_cards_criteria)
      |> ensure_sane_limit()
      |> Hearthstone.cards()

    components = Enum.map(cards, &create_image_component/1)

    create_components_message(msg.channel_id, components)
  end

  def ensure_sane_limit(criteria) do
    {{"limit", limit_raw}, rest} = List.keytake(criteria, "limit", 0)
    requested_limit = Util.to_int!(limit_raw, 10)
    sane_limit = Enum.min([requested_limit, 10])
    [{"limit", sane_limit} | rest]
  end

  def create_image_component(card, opts \\ []) do
    card_url = Keyword.get(opts, :card_url, Card.card_url(card)) |> add_hsguru()
    title_prepend = Keyword.get(opts, :title_prepend, nil)

    accent_color = discord_color(card)

    title =
      "### [#{card.name} (View card and tokens)](#{Card.our_url(card)})"

    %{
      type: 17,
      accent_color: accent_color,
      components: [
        %{
          type: 10,
          content: "#{title_prepend}#{if title_prepend, do: "\n"}#{title}"
        },
        %{
          type: 12,
          items: [
            %{
              media: %{url: card_url},
              description: Card.description(card)
            }
          ]
        }
      ]
    }
  end

  def create_card_image_component(card_name) when is_binary(card_name) do
    title = potential_matches_link(card_name)
    card = Backend.Hearthstone.get_fuzzy_card(card_name)

    if card do
      create_image_component(card, title_prepend: title)
    else
      %{
        type: 17,
        components: [
          %{
            type: 10,
            content: title
          }
        ]
      }
    end
  end

  def create_card_info_embed(card_name, include_other_matches \\ true)
      when is_binary(card_name) do
    other_matches = potential_matches_link(card_name)
    card = Backend.Hearthstone.get_fuzzy_card(card_name)

    if card do
      embed =
        %Embed{}
        |> Embed.put_title(Card.name(card))
        |> Embed.put_description(format_text(card.text))
        |> Embed.put_url(Card.our_url(card))
        |> Embed.put_color(discord_color(card))
        |> Embed.put_thumbnail(Card.card_url(card))
        |> Embed.put_field("Flavor Text", Map.get(card, :flavor_text))

      if include_other_matches do
        embed
        |> Embed.put_field("Other Matches", other_matches)
      end
    else
      %Nostrum.Struct.Embed{}
      |> Embed.put_title(other_matches)
    end
  end

  def create_card_stats_message(%{content: content}) do
    {criteria, _rest} = get_criteria(content)

    cards =
      criteria
      |> add_default_criteria(@default_card_stats_criteria)
      |> Hearthstone.cards()

    cards
    |> CardAggregate.aggregate()
    |> CardAggregate.string_fields_list()
    |> Enum.map(&Tuple.to_list/1)
    |> TableRex.quick_render!([])
  end

  defp discord_color(card) do
    case Card.class(card) do
      {:ok, class} -> Backend.Hearthstone.Deck.class_color(class) |> to_discord_color()
      _ -> nil
    end
  end

  defp potential_matches_link(card_name) do
    "[#{card_name} (Other potential matches)](https://www.hsguru.com/cards?collectible=yes&order_by=name_similarity_#{URI.encode(card_name)})"
  end

  defp add_hsguru("/" <> _ = card_url), do: "https://www.hsguru.com/#{card_url}"
  defp add_hsguru(card_url), do: card_url
end
