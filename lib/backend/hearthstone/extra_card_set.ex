defmodule Backend.Hearthstone.ExtraCardSet do
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.Hearthstone.Card
  alias Backend.Hearthstone.Set

  @primary_key false
  schema "hs_extra_card_set" do
    belongs_to :card_set, Set
    belongs_to :card, Card
  end

  def changeset(ecs, attrs) do
    ecs
    |> cast(attrs, [:card_set_id, :card_id])
    |> validate_required([:card_set_id, :card_id])
  end
end
