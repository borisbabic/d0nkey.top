defmodule Backend.Tournaments.HSEsportsFixtures do
  @moduledoc """
  Sample CSV fixtures for HSEsports tournament tests.
  Allows tests to run self-contained without relying on files on disk.
  """

  @sample_csv """
  Stage,Match #,Game #,Player 1,P1 Deck Used,Player 2,P2 Deck Used,Winner,Bans
  Group A,Initial Match 1,1,McBanterFace,Demon Hunter,Soyorin,Demon Hunter,Soyorin,P1 Ban
  ,,2,McBanterFace,Demon Hunter,Soyorin,Druid,McBanterFace,Warrior
  ,,3,McBanterFace,Druid,Soyorin,Druid,Soyorin,P2 Ban
  ,,4,McBanterFace,Druid,Soyorin,Warlock,McBanterFace,Warrior
  ,,5,McBanterFace,Warlock,Soyorin,Warlock,Soyorin,
  Group A,Initial Match 2,1,,,,,,P1 Ban
  ,,2,,,,,,
  ,,3,,,,,,P2 Ban
  ,,4,,,,,,
  ,,5,,,,,,
  Group A,Winners Match,1,,,,,,P1 Ban
  ,,2,,,,,,
  ,,3,,,,,,P2 Ban
  ,,4,,,,,,
  ,,5,,,,,,
  Group A,Elimination Match,1,,,,,,P1 Ban
  ,,2,,,,,,
  ,,3,,,,,,P2 Ban
  ,,4,,,,,,
  ,,5,,,,,,
  Group A,Decider Match,1,,,,,,P1 Ban
  ,,2,,,,,,
  ,,3,,,,,,P2 Ban
  ,,4,,,,,,
  ,,5,,,,,,
  Group B,Initial Match 1,1,,,,,,P1 Ban
  ,,2,,,,,,
  ,,3,,,,,,P2 Ban
  ,,4,,,,,,
  ,,5,,,,,,
  Group B,Initial Match 2,1,,,,,,P1 Ban
  ,,2,,,,,,
  ,,3,,,,,,P2 Ban
  ,,4,,,,,,
  ,,5,,,,,,
  Group B,Winners Match,1,,,,,,P1 Ban
  ,,2,,,,,,
  ,,3,,,,,,P2 Ban
  ,,4,,,,,,
  ,,5,,,,,,
  Group B,Elimination Match,1,,,,,,P1 Ban
  ,,2,,,,,,
  ,,3,,,,,,P2 Ban
  ,,4,,,,,,
  ,,5,,,,,,
  Group B,Decider Match,1,,,,,,P1 Ban
  ,,2,,,,,,
  ,,3,,,,,,P2 Ban
  ,,4,,,,,,
  ,,5,,,,,,
  Group C,Initial Match 1,1,,,,,,P1 Ban
  ,,2,,,,,,
  ,,3,,,,,,P2 Ban
  ,,4,,,,,,
  ,,5,,,,,,
  Group C,Initial Match 2,1,,,,,,P1 Ban
  ,,2,,,,,,
  ,,3,,,,,,P2 Ban
  ,,4,,,,,,
  ,,5,,,,,,
  Group C,Winners Match 3,1,,,,,,P1 Ban
  ,,2,,,,,,
  ,,3,,,,,,P2 Ban
  ,,4,,,,,,
  ,,5,,,,,,
  Group C,Elimination Match,1,,,,,,P1 Ban
  ,,2,,,,,,
  ,,3,,,,,,P2 Ban
  ,,4,,,,,,
  ,,5,,,,,,
  Group C,Decider Match,1,,,,,,P1 Ban
  ,,2,,,,,,
  ,,3,,,,,,P2 Ban
  ,,4,,,,,,
  ,,5,,,,,,
  Group D,Initial Match 1,1,,,,,,P1 Ban
  ,,2,,,,,,
  ,,3,,,,,,P2 Ban
  ,,4,,,,,,
  ,,5,,,,,,
  Group D,Initial Match 2,1,,,,,,P1 Ban
  ,,2,,,,,,
  ,,3,,,,,,P2 Ban
  ,,4,,,,,,
  ,,5,,,,,,
  Group D,Winners Match 3,1,,,,,,P1 Ban
  ,,2,,,,,,
  ,,3,,,,,,P2 Ban
  ,,4,,,,,,
  ,,5,,,,,,
  Group D,Elimination Match,1,,,,,,P1 Ban
  ,,2,,,,,,
  ,,3,,,,,,P2 Ban
  ,,4,,,,,,
  ,,5,,,,,,
  Group D,Decider Match,1,,,,,,P1 Ban
  ,,2,,,,,,
  ,,3,,,,,,P2 Ban
  ,,4,,,,,,
  ,,5,,,,,,
  BlizzCon Finals,Quarterfinals 1,1,,,,,,P1 Ban
  ,,2,,,,,,
  ,,3,,,,,,P2 Ban
  ,,4,,,,,,
  ,,5,,,,,,
  BlizzCon Finals,Quarterfinals 2,1,,,,,,P1 Ban
  ,,2,,,,,,
  ,,3,,,,,,P2 Ban
  ,,4,,,,,,
  ,,5,,,,,,
  BlizzCon Finals,Quarterfinals 3,1,,,,,,P1 Ban
  ,,2,,,,,,
  ,,3,,,,,,P2 Ban
  ,,4,,,,,,
  ,,5,,,,,,
  BlizzCon Finals,Quarterfinals 4,1,,,,,,P1 Ban
  ,,2,,,,,,
  ,,3,,,,,,P2 Ban
  ,,4,,,,,,
  ,,5,,,,,,
  BlizzCon Finals,Semifinals 1,1,,,,,,P1 Ban
  ,,2,,,,,,
  ,,3,,,,,,P2 Ban
  ,,4,,,,,,
  ,,5,,,,,,
  BlizzCon Finals,Semifinals 2,1,,,,,,P1 Ban
  ,,2,,,,,,
  ,,3,,,,,,P2 Ban
  ,,4,,,,,,
  ,,5,,,,,,
  BlizzCon Finals,Grand Finals,1,,,,,,P1 Ban
  ,,2,,,,,,
  ,,3,,,,,,P2 Ban
  ,,4,,,,,,
  ,,5,,,,,,
  """

  @doc """
  Returns a sample full 27-match CSV string.
  """
  def sample_csv, do: @sample_csv

  @doc """
  Returns a sample CSV string where a match is ongoing (e.g. 1-0 score, incomplete).
  """
  def sample_ongoing_csv do
    """
    Stage,Match #,Game #,Player 1,P1 Deck Used,Player 2,P2 Deck Used,Winner,Bans
    Group A,Initial Match 1,1,McBanterFace,Demon Hunter,Soyorin,Demon Hunter,Soyorin,P1 Ban
    ,,2,McBanterFace,Demon Hunter,Soyorin,Druid,,Warrior
    ,,3,McBanterFace,Druid,Soyorin,Druid,,P2 Ban
    ,,4,McBanterFace,Druid,Soyorin,Warlock,,Warrior
    ,,5,McBanterFace,Warlock,Soyorin,Warlock,,
    """
  end
end
