defmodule Components.Form.RankSelect do
  @moduledoc """
  Hearthstone rank picker: a row of level pills (Bronze-Legend), a grid of sub-rank pills for
  the picked level, and a legend number input when "Legend" is picked. Renders two hidden form
  fields (`rank_field` and `legend_rank_field`) so it can sit inside any outer `<form>`/`<.form>`.
  """
  use BackendWeb, :surface_live_component
  alias Hearthstone.DeckTracker

  prop(rank, :integer, default: nil)
  prop(legend_rank, :integer, default: 0)
  prop(rank_field, :atom, default: :rank)
  prop(legend_rank_field, :atom, default: :legend_rank)
  prop(rank_title, :string, default: "Rank")

  data(rank_parts, :any)

  def update(assigns, socket) do
    {:ok,
     assign(
       socket,
       assigns |> Util.vals_to_int_or_orig([:rank, :legend_rank]) |> set_rank_parts()
     )}
  end

  defp set_rank_parts(%{rank: r} = assigns) when is_integer(r) do
    Map.put(assigns, :rank_parts, DeckTracker.convert_rank(r))
  end

  defp set_rank_parts(assigns), do: Map.put(assigns, :rank_parts, {nil, nil})

  def render(assigns) do
    ~F"""
      <div id={@id} class="tw-flex tw-flex-col tw-gap-1.5">
        <div class="tw-flex tw-flex-wrap tw-gap-1" role="group" aria-label={@rank_title}>
          <button
            :for={level <- levels()}
            type="button"
            phx-target={@myself}
            phx-click="change_level"
            phx-value-level={level}
            aria-pressed={to_string(matches_level?(@rank_parts, level))}
            class={rank_pill_class(matches_level?(@rank_parts, level))}
          >
            {level}
          </button>
        </div>

        <div :if={num = num_sub_ranks(@rank_parts)} class="tw-grid tw-grid-cols-5 tw-gap-1">
          <button
            :for={rank <- 1..num}
            type="button"
            phx-target={@myself}
            phx-click="change_rank"
            phx-value-rank={rank}
            aria-pressed={to_string(matches_rank?(@rank_parts, rank))}
            class={rank_pill_class(matches_rank?(@rank_parts, rank))}
          >
            {rank}
          </button>
        </div>

        <input
          :if={@rank_parts == :Legend}
          type="number"
          name={@legend_rank_field}
          value={@legend_rank || 0}
          placeholder="Legend rank #"
          aria-label="Legend rank number"
          class="input has-text-black tw-w-full"
        />
        <input :if={@rank_parts != :Legend} type="hidden" name={@legend_rank_field} value={@legend_rank || 0} />
        <input type="hidden" name={@rank_field} value={@rank} />
      </div>
    """
  end

  defp levels do
    [
      :Legend,
      :Diamond,
      :Platinum,
      :Gold,
      :Silver,
      :Bronze
    ]
  end

  defp rank_pill_class(active?) do
    base = "tw-rounded-md tw-px-2 tw-py-1 tw-text-xs tw-font-semibold tw-transition-colors tw-border"

    if active? do
      base <> " tw-bg-sky-500/20 tw-border-sky-500 tw-text-sky-300"
    else
      base <> " tw-bg-slate-800 tw-border-slate-700 tw-text-slate-300 hover:tw-border-slate-500"
    end
  end

  def handle_event(
        "change_rank",
        %{"rank" => rank_raw},
        %{assigns: %{rank_parts: {level, _old_rank}}} = socket
      ) do
    {rank, _} = Integer.parse(rank_raw)
    {:noreply, assign(socket, rank_parts: {level, rank}) |> assign_rank()}
  end

  def handle_event("change_level", %{"level" => level_raw}, socket) do
    parts =
      case level_raw do
        "Legend" ->
          :Legend

        l when l in ["Diamond", "Platinum", "Gold", "Silver", "Bronze"] ->
          {String.to_existing_atom(l), nil}
      end

    {:noreply, assign(socket, rank_parts: parts) |> assign_rank()}
  end

  defp matches_level?({l, _}, level) when l == level, do: true
  defp matches_level?(l, level) when l == level, do: true
  defp matches_level?(_, _), do: false

  defp matches_rank?({_, r}, rank) when r == rank, do: true
  defp matches_rank?(_, _), do: false

  defp num_sub_ranks({level, _}) when level in [:Diamond, :Platinum, :Gold, :Silver, :Bronze],
    do: 10

  defp num_sub_ranks(_), do: nil

  defp assign_rank(%{assigns: %{rank_parts: :Legend}} = socket), do: assign(socket, rank: 51)

  defp assign_rank(%{assigns: %{rank_parts: parts}} = socket) do
    case DeckTracker.convert_rank(parts) do
      nil -> socket
      rank -> assign(socket, rank: rank, legend_rank: 0)
    end
  end
end
