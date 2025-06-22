defmodule Backend.CollectionManager.Collection do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Backend.CollectionManager.Collection.Card
  alias Backend.USerManager.User
  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "hs_collections" do
    field :battletag, :string
    field :region, Ecto.Enum, values: [:AM, :AP, :EU, :CN, :unknown]
    field :public, :boolean, default: false
    field :update_received, :naive_datetime
    embeds_many(:cards, Card, on_replace: :delete)
    field :card_map, :map
    field :card_map_updated_at, :naive_datetime
  end

  def changeset(collection, attrs) do
    collection
    |> cast(attrs, [
      :region,
      :battletag,
      :public,
      :update_received,
      :card_map,
      :card_map_updated_at
    ])
    |> cast_embed(:cards)
    |> validate_required(:battletag)
  end

  def display(%{battletag: battletag, region: region}) do
    "#{battletag} - #{Backend.Blizzard.get_region_name(region)}"
  end

  @spec can_view?(__MODULE__, User.t() | nil) :: boolean
  def can_view?(%{public: true}, _), do: true

  def can_view?(%{battletag: coll_battletag}, %{battletag: user_battletag}),
    do: coll_battletag == user_battletag

  def can_view?(_, _), do: false
  @spec can_admin?(__MODULE__, User.t() | nil) :: boolean
  def can_admin?(%{battletag: coll_battletag}, %{battletag: user_battletag}),
    do: coll_battletag == user_battletag

  def can_admin?(_, _), do: false
end

defmodule Backend.CollectionManager.Collection.Card do
  @moduledoc "Handles info about a specific card in a specific collection"
  use Ecto.Schema
  import Ecto.Changeset

  @all_attrs [
    :dbf_id,
    :total_count,
    :plain_count,
    :premium_count,
    :diamond_count,
    :signature_count
  ]
  @primary_key false
  embedded_schema do
    field :dbf_id, :integer
    field :total_count, :integer
    field :plain_count, :integer
    field :premium_count, :integer
    field :diamond_count, :integer
    field :signature_count, :integer
  end

  def changeset(sideboard, attrs) do
    sideboard
    |> cast(Map.new(attrs), @all_attrs)
    |> validate_required(@all_attrs)
  end

  @spec merge_multiple([__MODULE__], dbf_id :: integer()) :: __MODULE__
  def merge_multiple(cards, dbf_id) do
    %__MODULE__{
      dbf_id: dbf_id,
      total_count: Enum.sum_by(cards, & &1.total_count),
      plain_count: Enum.sum_by(cards, & &1.plain_count),
      premium_count: Enum.sum_by(cards, & &1.premium_count),
      diamond_count: Enum.sum_by(cards, & &1.diamond_count),
      signature_count: Enum.sum_by(cards, & &1.signature_count)
    }
  end

  @spec group_and_merge([__MODULE__], group_fun :: (__MODULE__ -> any())) :: [__MODULE__]
  def group_and_merge(cards, group_fun) do
    cards
    |> Enum.group_by(group_fun)
    |> Enum.map(&merge/1)
  end

  defp merge({dbf_id, multiple}), do: merge_multiple(multiple, dbf_id)

  def init(cards) when is_list(cards), do: Enum.map(cards, &init/1)
  def init(%__MODULE__{} = card), do: card

  def init(%{
        dbf_id: dbf_id,
        total_count: total_count,
        plain_count: plain_count,
        premium_count: premium_count,
        diamond_count: diamond_count,
        signature_count: signature_count
      }) do
    %__MODULE__{
      dbf_id: dbf_id,
      total_count: total_count,
      plain_count: plain_count,
      premium_count: premium_count,
      diamond_count: diamond_count,
      signature_count: signature_count
    }
  end
end
