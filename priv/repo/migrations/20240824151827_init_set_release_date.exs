defmodule Backend.Repo.Migrations.InitSetReleaseDate do
  use Ecto.Migration

  # Release dates as they were known when this migration was written.
  #
  # This list used to be read from Backend.Hearthstone and applied through the
  # Backend.Hearthstone.Set schema. That coupled the migration to the current
  # shape of hs_sets: once a later migration added a column, replaying the
  # migrations on a fresh database failed here, because the schema selected a
  # column the table did not have yet.
  #
  # The data is inlined and written with plain SQL so this migration keeps
  # describing the database as it was at this point in history.
  @release_dates [
    {"Perils in Paradise", ~D[2024-07-23]},
    {"Whizbang's Workshop", ~D[2024-03-19]},
    {"Event", ~D[2024-02-13]},
    {"Showdown in the Badlands", ~D[2023-11-14]},
    {"TITANS", ~D[2023-08-01]},
    {"Festival of Legends", ~D[2023-04-11]},
    {"Core", ~D[2021-03-30]},
    {"Caverns of Time", ~D[2023-08-31]},
    {"March of the Lich King", ~D[2022-12-06]},
    {"Path of Arthas", ~D[2022-12-06]},
    {"Murder at Castle Nathria", ~D[2022-08-02]},
    {"Voyage to the Sunken City", ~D[2022-04-12]},
    {"Fractured in Alterac Valley", ~D[2021-12-07]},
    {"United in Stormwind", ~D[2021-08-03]},
    {"Legacy", ~D[2021-03-30]},
    {"Forged in the Barrens", ~D[2021-03-30]},
    {"Madness at the Darkmoon Faire", ~D[2020-11-17]},
    {"Scholomance Academy", ~D[2020-08-06]},
    {"Demon Hunter Initiate", ~D[2020-04-07]},
    {"Ashes of Outland", ~D[2020-04-07]},
    {"Galakrond’s Awakening", ~D[2020-01-21]},
    {"Descent of Dragons", ~D[2019-12-10]},
    {"Saviors of Uldum", ~D[2019-08-06]},
    {"Rise of Shadows", ~D[2019-04-09]},
    {"Rastakhan’s Rumble", ~D[2018-12-04]},
    {"The Boomsday Project", ~D[2018-08-07]},
    {"The Witchwood", ~D[2018-04-12]},
    {"Kobolds and Catacombs", ~D[2017-12-07]},
    {"Knights of the Frozen Throne", ~D[2017-08-10]},
    {"Journey to Un’Goro", ~D[2017-04-06]},
    {"Mean Streets of Gadgetzan", ~D[2016-12-01]},
    {"One Night in Karazhan", ~D[2016-08-11]},
    {"Whispers of the Old Gods", ~D[2016-04-26]},
    {"League of Explorers", ~D[2015-11-12]},
    {"The Grand Tournament", ~D[2015-08-24]},
    {"Blackrock Mountain", ~D[2015-04-02]},
    {"Goblins vs Gnomes", ~D[2014-12-08]},
    {"Curse of Naxxramas", ~D[2014-07-22]},
    {"Legacy", ~D[2014-03-14]}
  ]

  def up do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    # List.keyfind/3 returned the first match, so keep the same winner for the
    # names that appear twice.
    for {name, release_date} <- Enum.uniq_by(@release_dates, &elem(&1, 0)) do
      repo().query!(
        "UPDATE hs_sets SET release_date = $1, updated_at = $2 WHERE name = $3",
        [release_date, now, name]
      )
    end
  end

  def down do
    :ok
  end
end
