defmodule Backend.Yaytears do
  @moduledoc false
  alias Backend.Hearthstone.Deck

  @spec create_deckstrings_link(Backend.Battlefy.tournament_id(), Backend.Battlefy.battletag()) ::
          String.t()
  def create_deckstrings_link(tournament_id, battletag_full) do
    "https://www.yaytears.com/battlefy/#{tournament_id}/#{battletag_full |> URI.encode_www_form()}"
  end

  @spec create_tournament_link(Backend.Battlefy.tournament_id()) :: String.t()
  def create_tournament_link(tournament_id) do
    "https://www.yaytears.com/battlefy/#{tournament_id}"
  end

  def yt_link?(link) when is_binary(link), do: link =~ "yaytears.com"
  def yt_link?(_), do: false

  @doc """
  Extracts deckcodes from an yaytears link

  ## Example
  iex> Backend.Yaytears.extract_codes("example.com")
  []
  iex> Backend.Yaytears.extract_codes("yaytears.com/")
  []
  iex> Backend.Yaytears.extract_codes("yaytears.com/conquest/")
  []
  iex> Backend.Yaytears.extract_codes("https://www.yaytears.com/conquest/AAECAQcKS6IC3q0DwLkD%2BcIDn80Dk9ADq9QDtt4Dzt4DCpADogTUBP8H3KkD2a0DpLYDlc0D99QDtd4DAA%3D%3D.AAECAaIHBLIC9acDitAD2dEDDbQB7QKXBogH3QiGCY%2BXA%2FuiA6rLA6TRA9%2FdA%2BfdA%2FPdAwA%3D.AAECAa0GHh6XAskGigf2B9MK65sD%2FKMDmakDn6kD8qwDha0DgbEDiLEDjrEDkbEDmLYDk7oDm7oDr7oDyL4D3swDlc0Dy80D184D49ED%2B9ED%2FtED4t4D%2B98DAAA%3D.AAECAZ8FBpYJhMEDk9ADw9EDhd4DyOEDDJwClaYDyrgD%2FbgD6rkD67kD7LkDysEDlc0Dns0Dn80DwNEDAA%3D%3D")
  ["AAECAQcKS6IC3q0DwLkD+cIDn80Dk9ADq9QDtt4Dzt4DCpADogTUBP8H3KkD2a0DpLYDlc0D99QDtd4DAA==", "AAECAaIHBLIC9acDitAD2dEDDbQB7QKXBogH3QiGCY+XA/uiA6rLA6TRA9/dA+fdA/PdAwA=","AAECAa0GHh6XAskGigf2B9MK65sD/KMDmakDn6kD8qwDha0DgbEDiLEDjrEDkbEDmLYDk7oDm7oDr7oDyL4D3swDlc0Dy80D184D49ED+9ED/tED4t4D+98DAAA=", "AAECAZ8FBpYJhMEDk9ADw9EDhd4DyOEDDJwClaYDyrgD/bgD6rkD67kD7LkDysEDlc0Dns0Dn80DwNEDAA=="]
  """
  @spec extract_codes(String.t()) :: [String.t()]
  def extract_codes(link) do
    with %{path: path} when is_binary(path) <- link |> URI.parse(),
         <<"/conquest/"::binary, codes_part::binary>> <- URI.decode(path) do
      codes_part |> String.split(".") |> Enum.filter(&(bit_size(&1) > 0))
    else
      _ -> []
    end
  end

  @spec create_deckstrings_link(String.t()) :: String.t()
  def create_deckstrings_link(deckstrings) do
    codes_part =
      deckstrings
      |> Deck.shorten()
      |> Enum.join(".")
      |> URI.encode_www_form()

    "https://yaytears.com/conquest/#{codes_part}"
  end
end
