defmodule Backend.Repo.Migrations.SeedDustFreeCards do
  use Ecto.Migration

  def up do
    sql = """
    UPDATE public.hs_cards
    SET dust_free = true
    WHERE collectible
    -- minion, spell, weapon, location
    AND card_type_id IN (4,5,7,39)
    AND name IN
    (
      'C''Thun',
      'Beckoner of Evil',
      'Marin the Fox',
      'Galakrond, the Unspeakable',
      'Galakrond, the Nightmare',
      'Galakrond, the Tempest',
      'Galakrond, the Wretched',
      'Galakrond, the Unbreakable',
      'Sathrovarr',
      'Shield of Galakrond',
      'Kael''thas Sunstrider',
      'Transfer Student',
      'Silas Darkmoon',
      'Mankrik',
      'Shadow Hunter Vol''jin',
      'Lady Prestor',
      'Flightmaster Dungar',
      'Blademaster Okani',
      'Prince Renathal',
      'Sire Denathrius',
      'The Sunwell',
      'E.T.C., Band Manager',
      'Prison of Yogg-Saron',
      'Marin the Manager',
      'Thunderbringer',
      'Colifero the Artist',
      'Jaina''s Gift',
      'Rexxar''s Gift',
      'Arthas''s Gift',
      'Uther''s Gift',
      'Thrall''s Gift',
      'Garrosh''s Gift',
      'Illidan''s Gift',
      'Valeera''s Gift',
      'Malfurion''s Gift',
      'Gul''dan''s Gift',
      'Anduin''s Gift',
      'Harth Stonebrew'
    )
    """

    execute(sql)
  end

  def down do
  end
end
