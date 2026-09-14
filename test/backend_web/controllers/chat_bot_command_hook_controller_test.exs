defmodule BackendWeb.ChatBotCommandHookControllerTest do
  use BackendWeb.ConnCase, async: false

  alias Backend.Hearthstone.Deck
  alias BackendWeb.ChatBotCommandHookController

  @sample_deckcode "AAECAZICAAADAgWSAgbmBQrKnAMK/60DCvm1AwrlugMK77oDCvnMAwqbzgMKudIDCvDUAwqJ4AMKiuADCozkAwqunwQK2Z8ECg=="

  setup do
    {:ok, %Deck{} = decoded_deck} = Deck.decode(@sample_deckcode)

    deck = %Deck{
      decoded_deck
      | id: 12_345,
        archetype: :"Ramp Druid"
    }

    %{deck: deck}
  end

  describe "deck_message/2" do
    test "returns default deck link with id when message parameter is missing", %{deck: deck} do
      assert {:ok, "https://www.hsguru.com/deck/12345"} =
               ChatBotCommandHookController.deck_message(deck, %{})

      assert {:ok, "https://www.hsguru.com/deck/12345"} =
               ChatBotCommandHookController.deck_message(deck, nil)
    end

    test "returns default deck link with deckcode when id is nil", %{deck: %Deck{} = deck} do
      deck_without_id = %Deck{deck | id: nil}

      assert {:ok, "https://www.hsguru.com/deck/" <> deckcode} =
               ChatBotCommandHookController.deck_message(deck_without_id, %{})

      assert byte_size(deckcode) > 0
    end

    test "renders custom message template with deck attributes", %{deck: deck} do
      template = "Check out {{ archetype }} ({{ format }}) for {{ class }}! Cost: {{ cost }}. Link: {{ link }}"

      assert {:ok, rendered} =
               ChatBotCommandHookController.deck_message(deck, %{"message" => template})

      assert rendered ==
               "Check out Ramp Druid (#{Deck.format_name(deck)}) for #{deck.class}! Cost: #{Deck.cost(deck)}. Link: https://www.hsguru.com/deck/12345"
    end

    test "renders name field in template", %{deck: deck} do
      template = "Deck: {{ name }}"

      assert {:ok, rendered} =
               ChatBotCommandHookController.deck_message(deck, %{"message" => template})

      assert rendered == "Deck: #{Deck.name(deck)}"
    end

    test "returns error when template syntax is invalid", %{deck: deck} do
      invalid_template = "Invalid: {{ name"

      assert {:error, %Solid.TemplateError{}} =
               ChatBotCommandHookController.deck_message(deck, %{"message" => invalid_template})
    end

    test "returns error when first argument is not a Deck struct" do
      assert {:error, :not_a_deck} =
               ChatBotCommandHookController.deck_message(%{class: "SHAMAN"}, %{})

      assert {:error, :not_a_deck} =
               ChatBotCommandHookController.deck_message(nil, %{})
    end
  end

  describe "GET /chat-bot-command-hook/help" do
    test "renders help page with 200 status", %{conn: conn} do
      conn = get(conn, "/chat-bot-command-hook/help")
      assert html_response(conn, 200) =~ "Chat Bot Command Hooks"
      assert html_response(conn, 200) =~ "Next Reveal"
      assert html_response(conn, 200) =~ "Deckcode"
      assert html_response(conn, 200) =~ "Leaderboard"
      assert html_response(conn, 200) =~ "Top 25"
      assert html_response(conn, 200) =~ "Leaderboard count"
      assert html_response(conn, 200) =~ "HS News"
    end
  end
end
