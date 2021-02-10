defmodule Backend.PlayerInfoMigrater do
  @moduledoc "Migrate old player info to the new system"
  alias Ecto.Multi
  alias Backend.MastersTour
  alias Backend.Battlenet.Battletag
  alias Backend.Repo
  @overrides {"old_overrides", 3000}
  @esports_earnings {"old_esports_earnings", 2000}
  @pn {"old_player_nationalities", 1000}
  def migrate() do
    migrate_player_nationalities()
    migrate_overrides()
    migrate_esports_earnings()
  end

  def migrate_esports_earnings() do
    {source, priority} = @esports_earnings

    Backend.EsportsEarnings.game_player_details(328)
    |> case do
      %{player_details: pd} -> pd
      _ -> []
    end
    |> Enum.filter(&(&1.country_code && &1.handle))
    |> Enum.group_by(& &1.handle)
    |> Enum.flat_map(fn {_, list} ->
      # If there are duplicates let us just ignore them all
      if 1 == list |> Enum.count(), do: list, else: []
    end)
    |> Enum.reduce(Multi.new(), fn %{country_code: cc, handle: h}, multi ->
      attrs = %{
        battletag_full: nil,
        battletag_short: h,
        country: cc,
        reported_by: source,
        priority: priority
      }

      cs =
        %Battletag{}
        |> Battletag.changeset(attrs)

      Multi.insert(multi, "esports_earnings_#{h}", cs)
    end)
    |> Repo.transaction()
  end

  def migrate_overrides() do
    {source, priority} = @overrides

    Backend.PlayerInfo.nationality_overrides()
    |> Enum.reduce(Multi.new(), fn {short, country}, multi ->
      attrs = %{
        battletag_full: nil,
        battletag_short: short,
        country: country,
        reported_by: source,
        priority: priority
      }

      cs =
        %Battletag{}
        |> Battletag.changeset(attrs)

      Multi.insert(multi, "override_#{short}", cs)
    end)
    |> Repo.transaction()
  end

  @spec migrate_player_nationalities([MasterTour.PlayerNationality.t()] | String.t() | atom()) ::
          any()
  def migrate_player_nationalities(pn) when is_list(pn) do
    pn
    |> Enum.reduce(Multi.new(), fn pn, multi ->
      multi
      |> migrate_pn(pn, pn.mt_battletag_full, "mt")
      |> migrate_pn(pn, pn.actual_battletag_full, "actual")
    end)
    |> Repo.transaction()
  end

  def migrate_player_nationalities(tour_stop),
    do: MastersTour.mt_player_nationalities(tour_stop) |> migrate_player_nationalities()

  def migrate_player_nationalities(),
    do: MastersTour.mt_player_nationalities() |> migrate_player_nationalities()

  @spec migrate_pn(Multi.t(), MastersTour.PlayerNationality.t(), String.t() | nil, String.t()) ::
          Multi.t()
  def migrate_pn(multi, _, nil, _), do: multi

  def migrate_pn(multi, pn, bt, append) do
    {source, _} = @pn

    attrs = %{
      battletag_full: bt,
      battletag_short: bt |> MastersTour.InvitedPlayer.shorten_battletag(),
      country: pn.nationality,
      reported_by: source,
      priority: pn_priority(pn)
    }

    cs =
      %Battletag{}
      |> Battletag.changeset(attrs)

    Multi.insert(multi, "pn_#{pn.tour_stop}_#{bt}_#{append}", cs)
  end

  @spec pn_priority(MastersTour.PlayerNationality.t()) :: integer()
  def pn_priority(%{tour_stop: tour_stop}) do
    {_, base} = @pn

    ts_priorities =
      MastersTour.TourStop.all()
      |> Enum.map(&(&1.id |> to_string()))
      |> Enum.with_index()
      |> Map.new()

    ts_string = tour_stop |> to_string()
    (ts_priorities |> Map.get(ts_string) || 0) + base
  end
end
