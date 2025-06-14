defmodule BackendWeb.DeckBuilderLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Backend.DeckInteractionTracker, as: Tracker
  alias Components.CardsExplorer
  alias Components.ExpandableDecklist
  alias Hearthstone.DeckcodeExtractor
  alias Backend.Hearthstone.Deck
  alias Backend.Hearthstone.Deck.Sideboard
  alias Backend.Hearthstone.Card
  alias Backend.Hearthstone.CardBag
  alias Surface.Components.Form
  alias Surface.Components.Form.Field
  alias Surface.Components.Form.TextArea
  alias Surface.Components.Form.Submit

  @supported_formats [1, 2]
  data(deck_class, :string)
  data(format, :integer)
  data(raw_params, :map)
  data(deck, :map)
  data(show_cards, :boolean)

  def mount(_params, session, socket),
    do:
      {:ok,
       socket
       |> assign_defaults(session)
       |> put_user_in_context()
       |> assign(deck: nil, raw_params: %{}, show_cards: false, scroll_size: 1)}

  def render(assigns) do
    ~F"""
    <div>
      <div class="title is-2">Hearthstone DeckBuilder</div>
        <FunctionComponents.Ads.below_title/>
      <div :if={@deck}>
        <div class="sticky-top decklist_card_container darker-grey-background">
          <ExpandableDecklist deck={@deck} name={deck_name(@deck)} id="in_progress_deck" on_card_click={"remove-card"} toggle_cards={"toggle_cards"} show_cards={@show_cards}/>
        </div>
        <CardsExplorer
          scroll_size={@scroll_size}
          card_pool={card_pool(@deck)}
          default_order_by={"mana_in_class"}
          class_options={class_options(@deck)}
          format_filter={standard?(@deck)}
          live_view={__MODULE__}
          id="cards_explorer"
          additional_url_params={%{"code" => Deck.deckcode(@deck)}}
          params={card_params(@params, Deck.missing_zilliax_parts?(@deck))}
          url_params={@params}
          on_card_click={"add-card"}
          card_phx_hook={"CardRightClick"}
          card_disabled={fn card -> !Deck.addable?(@deck, card) end}>
          <:below_card :let={card: card}>
            <div class="tw-flex tw-justify-center">
              <div class="tag" :if={Card.max_copies_in_deck(card) > 1}>
                {Deck.total_copies(@deck, card)} / {Card.max_copies_in_deck(card)}
              </div>
            </div>
          </:below_card>
        </CardsExplorer>
      </div>
      <div :if={!@deck}>
        <Form submit="submit" for={%{}} as={:new_deck} opts={autocomplete: "off", id: "add_deck_form"}>
          <div class="columns is-mobile is-multitline">
            <div class="column is-narrow">
              <Field name="new_code">
                  <TextArea class="textarea has-fixed-size small" opts={placeholder: "Paste deckcode or link", size: "30", rows: "1"}/>
              </Field>
            </div>
            <div class="column is-narrow">
              <Submit label="Edit" class="button"/>
            </div>
          </div>
        </Form>
        <button class={"button", "decklist-info", String.downcase(class)} :for={class <- Deck.classes(), format <- supported_formats()} :on-click={"pick-class-format"} phx-value-format={format} phx-value-deck_class={class}>
        {Deck.class_name(class)} - {format_name(format)}
        </button>
      </div>
    </div>
    """
  end

  defp format_name("standard_2024"), do: "2024 Standard"
  defp format_name("standard_2025"), do: "2025 Standard"
  defp format_name("ed_prerelease_brawl"), do: "Prerelease Brawl"
  defp format_name(format), do: Deck.format_name(format)

  defp standard?(%{format: 2}), do: true
  defp standard?(_), do: false

  defp card_pool(deck) do
    tourist_pool =
      for {class, set} <- Deck.tourist_class_set_tuples(deck) do
        %{class: class, card_set_id: set, not_tourist: true}
      end

    [%{class: Deck.class(deck)}, %{class: "NEUTRAL"} | tourist_pool]
  end

  defp class_options(deck) do
    tourist_classes = for {class, _} <- Deck.tourist_class_set_tuples(deck), do: class
    [Deck.class(deck) | tourist_classes]
  end

  defp deck_name(deck) do
    max =
      if Card.renathal() in deck.cards do
        40
      else
        30
      end

    curr = Enum.count(deck.cards)

    if curr == max do
      Deck.name(deck)
    else
      class = Deck.class(deck) |> Deck.class_name()
      "#{class} #{curr}/#{max}" |> Deck.add_runes(deck)
    end
  end

  defp supported_formats(), do: @supported_formats
  defp card_params(params, false), do: params

  defp card_params(_, true) do
    %{"collectible" => false, "card_set_id" => [1897], "search" => " Module"}
  end

  def handle_event("pick-class-format", %{"format" => format, "deck_class" => class}, socket) do
    %{raw_params: raw_params} = socket.assigns
    hero = Deck.get_basic_hero(class)
    deckcode = Deck.deckcode([], hero, Util.to_int(format, 2))

    new_params =
      Map.merge(raw_params, %{"format" => format, "deck_class" => class, "code" => deckcode})

    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, new_params))}
  end

  def handle_event("remove-card", %{"card_id" => _card_raw} = params, socket) do
    do_remove_card(socket, params)
  end

  def handle_event("submit", %{"new_deck" => %{"new_code" => new_code}}, socket) do
    case DeckcodeExtractor.extract_decks(new_code) do
      [code | _] ->
        %{raw_params: raw_params} = socket.assigns
        deck = Deck.decode!(code)

        new_params =
          Map.merge(raw_params, %{
            "format" => deck.format,
            "deck_class" => D,
            "code" => Deck.deckcode(deck)
          })

        {:noreply,
         socket
         |> assign(page_title: "DeckBuilder - #{deck_name(deck)}")
         |> push_patch(to: Routes.live_path(socket, __MODULE__, new_params))}

      _ ->
        socket
    end
  end

  def handle_event("card-right-click", %{"card_id" => _card_id} = params, socket) do
    do_remove_card(socket, params)
  end

  def handle_event("toggle_cards", _, socket) do
    {:noreply, socket |> assign(show_cards: !socket.assigns.show_cards)}
  end

  def handle_event("add-card", %{"card_id" => card_raw}, socket) do
    card = Util.to_int!(card_raw)
    %{deck: deck, raw_params: raw_params} = socket.assigns

    if Deck.addable?(deck, card) do
      new_code =
        cond do
          # hack so people can't remove the zilly art because they won't be able to add it back
          card == 110_446 ->
            Deck.deckcode(deck)

          Deck.missing_zilliax_parts?(deck) ->
            add_to_sideboard(deck, card, Card.zilliax_3000())

          missing_etc_band_member?(deck) ->
            add_to_sideboard(deck, card, Card.etc_band_manager())

          # auto add art
          Card.zilliax_3000?(card) ->
            add_card(deck, card)
            |> Deck.decode!()
            # pink is perfect. perfect is pink
            |> add_to_sideboard(110_446, card)

          true ->
            add_card(deck, card)
        end

      {:noreply,
       push_patch(socket,
         to: Routes.live_path(socket, __MODULE__, Map.put(raw_params, "code", new_code))
       )}
    else
      {:noreply, socket}
    end
  end

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end

  defp do_remove_card(socket, %{"card_id" => card_raw} = params) do
    sideboard =
      with sideboard_raw when not is_nil(sideboard_raw) <- Map.get(params, "sideboard"),
           sideboard_int when not is_nil(sideboard_int) <- Util.to_int(sideboard_raw, nil) do
        Backend.Hearthstone.canonical_id(sideboard_int)
      end

    card = Util.to_int!(card_raw)
    %{deck: deck, raw_params: raw_params} = socket.assigns

    new_code =
      if sideboard do
        remove_from_sideboard(deck, card, sideboard)
      else
        remove_card(deck, card)
      end

    {:noreply,
     push_patch(socket,
       to: Routes.live_path(socket, __MODULE__, Map.put(raw_params, "code", new_code))
     )}
  end

  defp remove_from_sideboard(deck, card, sideboard) do
    index = Enum.find_index(deck.sideboards, &(&1.card == card && &1.sideboard == sideboard))
    current = Enum.at(deck.sideboards, index)

    new_sideboards =
      if current.count > 1 do
        List.update_at(deck.sideboards, index, &Map.put(&1, :count, &1.count - 1))
      else
        List.delete_at(deck.sideboards, index)
      end

    Deck.deckcode(deck.cards, deck.hero, deck.format, new_sideboards)
  end

  defp remove_card(deck, card) do
    in_sideboard = Enum.find(deck.sideboards, nil, &(&1.card == card))

    index =
      Enum.find_index(
        deck.cards,
        &(CardBag.deckcode_copy_id(&1) == CardBag.deckcode_copy_id(card))
      )

    cond do
      index ->
        new_sideboards = Enum.reject(deck.sideboards, &(&1.sideboard == card))
        new_cards = List.delete_at(deck.cards, index)
        Deck.deckcode(new_cards, deck.hero, deck.format, new_sideboards)

      in_sideboard != nil ->
        remove_from_sideboard(deck, card, in_sideboard.sideboard)

      true ->
        Deck.deckcode(deck)
    end
  end

  defp add_card(deck, card) do
    Deck.deckcode([card | deck.cards], deck.hero, deck.format, deck.sideboards)
  end

  defp add_to_sideboard(deck, card, sideboard) do
    index = Enum.find_index(deck.sideboards, &(&1.card == card && &1.sideboard == sideboard))

    new_sideboards =
      if index do
        List.update_at(deck.sideboards, index, &Map.put(&1, :count, &1.count + 1))
      else
        [%Sideboard{sideboard: sideboard, count: 1, card: card} | deck.sideboards]
      end

    Deck.deckcode(deck.cards, deck.hero, deck.format, new_sideboards)
  end

  def handle_info({:update_filters, params}, socket) do
    %{raw_params: raw_params} = socket.assigns
    non_cards_params = Map.take(raw_params, ["deck_class", "code", "format"])

    {:noreply,
     push_patch(socket,
       to: Routes.live_path(socket, __MODULE__, Map.merge(params, non_cards_params))
     )}
  end

  def handle_params(raw_params, _uri, socket) do
    params = CardsExplorer.filter_relevant(raw_params)
    scroll_size = Map.get(raw_params, "scroll_size", socket.assigns.scroll_size) |> Util.to_int(1)

    {
      :noreply,
      socket
      |> assign(params: params, raw_params: raw_params, scroll_size: scroll_size)
      |> assign_deck(raw_params)
      |> assign_title()
    }
  end

  defp assign_deck(socket, params) do
    with code when is_binary(code) <- Map.get(params, "code"),
         {:ok, deck} <- Deck.decode(code) do
      assign(socket, :deck, deck)
    else
      _ -> socket
    end
  end

  defp assign_title(%{assigns: %{deck: %Deck{} = deck}} = socket) do
    assign(socket, :page_title, "#{deck_name(deck)} - DeckBuilder")
  end

  defp assign_title(%{assigns: %{deck_class: deck_class}} = socket) when is_binary(deck_class) do
    assign(socket, :page_title, "#{deck_class} - DeckBuidler")
  end

  defp assign_title(socket) do
    assign(socket, :page_title, "DeckBuilder")
  end

  def missing_etc_band_member?(deck) do
    Enum.any?(deck.cards, &Card.etc_band_manager?/1) and
      Deck.sideboards_count(deck, Card.etc_band_manager()) < 3
  end
end
