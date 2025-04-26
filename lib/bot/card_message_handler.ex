defmodule Bot.CardMessageHandler do
  @moduledoc false
  alias Nostrum.Api
  alias Backend.Hearthstone
  alias Backend.Hearthstone.Card
  alias Backend.Hearthstone.CardAggregate
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

    components = Enum.map(cards, &create_component/1)

    create_components_message(msg.channel_id, components)
  end

  def ensure_sane_limit(criteria) do
    {{"limit", limit_raw}, rest} = List.keytake(criteria, "limit", 0)
    requested_limit = Util.to_int!(limit_raw, 10)
    sane_limit = Enum.min([requested_limit, 10])
    [{"limit", sane_limit} | rest]
  end

  def create_component(card, opts \\ []) do
    card_url = Keyword.get(opts, :card_url, Card.card_url(card)) |> add_hsguru()
    title_prepend = Keyword.get(opts, :title_prepend, nil)

    accent_color =
      case Backend.Hearthstone.Card.class(card) do
        {:ok, class} -> Backend.Hearthstone.Deck.class_color(class) |> to_discord_color()
        _ -> nil
      end

    title =
      "### [#{card.name} (View card and tokens)](https://www.hsguru.com/card/#{Backend.Hearthstone.Card.dbf_id(card)})"

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

  defp add_hsguru("/" <> _ = card_url), do: "https://www.hsguru.com/#{card_url}"
  defp add_hsguru(card_url), do: card_url
end
