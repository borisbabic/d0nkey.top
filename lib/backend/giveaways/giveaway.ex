defmodule Backend.Giveaways.Giveaway do
  use Ecto.Schema
  import Ecto.Changeset
  alias Backend.Giveaways.GiveawayEntry
  alias Backend.UserManager.User

  schema "giveaways" do
    field :name, :string
    field :description, :string, default: nil
    field :config, :map
    field :deadline, :naive_datetime
    field :number_of_winners, :integer, default: 1
    field :codes, {:array, :string}, default: []
    belongs_to :creator, User

    many_to_many(:pool, GiveawayEntry,
      join_through: "giveaway_entries",
      on_replace: :delete
    )

    timestamps()
  end

  @doc false
  def changeset(giveaway, attrs) do
    attrs = normalize_codes_attr(attrs)

    giveaway
    |> cast(attrs, [:name, :config, :deadline, :creator_id, :number_of_winners, :description, :codes])
    |> validate_required([:name, :deadline, :creator_id])
  end

  def normalize_codes(nil), do: []

  def normalize_codes(codes) when is_list(codes) do
    codes
    |> Enum.map(&to_string/1)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end

  def normalize_codes(codes) when is_binary(codes) do
    codes
    |> String.split(~r/\r?\n/)
    |> normalize_codes()
  end

  def normalize_codes(_), do: []

  defp normalize_codes_attr(attrs) when is_map(attrs) do
    cond do
      Map.has_key?(attrs, :codes) ->
        Map.put(attrs, :codes, normalize_codes(Map.get(attrs, :codes)))

      Map.has_key?(attrs, "codes") ->
        Map.put(attrs, "codes", normalize_codes(Map.get(attrs, "codes")))

      true ->
        attrs
    end
  end

  defp normalize_codes_attr(attrs), do: attrs
end
