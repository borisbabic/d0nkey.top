defmodule Backend.CollectionManager.CollectionDto do
  @moduledoc false
  use TypedStruct
  alias Backend.CollectionManager.CollectionDto.Card

  typedstruct do
    field :battletag, String.t()
    field :region, integer()
    field :cards, [Card.t()]
    field :updated, NaiveDateTime.t()
  end

  @spec from_raw_map(map(), NaiveDateTime.t() | String.t()) ::
          {:ok, t()} | {:error, atom() | String.t()}
  def from_raw_map(map, updated_raw) do
    with {:ok, cards} <- parse_cards(map),
         {:ok, battletag} <- battletag(map),
         {:ok, region} <- region(map),
         {:ok, updated} <- updated(updated_raw) do
      {
        :ok,
        %__MODULE__{
          cards: cards,
          battletag: battletag,
          region: region,
          updated: updated
        }
      }
    end
  end

  defp updated(%NaiveDateTime{} = u), do: {:ok, u}

  defp updated(updated) when is_binary(updated) do
    NaiveDateTime.from_iso8601(updated)
  end

  defp updated(_), do: {:error, :invalid_date}

  defp battletag(%{"battleTag" => bt}), do: {:ok, bt}
  defp battletag(%{"battletag" => bt}), do: {:ok, bt}
  defp battletag(_), do: {:error, :cant_extract_battletag}

  defp region(map) do
    (Map.get(map, "region") || Map.get(map, "BnetRegion") || Map.get(map, "bnetRegion"))
    |> parse_region()
  end

  defp parse_region(region) when is_integer(region), do: {:ok, region}

  defp parse_region(region) when is_binary(region) do
    case Integer.parse(region) do
      {int, _rem} when is_integer(int) -> {:ok, int}
      _ -> {:error, :region_is_not_an_integer}
    end
  end

  defp parse_region(_), do: {:error, :cant_extract_region}

  @spec parse_cards([map()]) :: {:ok, [Card.t()]} | {:error, atom() | String.t()}
  defp parse_cards(%{"cards" => cards}) do
    Enum.reduce_while(cards, {:ok, []}, fn raw_card, {:ok, carry} ->
      case Card.from_raw_map(raw_card) do
        {:ok, card} -> {:cont, {:ok, add_card(carry, card)}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  defp parse_cards(_), do: {:error, :missing_cards}

  @spec add_card([Card.t()], Card.t()) :: [Card.t()]
  defp add_card(cards, card) do
    fabled_group = Backend.Hearthstone.CardBag.fabled_group(card.dbf_id)

    case fabled_group do
      [] ->
        [card | cards]

      group ->
        Enum.map(group, fn dbf_id ->
          Card.new(dbf_id, card)
        end)
        |> Kernel.++(cards)
    end
  end
end

defmodule Backend.CollectionManager.CollectionDto.Card do
  @moduledoc false
  use TypedStruct

  typedstruct do
    field :dbf_id, integer()
    field :total_count, integer()
    field :plain_count, integer()
    field :premium_count, integer()
    field :diamond_count, integer()
    field :signature_count, integer()
  end

  @spec from_raw_map(map()) :: {:ok, t()} | {:error, String.t()}
  def from_raw_map(%{"id" => id} = map) do
    case Backend.HearthstoneJson.get_dbf_by_card_id(id) do
      dbf_id when is_integer(dbf_id) ->
        plain_count = map["count"] || 0
        premium_count = map["premiumCount"] || map["premium_count"] || 0
        diamond_count = map["diamondCount"] || map["diamond_count"] || 0
        signature_count = map["signatureCount"] || map["signature_count"] || 0

        {:ok,
         new(dbf_id, %{
           plain_count: plain_count,
           premium_count: premium_count,
           diamond_count: diamond_count,
           signature_count: signature_count
         })}

      _ ->
        {:error, "no card found with id #{id}"}
    end
  end

  @base_counts %{plain_count: 0, premium_count: 0, diamond_count: 0, signature_count: 0}
  def new(dbf_id, counts_to_merge \\ %{}) do
    counts = Map.merge(@base_counts, counts_to_merge)

    %__MODULE__{
      dbf_id: dbf_id,
      total_count:
        counts.plain_count + counts.premium_count + counts.diamond_count + counts.signature_count,
      plain_count: counts.plain_count,
      premium_count: counts.premium_count,
      diamond_count: counts.diamond_count,
      signature_count: counts.signature_count
    }
  end
end
