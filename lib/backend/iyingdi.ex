defmodule Backend.Iyingdi do
  @moduledoc false
  alias Backend.Hearthstone
  alias Iyingdi.Hearthstone.Api
  alias Iyingdi.Hearthstone.Deck, as: IDeck

  @tournament_source "iyingdi"

  def lineup_url(set_id) do
    "/tournament-lineups/#{@tournament_source}/#{set_id}"
  end

  def ensure_lineups(set_id) do
    if !Hearthstone.has_lineups?(set_id, @tournament_source) do
      import_lineups(set_id)
    end
  end

  def get_or_create_lineups(set_id) do
    ensure_lineups(set_id)

    Hearthstone.lineups([{"tournament_source", @tournament_source}, {"tournament_id", set_id}])
  end

  def import_lineups(set_id_or_url) do
    set_id = set_id(set_id_or_url)

    set_id
    |> get_decks()
    |> insert_lineups(set_id)
  end

  @spec get_decks(String.t()) :: [IDeck.t()]
  def get_decks(set_id) do
    {:ok, decks} = Api.fetch_decks(set_id)
    decks
  end

  def insert_lineups(decks, set_id, opts \\ []) do
    tournament_source = Keyword.get(opts, :tournament_source, @tournament_source)

    Enum.group_by(decks, & &1.player)
    |> Enum.map(fn {_group, [%{player: player} | _] = decks} ->
      deckstrings = Enum.map(decks, & &1.code)

      attrs = %{
        name: player,
        display_name: display_name(player),
        tournament_source: tournament_source,
        tournament_id: set_id
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
    iex> Backend.Iyingdi.set_id("https://www.iyingdi.com/web/tools/hearthstone/decks/setdetail?btypes=home_allset&setid=1644750")
    "1644750"
  """
  @spec set_id(String.t()) :: String.t()
  def set_id(set_id_or_url) do
    extract_set_id_from_url(set_id_or_url) || set_id_or_url
  end

  def extract_set_id_from_url(url) do
    case Regex.named_captures(~r/setid=(?<set_id>\d+)/, url) do
      %{"set_id" => set_id} -> set_id
      _ -> nil
    end
  end
end
