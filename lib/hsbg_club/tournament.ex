defmodule HSBGClub.Tournament do
  @moduledoc false
  use TypedStruct

  @base_url "https://hsbgclub.com"
  # anonymous visitors don't have a timezone set, so times are presumably shown in UTC
  @time_zone "Etc/UTC"

  typedstruct do
    field(:id, String.t())
    field(:name, String.t())
    field(:date, NaiveDateTime.t())
    field(:mode, String.t() | nil)
    field(:max_players, integer() | nil)
    field(:type, String.t() | nil)
    field(:prize, String.t() | nil)
  end

  def link(%{id: id}), do: link(id)

  def link(id) when is_binary(id) or is_integer(id),
    do: "#{@base_url}/TournamentInfo?TourneyID=#{id}"

  @doc "Links to the score sheet once the tournament has started, before that to the info page"
  def standings_link(%{id: id, date: date}) do
    if :lt == NaiveDateTime.compare(date, NaiveDateTime.utc_now()) do
      standings_link(id)
    else
      link(id)
    end
  end

  def standings_link(%{id: id}), do: standings_link(id)

  def standings_link(id) when is_binary(id) or is_integer(id),
    do: "#{@base_url}/TournamentScore?TourneyID=#{id}"

  def tags(_tour), do: [:battlegrounds]

  @spec from_cells([String.t()]) :: {:ok, t()} | {:error, any()}
  def from_cells([id, name, date_raw, mode, max_players, type, prize | _]) do
    with {_, ""} <- Integer.parse(id),
         {:ok, date} <- parse_date(date_raw) do
      tour = %__MODULE__{
        id: id,
        name: name,
        date: date,
        mode: mode,
        max_players: Util.to_int(max_players, nil),
        type: type,
        prize: prize
      }

      {:ok, tour}
    else
      {:error, _reason} = r -> r
      _ -> {:error, :unknown_error_parsing_hsbg_club_tournament}
    end
  end

  def from_cells(_), do: {:error, :invalid_hsbg_club_tournament_row}

  @spec parse_date(String.t()) :: {:ok, NaiveDateTime.t()} | {:error, any()}
  defp parse_date(date_raw) do
    with {:ok, local} <- Timex.parse(date_raw, "{M}/{D}/{YYYY} {h12}:{m}:{s} {AM}"),
         %DateTime{} = date <- Timex.to_datetime(local, @time_zone) do
      {:ok, date |> Timex.to_datetime("Etc/UTC") |> DateTime.to_naive()}
    else
      {:error, _} = r -> r
      _ -> {:error, :invalid_hsbg_club_date}
    end
  end
end
