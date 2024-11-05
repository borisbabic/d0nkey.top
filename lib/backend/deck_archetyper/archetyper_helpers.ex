# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.DeckArchetyper.ArchetyperHelpers do
  @moduledoc false
  alias Backend.Hearthstone.Deck
  alias Backend.Hearthstone.Card

  ####
  # if a function starts with defp that means it's private and wont be used by modules that import this
  # for most helpers you move here you want to change it to def
  # if you're unsure just thischange to def

  @type card_info :: %{
          card_names: [String.t()],
          full_cards: [Card.t()],
          cards: [integer()],
          deck: Deck.t(),
          zilliax_sideboard_names: [String.t()],
          etc_sideboard_names: [String.t()]
        }

  @spec full_cards(Deck.t()) :: card_info()
  def full_cards(%{cards: cards} = deck) do
    {full_cards, card_names} =
      Enum.map(cards, fn c ->
        with card = %{name: name} <- Backend.Hearthstone.get_card(c) do
          {card, name}
        end
      end)
      |> Enum.filter(& &1)
      |> Enum.unzip()

    zilliax_modules_names =
      Map.get(deck, :sideboards, []) |> Deck.zilliax_modules_cards() |> Enum.map(& &1.name)

    etc_sideboard_names =
      Map.get(deck, :sideboards, []) |> Deck.etc_sideboard_cards() |> Enum.map(& &1.name)

    %{
      full_cards: full_cards,
      card_names: card_names,
      cards: cards,
      deck: deck,
      zilliax_modules_names: zilliax_modules_names,
      etc_sideboard_names: etc_sideboard_names
    }
  end

  @spec baku?(card_info()) :: boolean()
  def baku?(%{card_names: card_names}), do: "Baku the Mooneater" in card_names
  @spec genn?(card_info()) :: boolean()
  def genn?(%{card_names: card_names}), do: "Genn Greymane" in card_names

  @spec min_count?(card_info() | [String.t()], integer(), [String.t()]) :: boolean()
  def min_count?(%{card_names: card_names}, min, cards) do
    min_count?(card_names, min, cards)
  end

  def min_count?(card_names, min, cards) do
    min <= cards |> Enum.filter(&(&1 in card_names)) |> Enum.count()
  end

  @spec all_odd?(card_info()) :: boolean()
  def all_odd?(%{deck: deck, full_cards: full_cards}), do: all_cost_rem?(deck, full_cards, 1)
  @spec all_even?(card_info()) :: boolean()
  def all_even?(%{deck: deck, full_cards: full_cards}), do: all_cost_rem?(deck, full_cards, 0)

  def all_cost_rem?(deck, cards, remainder, divisor \\ 2) do
    cards
    |> Enum.filter(& &1)
    |> Enum.reject(fn card ->
      cost = Deck.card_mana_cost(deck, card)
      cost && remainder == rem(cost, divisor)
    end)
    |> Enum.empty?()
  end

  @neutral_excavate ["Kobold Miner", "Burrow Buster"]
  @standard_neutral_spell_damage [
    "Bloodmage Thalnos",
    "Kobold Geomancer",
    "Rainbow Glowscale",
    "Silvermoon Arcanist",
    "Azure Drake"
  ]

  def neutral_excavate(), do: @neutral_excavate
  def neutral_spell_damage(), do: @standard_neutral_spell_damage

  @type fallbacks_opt :: minion_type_fallback_opt()
  @spec fallbacks(card_info(), String.t(), fallbacks_opt()) :: String.t()
  def fallbacks(ci, class_name, opts \\ []) do
    cond do
      "Mecha'thun" in ci.card_names ->
        :"Mecha'thun #{class_name}"

      miracle_chad?(ci) ->
        :"Miracle Chad #{class_name}"

      "Rivendare, Warrider" in ci.card_names ->
        :"Rivendare #{class_name}"

      tentacle?(ci) ->
        :"Tentacle #{class_name}"

      ogre?(ci) ->
        :"Ogre #{class_name}"

      "Colifero the Artist" in ci.card_names ->
        :"Colifero #{class_name}"

      quest?(ci) or questline?(ci) ->
        :"Quest #{class_name}"

      "Gadgetzan Auctioneer" in ci.card_names ->
        :"Miracle #{class_name}"

      genn?(ci) ->
        :"Even #{class_name}"

      baku?(ci) ->
        :"Odd #{class_name}"

      "Seaside Giant" in ci.card_names ->
        :"Location #{class_name}"

      "Concierge" in ci.card_names and class_name != "Rogue" ->
        :"Concierge #{class_name}"

      giants?(ci) ->
        :"Giants #{class_name}"

      cute?(ci) ->
        :"Cute #{class_name}"

      starship?(ci) ->
        String.to_atom("Starship #{class_name}")

      min_secret_count?(ci, 4) ->
        String.to_atom("Secret #{class_name}")

      true ->
        minion_type_fallback(ci, class_name, opts)
    end
  end

  def giants?(ci, min_count \\ 3) do
    count =
      ci.card_names
      |> Enum.filter(&(String.reverse(&1) |> String.starts_with?("tnaiG")))
      |> Enum.count()

    count >= min_count
  end

  def tentacle?(ci), do: "Chaotic Tendril" in ci.card_names

  def miracle_chad?(ci), do: min_count?(ci, 2, ["Thaddius, Monstrosity", "Cover Artist"])

  def murloc?(ci),
    do:
      min_count?(ci, 4, [
        "Murloc Tinyfin",
        "Murloc Tidecaller",
        "Lushwater Scout",
        "Lushwater Mercenary",
        "Murloc Tidehunter",
        "Coldlight Seer",
        "Murloc Warleader",
        "Twin-fin Fin Twin",
        "Gorloc Ravager"
      ])

  def starship?(ci, min \\ 2) do
    min_keyword_count?(ci, min, "starship")
  end

  def min_keyword_count?(%{full_cards: full_cards}, min, keyword_slug) do
    num =
      full_cards
      |> Enum.filter(&Card.has_keyword?(&1, keyword_slug))
      |> Enum.count()

    num >= min
  end

  @spec min_spell_school_count?(card_info(), integer(), atom()) :: boolean()
  def min_spell_school_count?(ci, min, spell_school) do
    num =
      ci
      |> spell_school_map()
      |> Map.get(spell_school, 0)

    num >= min
  end

  def spell_school_map(%{full_cards: full_cards}) do
    full_cards
    |> Enum.flat_map(&Card.spell_schools/1)
    |> Enum.frequencies()
  end

  @spec spell_school_count(card_info()) :: integer()
  def spell_school_count(card_info) do
    card_info
    |> spell_school_map()
    |> Enum.count()
  end

  def ogre?(ci) do
    # Stupid API has one in the picture and one in the api
    min_count?(ci, 2, [
      "Ogre Gang Outlaw",
      "Ogre-Gang Outlaw",
      "Ogre Gang Rider",
      "Ogre-Gang Rider",
      "Ogre-Gang Ace",
      "Ogre Gang Ace"
    ]) and "Kingpin Pud" in ci.card_names
  end

  def menagerie?(%{card_names: card_names}), do: "The One-Amalgam Band" in card_names
  def boar?(%{card_names: card_names}), do: "Elwynn Boar" in card_names
  def kazakusan?(%{card_names: card_names}), do: "Kazakusan" in card_names

  def highlander?(card_info) do
    num_dupl = num_duplicates(card_info.cards)
    num_dupl == 0 or (num_dupl < 4 and highlander_payoff?(card_info))
  end

  def num_duplicates(cards) do
    cards
    |> Enum.frequencies()
    |> Enum.filter(fn {_, count} -> count > 1 end)
    |> Enum.count()
  end

  def vanndar?(%{card_names: card_names}), do: "Vanndar Stormpike" in card_names

  def quest_abbreviation(card_info) do
    case Enum.filter(card_info.full_cards, &Card.quest?/1) do
      [%{card_set: card_set}] -> Backend.Hearthstone.Set.abbreviation(card_set)
      _ -> nil
    end
  end

  def quest?(%{full_cards: full_cards}), do: Enum.any?(full_cards, &Card.quest?(&1))
  def questline?(%{full_cards: full_cards}), do: Enum.any?(full_cards, &Card.questline?/1)

  def highlander_payoff?(%{full_cards: full_cards}),
    do: Enum.any?(full_cards, &Card.highlander?/1)

  @type minion_type_fallback_opt ::
          {:fallback, String.t() | nil} | {:min_count, number()} | {:ignore_types, [String.t()]}
  @spec minion_type_fallback(card_info(), String.t(), [minion_type_fallback_opt()]) :: String.t()
  def minion_type_fallback(
        ci,
        class_part,
        opts
      ) do
    fallback = Keyword.get(opts, :fallback, nil)
    min_count = Keyword.get(opts, :min_count, 6)
    ignore_types = Keyword.get(opts, :ignore_types, [])

    with counts = [_ | _] <- minion_type_counts(ci),
         filtered = [_ | _] <- Enum.reject(counts, &(to_string(elem(&1, 0)) in ignore_types)),
         {type, count} when count >= min_count <- Enum.max_by(filtered, &elem(&1, 1)) do
      "#{type} #{class_part}"
    else
      _ -> fallback
    end
  end

  def min_secret_count?(%{full_cards: fc}, min) do
    secret_count =
      fc
      |> Enum.uniq_by(&Card.dbf_id/1)
      |> Enum.count(&Card.secret?/1)

    min <= secret_count
  end

  @spec minion_type_counts(card_info()) :: [{String.t(), integer()}]
  def minion_type_counts(%{full_cards: fc}) do
    base_counts =
      fc
      |> Enum.uniq_by(&Card.dbf_id/1)
      |> Enum.flat_map(fn
        %{minion_type: %{name: name}} -> [name]
        _ -> []
      end)
      |> Enum.frequencies()

    {all_count, without_all} = Map.pop(base_counts, "All", 0)

    without_all
    |> Enum.map(fn {key, val} -> {key, val + all_count} end)
  end

  @spec type_count(card_info(), String.t()) :: integer()
  def type_count(card_info, type) do
    card_info
    |> minion_type_counts()
    |> List.keyfind(type, 0, {type, 0})
    |> elem(1)
  end

  @spec neutral_bouncers?(card_info(), integer()) :: boolean()
  def neutral_bouncers?(ci, min_count \\ 2) do
    min_count?(ci, min_count, ["Youthful Brewmaster", "Saloon Brewmaster", "Zola the Gorgon"])
  end

  @spec lowest_highest_cost_cards(card_info(), :name | :full_card) ::
          {lowest :: [String.t()], highest :: [String.t()]}
          | {lowest :: [Card.t()], highest :: [Card.t()]}
  def lowest_highest_cost_cards(card_info, return \\ :name)

  def lowest_highest_cost_cards(%{full_cards: [_ | _] = full_cards}, return) do
    uniq_cards = Enum.uniq_by(full_cards, &Card.name/1)
    {lowest_card, highest_card} = uniq_cards |> Enum.min_max_by(&Card.cost/1)
    lowest_cost = Card.cost(lowest_card)
    highest_cost = Card.cost(highest_card)
    lowest = Enum.filter(uniq_cards, &(Card.cost(&1) == lowest_cost))
    highest = Enum.filter(uniq_cards, &(Card.cost(&1) == highest_cost))
    {do_return(lowest, return), do_return(highest, return)}
  end

  def lowest_highest_cost_cards(_, _), do: {[], []}

  @spec cute?(card_info | Card.t(), integer) :: boolean
  def cute?(cards_or_card_info, min_count \\ 2)
  def cute?(%{full_cards: full_cards}, min_count), do: cute?(full_cards, min_count)

  def cute?(cards, min_count) do
    cute_minions =
      cards
      |> Enum.uniq_by(&Card.name/1)
      |> Enum.filter(&Card.cute?/1)

    Enum.count(cute_minions) >= min_count
  end

  @spec do_return([Card.t()], :full_cards | :name) :: [Card.t()] | [String.t()]
  defp do_return(cards, :full_cards), do: cards
  defp do_return(cards, :name), do: Enum.map(cards, & &1.name)
end
