defmodule Backend.Hearthstone.Lineup do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Backend.Hearthstone.Deck

  schema "lineups" do
    field :name, :string
    field :tournament_id, :string
    field :tournament_source, :string
    many_to_many :decks, Deck, join_through: "lineup_decks", on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(lineup, attrs, decks) do
    lineup
    |> cast(attrs, [:tournament_id, :tournament_source, :name])
    |> put_assoc(:decks, decks)
    |> validate_required([:tournament_id, :tournament_source, :name])
  end

  def stats(lineups) do
    lineups
    |> Enum.reduce(empty_stats_map(), fn l, c ->
      l.decks
      |> Enum.reduce(c, fn d, carry ->
        carry
        |> Map.update(d |> Deck.class(), 1, &(&1 + 1))
      end)
    end)
  end

  defp empty_stats_map() do
    %{
      "DEATHKNIGHT" => 0,
      "DEMONHUNTER" => 0,
      "DRUID" => 0,
      "HUNTER" => 0,
      "MAGE" => 0,
      "PALADIN" => 0,
      "PRIEST" => 0,
      "ROGUE" => 0,
      "SHAMAN" => 0,
      "WARLOCK" => 0,
      "WARRIOR" => 0
    }
  end
end
