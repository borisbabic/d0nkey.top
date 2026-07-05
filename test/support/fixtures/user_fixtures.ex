defmodule Backend.UserFixtures do
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        battletag: Ecto.UUID.generate(),
        bnet_id: :rand.uniform(2_147_483_646),
        decklist_options: %{
          preferred_deckcode: "short"
        }
      })
      |> Backend.UserManager.create_user()

    user
  end
end
