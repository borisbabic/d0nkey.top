defmodule Backend.DiscordBot.GuildBattletags do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:guild_id, :integer, autogenerate: false}
  schema "guild_battletags" do
    field :battletags, {:array, :string}, default: []
    field :channel_id, :integer
    field :last_message_id, :integer, default: nil

    timestamps()
  end

  @doc false
  def changeset(guild_battletags, attrs) do
    guild_battletags
    |> cast(attrs, [:guild_id, :channel_id, :battletags, :last_message_id])
    |> validate_required([:guild_id])
  end
end
