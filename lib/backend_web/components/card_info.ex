defmodule Components.CardInfo do
  @moduledoc false
  use BackendWeb, :surface_live_component
  alias Backend.Hearthstone.Card

  prop(card, :map, required: true)

  prop(attrs, :list,
    default: [
      :name,
      :nicknames,
      :card_set,
      :id,
      :mana_cost,
      :attack,
      :health,
      :durability,
      :classes,
      :durability,
      :multi_minion_types,
      :dust_cost,
      :dust_free,
      :spell_school,
      :flavor_text,
      :text,
      :keywords,
      :factions,
      :collectible,
      :artist_name,
      :crop_image,
      :image,
      :image_gold
    ]
  )

  def render(assigns) do
    [headers | rows] = rows(assigns.card, assigns.attrs)
    assigns = assigns |> assign(rows: rows, headers: headers)

    ~F"""
      <div>
        <.table id="card_info_table">
          <.thead>
            <.trh>
              <.td>{elem(@headers, 0)}</.td>
              <.td>{elem(@headers, 1)}</.td>
            </.trh>
          </.thead>
          <.tbody>
            <.trb :for={{name, value} <- @rows}>
              <.td>{name}</.td>
              <.td>{value}</.td>
            </.trb>
          </.tbody>
        </.table>
      </div>
    """
  end

  def rows(card, attrs) do
    Enum.map(attrs, fn a ->
      name = prepare(a)

      val =
        value(card, a)
        |> prepare(a)

      {name, val}
    end)
  end

  defp value(card, attr) do
    if function_exported?(Card, attr, 1) do
      apply(Card, attr, [card])
    else
      Map.get(card, attr)
    end
  end

  @ignore_prepare [:name, :flavor_text, :text, :artist_name]
  defp prepare(val, attr \\ nil)
  defp prepare(:multi_minion_types, nil), do: "Minion Types"
  defp prepare(val, attr) when attr in @ignore_prepare, do: val
  defp prepare(%{name: name}, _), do: name
  defp prepare(nil, _), do: ""

  defp prepare("https" <> _ = url, _) do
    assigns = %{url: url}

    ~F"""
      <a href={@url} target="_blank">Image Link<HeroIcons.external_link /></a>
    """
  end

  defp prepare(data, _) when is_list(data), do: Enum.map_join(data, ", ", &prepare/1)
  defp prepare(data, _) when is_atom(data), do: data |> to_string() |> prepare()
  defp prepare(data, _) when is_binary(data), do: Recase.to_title(data)
  defp prepare(data, _), do: data
end
