defmodule FunctionComponents.Stats do
  @moduledoc false

  use BackendWeb, :component

  attr :winrate, :float, required: true
  attr :round_digits, :integer, default: 1
  attr :positive_hue, :integer, default: 120
  attr :negative_hue, :integer, default: 0
  attr :offset, :integer, default: 0
  attr :tag_name, :string, default: "span"
  attr :class, :string, default: "tag"
  attr :lightness, :integer, default: 50
  attr :base_saturation, :integer, default: 5
  attr :sample, :integer, default: nil
  attr :show_sample, :boolean, default: nil
  attr :impact, :boolean, default: false
  attr :win_loss, :any, default: nil
  attr :min_sample, :integer, default: 1
  attr :min_for_color, :integer, default: nil
  attr :flip, :boolean, default: false
  attr :show_winrate, :boolean, default: true

  def winrate_tag(assigns) do
    ~H"""
    <.dynamic_tag :if={sufficient_sample(@sample, @min_sample)} tag_name={@tag_name} class={@class} style={if use_color?(@sample, @min_sample, @winrate, @min_for_color) , do: winrate_style(@winrate + shift_for_color(@impact) + @offset, flip(@positive_hue, @negative_hue, @flip), flip(@negative_hue, @positive_hue, @flip), @lightness, @base_saturation), else: ""}>
      <span class={["tw-text-center", use_color?(@sample, @min_sample, @winrate, @min_for_color) && "basic-black-text"]}>
        <span :if={@show_winrate}>{round(@winrate, @round_digits)}</span>
        <sup :if={@show_sample}>{@sample}</sup>
        <span :if={@win_loss}>{win_loss(@win_loss, @winrate, @sample, @show_winrate)}</span>
      </span>
    </.dynamic_tag>
    """
  end

  defp win_loss(%{wins: wins, losses: losses} = win_loss, _, _, false), do: "#{wins} - #{losses}"
  defp win_loss(%{wins: wins, losses: losses} = win_loss, _, _, true), do: "(#{wins} - #{losses})"

  defp win_loss(true, winrate, sample, show_winrate) when is_integer(sample) and sample > 0 do
    wins = Float.round(winrate * sample, 0) |> trunc()
    losses = sample - wins

    %{wins: wins, losses: losses}
    |> win_loss(nil, nil, show_winrate)
  end

  defp flip(_hue1, hue2, true), do: hue2
  defp flip(hue1, _hue2, _), do: hue1

  defp use_color?(sample, min_sample, winrate, min_for_color) do
    sufficient_sample(sample, min_sample) and sufficient_winrate(winrate, min_for_color)
  end

  defp sufficient_winrate(winrate, min_for_color)
       when is_number(winrate) and is_number(min_for_color) do
    winrate >= min_for_color
  end

  defp sufficient_winrate(winrate, _min_for_color) when is_number(winrate) do
    true
  end

  defp sufficient_winrate(_, _), do: false

  defp sufficient_sample(sample, min_sample) when is_integer(sample) and is_integer(min_sample) do
    sample >= min_sample
  end

  defp sufficient_sample(_, _), do: true

  def winrate_style(
        winrate,
        positive_hue,
        negative_hue,
        lightness,
        base_saturation,
        sample \\ nil
      )

  def winrate_style(_, _, _, _, _, 0), do: ""

  def winrate_style(winrate, positive_hue, negative_hue, lightness, base_saturation, _sample) do
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
  def round(zero, _) when zero in [0, 0.0, nil], do: 0
  def round(int, _) when is_integer(int), do: int / 1
  def round(float, digits), do: Float.round(float * 100, digits)

  def shift_for_color(true), do: 0.5
  def shift_for_color(_), do: 0
end
