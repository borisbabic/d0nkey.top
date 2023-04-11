defmodule Components.Form.RankSelect do
  @moduledoc "Hearthstone Rank Select. Expects Surface.Components.Form in context"
  use BackendWeb, :surface_live_component
  alias Surface.Components.Form.HiddenInput
  alias Surface.Components.Form.NumberInput
  alias Components.Dropdown
  alias Hearthstone.DeckTracker
  prop(form, :form, default: nil)
  # prop form, :form, from_context: {Surface.Components.Form, :form}
  prop(rank, :integer, default: nil)
  prop(legend_rank, :integer, default: 0)
  prop(rank_field, :atom, default: :rank)
  prop(legend_rank_field, :atom, default: :legend_rank)
  prop(rank_title, :string, default: "Rank")
  prop(sub_rank_title, :string, default: "#")

  data(rank_parts, :any)

  def mount(socket) do
    {:ok, assign_rank_parts(socket)}
  end

  def render(assigns) do
    ~F"""
      <div>
        <Dropdown title={@rank_title}>
          <a :for={level <-levels()} class={"dropdown-item", "is-active": matches_level?(@rank_parts, level)} :on-click="change_level" phx-value-level={level}>
          {level}
          </a>
        </Dropdown>

        <Dropdown :if={num = num_sub_ranks(@rank_parts)} title={@sub_rank_title}>
          <a :for={rank <- 1..num} class={"dropdown-item", "is-active": matches_rank?(@rank_parts, rank)} :on-click="change_rank" phx-value-rank={rank}>
          {rank}
          </a>
        </Dropdown>
        <NumberInput :if={@rank_parts == :Legend} class="input" field={@legend_rank_field} :if={:Legend == @rank_parts} value={@legend_rank || 0} opts={style: "width: 100px;"}/>
        <HiddenInput :if={@rank_parts != :Legend} field={@legend_rank_field} value={@legend_rank || 0} />

        <HiddenInput field={@rank_field} value={@rank} />
      </div>
    """
  end

  defp levels() do
    [
      :Legend,
      :Diamond,
      :Platinum,
      :Gold,
      :Silver,
      :Bronze
    ]
  end

  def handle_event("legend_change", params, socket) do
    IO.inspect(params, label: :params)
    {l, _} = Integer.parse(params["value"])
    {:no_reply, assign(socket, legend_rank: l, rank: 51)}
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

  defp assign_rank_parts(socket = %{assigns: %{rank: r}}) when is_integer(r) do
    assign(socket, rank_parts: DeckTracker.convert_rank(r))
  end

  defp assign_rank_parts(socket), do: assign(socket, rank_parts: {nil, nil})

  defp assign_rank(socket = %{assigns: %{rank_parts: :Legend}}), do: assign(socket, rank: 51)

  defp assign_rank(socket = %{assigns: %{rank_parts: parts}}) do
    case DeckTracker.convert_rank(parts) do
      nil -> socket
      rank -> assign(socket, rank: rank, legend_rank: 0)
    end
  end
end
