defmodule Backend.Discord.Broadcast do
  use Ecto.Schema
  import Ecto.Changeset

  schema "broadcasts" do
    field :publish_token, :string
    field :subscribe_token, :string
    field :subscribed_urls, {:array, :string}, default: []

    timestamps()
  end

  @doc false
  def changeset(broadcast, attrs) do
    broadcast
    |> cast(attrs, [:publish_token, :subscribe_token, :subscribed_urls])
    |> validate_required([])
  end
end
