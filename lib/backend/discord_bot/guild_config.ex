defmodule Backend.DiscordBot.GuildConfig do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:guild_id, :integer, autogenerate: false}
  schema "guild_config" do
    field :battletags, {:array, :string}, default: []
    field :channel_id, :integer
    field :last_message_id, :integer, default: nil

    timestamps()
  end

  @doc false
  def changeset(guild_config, attrs) do
    guild_config
    |> cast(attrs, [:guild_id, :channel_id, :battletags, :last_message_id])
    |> validate_required([:guild_id])
  end
end
