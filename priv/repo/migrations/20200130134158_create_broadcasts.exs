defmodule Backend.Repo.Migrations.CreateBroadcasts do
  use Ecto.Migration

  def change do
    create table(:broadcasts) do
      add :publish_token, :string
      add :subscribe_token, :string
      add :subscribed_urls, {:array, :string}

      timestamps()
    end
  end
end
