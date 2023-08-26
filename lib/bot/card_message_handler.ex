defmodule Bot.CardMessageHandler do
  @moduledoc false
  alias Nostrum.Api
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

    embeds = create_card_embeds(cards)

    Api.create_message(msg.channel_id, embeds: embeds)
  end

  def ensure_sane_limit(criteria) do
    {{"limit", limit_raw}, rest} = List.keytake(criteria, "limit", 0)
    requested_limit = Util.to_int!(limit_raw, 10)
    sane_limit = Enum.min([requested_limit, 10])
    [{"limit", sane_limit} | rest]
  end

  def create_card_embeds(cards), do: Enum.map(cards, &create_card_embed/1)

  def create_card_embed(card, opts \\ []) do
    card_url = Keyword.get(opts, :card_url, Card.card_url(card))
    embed = Keyword.get(opts, :embed, %Embed{})

    embed
    |> Embed.put_title("#{card.name} (View card and tokens)")
    |> Embed.put_image(card_url)
    |> Embed.put_url("https://www.hsguru.com/card/#{Card.dbf_id(card)}")
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
end
