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
      :minion_type,
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
  defp prepare(val, attr) when attr in @ignore_prepare, do: val
  defp prepare(%{name: name}, _), do: name
  defp prepare(nil, _), do: ""

  defp prepare("https" <> _ = url, _) do
    assigns = %{url: url}

    ~F"""
      <a href={@url} target="_blank">Image Link</a>
    """
  end

  defp prepare(data, _) when is_list(data), do: Enum.map_join(data, ", ", &prepare/1)
  defp prepare(data, _) when is_atom(data), do: data |> to_string() |> prepare()
  defp prepare(data, _) when is_binary(data), do: Recase.to_title(data)
  defp prepare(data, _), do: data
end
