defmodule Backend.CollectionManager do
  @moduledoc "Manages hearthstone collections"
  import Ecto.Query, warn: false
  alias Backend.Repo
  alias Backend.CollectionManager.CollectionDto
  alias Backend.CollectionManager.Collection

  @spec upsert_collection(CollectionDto.t()) ::
          {:ok, Collection.t()} | {:error, atom() | String.t()}
  def upsert_collection(dto) do
    attrs = dto_to_attrs(dto)
    cs = Collection.changeset(%Collection{}, attrs)

    with {:ok, %{battletag: bt, region: r}} <-
           Repo.insert(cs,
             on_conflict: on_conflict_update(attrs),
             conflict_target: [:battletag, :region]
           ) do
      {:ok, do_get_collection(bt, r)}
    end
  end

  defp on_conflict_update(%{region: nil}), do: :do_nothing

  defp on_conflict_update(attrs) do
    from c in Collection,
      where:
        c.battletag == ^attrs.battletag and not is_nil(c.region) and c.region == ^attrs.region,
      # doing it like this instead of a where clause means it still gets touched so we don't have to deal with stale nonesense and worry about the right struct being returned
      update: [
        set: [
          cards:
            fragment(
              "CASE ? < ? WHEN true THEN ? ELSE ? END",
              c.update_received,
              ^attrs.update_received,
              ^attrs.cards,
              c.cards
            ),
          update_received: fragment("GREATEST(?, ?)", ^attrs.update_received, c.update_received)
        ]
      ]
  end

  @spec dto_to_attrs(CollectionDto.t()) :: Map.t()
  defp dto_to_attrs(dto) do
    # merged_cards = CollectionDto.Card.group_and_merge(dto.cards, fn %{dbf_id: dbf_id} -> Backend.Hearthstone.canonical_id(dbf_id) end)
    %{
      battletag: dto.battletag,
      region: Hearthstone.DeckTracker.GameDto.region(dto.region),
      update_received: dto.updated || NaiveDateTime.utc_now(),
      cards: Enum.map(dto.cards, &Map.from_struct/1)
    }
  end

  @spec do_get_collection(String.t(), String.t() | atom()) :: Collection.t() | nil
  defp do_get_collection(battletag, region) do
    query =
      from c in Collection,
        where: c.battletag == ^battletag and c.region == ^region

    Repo.one(query)
  end
end
