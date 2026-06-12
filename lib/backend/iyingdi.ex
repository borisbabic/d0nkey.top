defmodule Backend.Iyingdi do
  @moduledoc false
  alias Iyingdi.Hearthstone.Api
  alias Iyingdi.Hearthstone.Deck, as: IDeck

  def import_lineups(set_id_or_url) do
    set_id_or_url
    |> get_decks()
    |> insert_lineups()
  end

  @spec get_decks(String.t()) :: [IDeck.t()]
  def get_decks(set_id_or_url) do
    set_id = extract_set_id(set_id_or_url)
    {:ok, decks} = Api.fetch_decks(set_id)
    decks
  end

  def insert_lineups(decks, opts \\ []) do
    tournament_source = Keyword.get(opts, :tournament_source, "iyingdi")

    Enum.group_by(decks, &(&1.set_name <> &1.player))
    |> Enum.map(fn {_group, [%{set_name: set_name, player: player} | _] = decks} ->
      deckstrings = Enum.map(decks, & &1.code)

      attrs = %{
        name: player,
        display_name: display_name(player),
        tournament_source: tournament_source,
        tournament_id: set_name
      }

      {attrs, deckstrings}
    end)
    |> Backend.Hearthstone.batch_insert_lineups()
  end

  @doc """
  If Hanzi add pinyin in parenthesis 
  If not return string
  ## Example
    iex> Backend.Iyingdi.display_name("小惕")
    "小惕 (xiǎotì)"
    iex> Backend.Iyingdi.display_name("D0nkey")
    "D0nkey"
  """
  @spec display_name(String.t()) :: String.t()
  def display_name(name) do
    pinyin = Hanyutils.to_marked_pinyin(name)

    if pinyin == name do
      name
    else
      "#{name} (#{pinyin})"
    end
  end

  @doc """
  If url with id extract it, otherwise return the string

  ## Example
    iex> Backend.Iyingdi.extract_set_id("https://www.iyingdi.com/web/tools/hearthstone/decks/setdetail?btypes=home_allset&setid=1644750")
    "1644750"
  """
  @spec extract_set_id(String.t()) :: String.t()
  def extract_set_id(set_id_or_url) do
    case Regex.named_captures(~r/setid=(?<set_id>\d+)/, set_id_or_url) do
      %{"set_id" => set_id} -> set_id
      _ -> set_id_or_url
    end
  end
end
