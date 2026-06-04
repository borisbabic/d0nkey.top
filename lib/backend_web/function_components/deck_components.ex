defmodule FunctionComponents.DeckComponents do
  @moduledoc false

  use BackendWeb, :component
  alias Backend.Hearthstone.Deck
  attr :archetype, :any, required: true

  def archetype(assigns) do
    ~H"""
      <div class={"decklist-info deck-title #{Deck.extract_class(@archetype) |> String.downcase()}"}>
        <a class="basic-black-text deck-title" href={~p"/archetype/#{@archetype}"}>
          <%= @archetype %>
        </a>
      </div>
    """
  end

  attr :class_slug, :string, required: true
  attr :opacity, :float, default: 1.0
  attr :css_class, :string, default: ""
  attr :style, :string, default: ""
  attr :size, :integer, default: 32

  def class_icon(assigns) do
    ~H"""
    <figure class="image is-rounded">
      <img class={"image is-rounded is-#{@size}x#{@size} #{@css_class}"} style={"opacity: #{@opacity};#{@style}"} src={class_icon_url(@class_slug)}>
    </figure>
    """
  end

  def class_icon_url([class]), do: class_icon_url(class)

  def class_icon_url(class) when is_binary(class),
    do: "/images/icons/#{String.downcase(class)}.png"

  def class_icon_url(_), do: nil
end
