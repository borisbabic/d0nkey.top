defmodule Backend.OldBattletagFixtures do
  @moduledoc false
  alias Backend.Battlenet.OldBattletag
  alias Ecto.Multi
  alias Backend.Repo

  def old_battletags_chain_fixtures(
        [first | rest] \\ ["first#1111", "second#2222", "third#3333", "fourth#4444"],
        base_attrs \\ %{source: "fixtures"}
      ) do
    {multi, _} =
      Enum.reduce(rest, {Multi.new(), first}, fn new_battletag, {multi, old_battletag} ->
        attrs = base_attrs |> Map.merge(%{old_battletag: old_battletag, new_battletag: new_battletag})
        cs = OldBattletag.changeset(%OldBattletag{}, attrs)
        {Multi.insert(multi, new_battletag, cs), new_battletag}
      end)

    Repo.transact(multi)
  end
end
