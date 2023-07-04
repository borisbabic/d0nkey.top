defmodule Components.CardInfo do
  @moduledoc false
  use BackendWeb, :surface_live_component

  prop(card, :map, required: true)

  prop(attrs, :list,
    default: [
      :name,
      :card_set,
      :id,
      :mana_cost,
      :attack,
      :health,
      :durability,
      :classes,
      :durability,
      :minion_type,
      :spell_school,
      :flavor_text,
      :text,
      :keywords,
      :collectible,
      :duels_constructed,
      :duels_relevant
    ]
  )

  def render(assigns) do
    ~F"""
      <div>
        <table class="table is-striped is-narrow">
          <tbody>
            <tr :for={{name, value} <- rows(@card, @attrs)}>
              <td>{name}</td>
              <td>{value}</td>
            </tr>
          </tbody>
        </table>
      </div>
    """
  end

  def rows(card, attrs) do
    Enum.map(attrs, fn a ->
      name = prepare(a)

      val =
        card
        |> Map.get(a)
        |> prepare()

      {name, val}
    end)
  end

  defp prepare(%{name: name}), do: name
  defp prepare(nil), do: ""
  defp prepare(data) when is_list(data), do: Enum.map_join(data, ", ", &prepare/1)
  defp prepare(data) when is_atom(data), do: data |> to_string() |> prepare()
  defp prepare(data) when is_binary(data), do: Recase.to_title(data)
  defp prepare(data), do: data
end
