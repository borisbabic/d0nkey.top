defmodule Bot.SlashCommands.TimestampCommands do
  @moduledoc false
  use Bot.SlashCommands.SlashCommand

  @region_choices [
    %{
      "value" => "EU",
      "name" => "Europe"
    },
    %{
      "value" => "US",
      "name" => "Americas"
    },
    %{
      "value" => "AP",
      "name" => "Asia-Pacific"
    },
    %{
      "value" => "CN",
      "name" => "China"
    }
  ]
  @impl true
  def get_commands() do
    [
      %{
        name: "reset",
        description: "Get the next reset (in your timezone)",
        options: [
          %{
            # string
            type: 3,
            name: "region",
            description: "Which region",
            min_value: 1,
            choices: @region_choices,
            required: false
          }
        ]
      },
      %{
        name: "midnight",
        description: "Get the next Hearthstone season reset (in your timezone)",
        options: [
          %{
            # string
            type: 3,
            name: "region",
            description: "Which region",
            min_value: 1,
            choices: @region_choices,
            required: false
          }
        ]
      },
      %{
        name: "blizz",
        description: "Get the next blizz o clock (in your timezone)"
      }
    ]
  end

  @impl true
  def handle_interaction(%Interaction{data: %{name: "reset"}} = interaction) do
    region = option_value(interaction, "region")
    message = Bot.MessageHandler.reset_message(region)

    respond(interaction, message)
    :ok
  end

  @impl true
  def handle_interaction(%Interaction{data: %{name: "midnight"}} = interaction) do
    region = option_value(interaction, "region")
    message = Bot.MessageHandler.midnight_message(region)
    respond(interaction, message)
    :ok
  end

  @impl true
  def handle_interaction(%Interaction{data: %{name: "blizz"}} = interaction) do
    message = Bot.MessageHandler.blizz_message()

    respond(interaction, message)
    :ok
  end

  def handle_interaction(_), do: :skip
end
