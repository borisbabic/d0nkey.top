defmodule Bot.SlashCommands.CardCommand do
  @moduledoc false
  use Bot.SlashCommands.SlashCommand
  alias Backend.Hearthstone.Card

  @name "card"
  @image_name "card_image"
  @impl true
  def get_commands() do
    [
      %{
        name: @name,
        description: "Get card info",
        options: [
          %{
            # string
            type: 3,
            name: "card_search",
            description: "Card search",
            min_value: 1,
            autocomplete: true,
            required: true
          }
        ]
      },
      %{
        name: @image_name,
        description: "Get card image",
        options: [
          %{
            # string
            type: 3,
            name: "card_search",
            description: "Card search",
            min_value: 1,
            autocomplete: true,
            required: true
          }
        ]
      }
    ]
  end

  def handle_interaction(%Interaction{type: 4, data: %{name: n}} = interaction)
      when n in [@name, @image_name] do
    card_search = option_value(interaction, "card_search")

    choices =
      if String.length(card_search) >= 3 do
        Backend.Hearthstone.get_fuzzy_cards(card_search, 10)
        |> Enum.map(fn c ->
          name = Card.name(c)
          rarity_square = Card.rarity_square(c)
          %{name: "#{rarity_square} #{name}", value: name}
        end)
      else
        []
      end

    Nostrum.Api.create_interaction_response(interaction, %{
      type: 8,
      data: %{choices: choices}
    })
  end

  @impl true
  def handle_interaction(%Interaction{type: 2, data: %{name: @name}} = interaction) do
    card_search = option_value(interaction, "card_search")
    defer(interaction)
    embeds = Bot.CardMessageHandler.create_card_info_embed(card_search)

    embeds_follow_up(interaction, embeds)
    :ok
  end

  @impl true
  def handle_interaction(%Interaction{type: 2, data: %{name: @image_name}} = interaction) do
    card_search = option_value(interaction, "card_search")
    defer(interaction)
    components = Bot.CardMessageHandler.create_card_image_component(card_search)

    components_follow_up(interaction, components)
    :ok
  end

  def handle_interaction(_), do: :skip
end
