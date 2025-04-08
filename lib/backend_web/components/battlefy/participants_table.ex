defmodule Components.Battlefy.ParticipantsTable do
  @moduledoc false
  use BackendWeb, :surface_live_component
  prop(participants, :list, required: true)
  prop(highlight, :string, default: nil)
  prop(filters, :map, default: %{})
  prop(tournament_id, :string, required: true)
  alias Components.SurfaceBulma.Table
  alias Components.SurfaceBulma.Table.Column
  alias Components.Helper
  # prop(sort, :str
  # prop(sort_direction, :string, :logged_in)
  # prop(search, :def)

  def render(assigns) do
    ~F"""
      <div>
      <Table id={"participants_table_#{@id}"} row_class={row_class(@highlight)} data={{row, index} <- rows(@participants, @filters) |> Enum.with_index()} striped>
        <Column label="Player" sort_by={& elem(&1, 0).player}><Helper.player_link name={row.player} link={~p"/battlefy/tournament/#{@tournament_id}/player/#{row.player}"}/></Column>
        <Column label="Registered #" sort_by={{& elem(&1, 0).registered_at, NaiveDateTime}}>#{row.registered_at_num}</Column>
        <Column label="Registered At" sort_by={{& elem(&1, 0).registered_at, NaiveDateTime}}><Helper.datetime datetime={row.registered_at} /></Column>
        <Column label="Checked In #"><Helper.checkmark show={row.checked_in} /> <span :if={row.checked_in}>#{row.checked_in_num}</span></Column>
      </Table>
      </div>
    """
  end

  defp row_class(battletag) when is_binary(battletag) do
    fn
      %{player: player}, _ when player == battletag -> "is-selected"
      {%{player: player}, _}, _ when player == battletag -> "is-selected"
      _, _ -> ""
    end
  end

  defp row_class(_), do: nil

  def rows(participants, filters) do
    participants
    |> Enum.map(fn p ->
      %{
        player: p.name,
        registered_at: p.created_at,
        checked_in_at: p.checked_in_at,
        checked_in: !!p.checked_in_at,
        checked_in_num: nil
      }
    end)
    |> add_position(:checked_in_num, &to_iso(&1.registered_at), & &1.checked_in_at)
    |> add_position(:registered_at_num, &to_iso(&1.registered_at))
    |> filter(filters)
  end

  defp to_iso(%NaiveDateTime{} = time), do: NaiveDateTime.to_iso8601(time)
  defp to_iso(_), do: nil

  defp add_position(participants, new_field, sort_by, filter \\ & &1) do
    participants
    |> Enum.sort_by(sort_by)
    |> Enum.reduce({1, []}, fn row, {next_index, acc} ->
      if filter.(row) do
        {
          next_index + 1,
          [Map.put(row, new_field, next_index) | acc]
        }
      else
        {next_index, [row | acc]}
      end
    end)
    |> elem(1)
    |> Enum.reverse()
  end

  defp filter(participants, filters) do
    Enum.reduce(filters, participants, &do_filter/2)
  end

  defp do_filter({"search", any}, participants) when any in ["", nil], do: participants

  defp do_filter({"search", search}, participants) do
    search_lower = String.downcase(search)
    Enum.filter(participants, &(String.downcase(&1.player) =~ search_lower))
  end

  defp do_filter({"checked_in", any}, participants) when any in ["any", nil], do: participants

  defp do_filter({"checked_in", checked_in}, participants) do
    parsed =
      case checked_in do
        yes when yes in ["true", true, "yes"] -> true
        no when no in ["false", true, "no"] -> false
      end

    Enum.filter(participants, &(!!&1.checked_in_at == parsed))
  end
end
