defmodule Components.Lineups.PopularityTable do
  @moduledoc false
  use BackendWeb, :surface_live_component
  alias Components.LivePatchDropdown
  alias Components.SurfaceBulma.Table
  alias Components.SurfaceBulma.Table.Column
  alias FunctionComponents.DeckComponents
  alias Backend.Hearthstone.Deck

  @default_deck_group_size 1
  prop(lineups, :list)
  prop(lineup_count, :integer)
  prop(standings_url, :string, required: false)
  prop(deck_group_size, :integer, default: @default_deck_group_size)

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:lineup_count, Enum.count(assigns.lineups))
      |> update(:deck_group_size, fn dgs -> Util.to_int(dgs, @default_deck_group_size) end)
    }
  end

  def render(assigns) do
    ~F"""
      <div>
        <LivePatchDropdown id="group_decks"
          options={group_decks_options(@lineups)}
          title={"# Decks Grouped"}
          param={"deck_group_size"}
          normalizer={&Util.to_int_or_orig/1}
          selected_as_title={false} />
        <Table id={"lineups_table_#{@id}"} data={{archetypes, count} <- lineups_freq(@lineups, @deck_group_size)} striped>
          <Column label={if @deck_group_size > 1, do: "Decks", else: "Deck"}>
            <div class="columns">
              <div class=" column is-narrow" :for={archetype <- archetypes}  >
                <DeckComponents.archetype archetype={archetype} />
              </div>
            </div>
          </Column>
          <Column label="Count">{count}</Column>
          <Column label="Popularity">{Util.percent(count, @lineup_count) |> Float.round(1)}%</Column>
        </Table>
      </div>
    """
  end

  defp lineups_freq(lineups, deck_group_size) do
    lineups
    |> Enum.flat_map(fn %{decks: decks} ->
      archetypes = Enum.map(decks, & Deck.archetype(&1) || Deck.class_name(&1))
      combinations(deck_group_size, archetypes)
    end)
    # keep class sort
    |> Enum.map(fn archetypes ->
      Enum.sort_by(archetypes, &{Deck.extract_class(&1), &1})
    end)
    |> Enum.frequencies()
    |> Enum.sort_by(&elem(&1, 1), :desc)
  end

  # defp deck_group_size(%{"deck_group_size" => deck_group_size}) when is_integer(deck_group_size), do: deck_group_size
  # defp deck_group_size(_), do: @default_deck_group_size

  defp group_decks_options(lineups) do
    max_size =
      case Enum.max_by(lineups, &Enum.count(&1.decks)) do
        %{decks: decks} when is_list(decks) -> Enum.count(decks)
        _ -> 1
      end

    if max_size < 2 do
      [1]
    else
      1..max_size |> Enum.to_list()
    end
  end

  defp combinations(0, _), do: [[]]
  defp combinations(_, []), do: []

  defp combinations(size, [head | tail]) do
    for(elem <- combinations(size - 1, tail), do: [head | elem]) ++ combinations(size, tail)
  end
end
