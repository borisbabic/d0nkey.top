defmodule FunctionComponents.Stats do
  @moduledoc false

  use BackendWeb, :component

  attr :winrate, :float, required: true
  attr :round_digits, :integer, default: 1
  attr :positive_hue, :integer, default: 120
  attr :negative_hue, :integer, default: 0
  attr :tag_name, :string, default: "span"
  attr :class, :string, default: "tag"
  attr :lightness, :integer, default: 50
  attr :base_saturation, :integer, default: 5
  attr :sample, :integer, default: nil
  attr :show_sample, :boolean, default: nil
  attr :impact, :boolean, default: false
  attr :win_loss, :any, default: nil
  attr :min_sample, :integer, default: 1

  def winrate_tag(assigns) do
    ~H"""
    <.dynamic_tag tag_name={@tag_name} class={@class} style={if sufficient_sample(@sample, @min_sample), do: winrate_style(@winrate + shift_for_color(@impact), @positive_hue, @negative_hue, @lightness, @base_saturation), else: ""}>
      <span :if={!sufficient_sample(@sample, @min_sample)}></span>
      <span :if={sufficient_sample(@sample, @min_sample)}class="basic-black-text tw-text-center">
        {round(@winrate, @round_digits)}
        <sup :if={@show_sample}>{@sample}</sup>
        <span :if={@win_loss}>({@win_loss.wins} - {@win_loss.losses})</span>
      </span>
    </.dynamic_tag>
    """
  end

  defp sufficient_sample(sample, min_sample) when is_integer(sample) and is_integer(min_sample) do
    sample >= min_sample
  end

  defp sufficient_sample(_, _), do: true

  def winrate_style(
        winrate,
        positive_hue,
        negative_hue,
        lightness,
        base_saturation
      )

  def winrate_style(winrate, positive_hue, negative_hue, lightness, base_saturation) do
    hue =
      if winrate >= 0.5 do
        positive_hue
      else
        negative_hue
      end

    saturation = base_saturation + (100 - base_saturation) * (abs(winrate - 0.5) / 0.5)
    "background-color:hsl(#{hue}, #{saturation}%, #{lightness}%);"
  end

  def lightness(_lightness, 0), do: 100
  def lightness(lightness, _sample), do: lightness
  def round(int, _) when is_integer(int), do: int / 1
  def round(float, digits), do: Float.round(float * 100, digits)

  def shift_for_color(true), do: 0.5
  def shift_for_color(_), do: 0
end
