defmodule Backend.Discord.Broadcast do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "broadcasts" do
    field :publish_token, :string
    field :subscribe_token, :string
    field :subscribed_urls, {:array, :string}, default: []

    timestamps()
  end

  @doc false
  def new() do
    cast(
      %__MODULE__{},
      %{publish_token: Ecto.UUID.generate(), subscribe_token: Ecto.UUID.generate()},
      [:publish_token, :subscribe_token]
    )
    |> validate_required([:subscribe_token, :publish_token])
  end

  @doc false
  def changeset(broadcast, attrs) do
    broadcast
    |> cast(attrs, [:publish_token, :subscribe_token, :subscribed_urls])
    |> validate_required([:subscribe_token, :publish_token])
  end
end
