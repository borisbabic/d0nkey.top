defmodule Components.Socials do
  @moduledoc "Social media linking components"
  use BackendWeb, :component

  attr :link, :string, required: true

  def paypal(assigns) do
    ~H"""
      <a href={@link}>
        <img height="50px" class="image" alt="Paypal" src="https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif"/>
      </a>
    """
  end

  attr :link, :string, required: true
  attr :class, :string, default: ""

  def discord(assigns) do
    ~H"""
      <a href={@link} class={@class}>
        <img style="height: 30px;" class="image" alt="Discord" src="/images/brands/discord.svg"/>
      </a>
    """
  end

  attr :link, :string, required: true
  attr :height, :integer, default: 30

  def twitch(channel) when is_binary(channel),
    do: %{link: "https://www.twitch.tv/#{channel}"} |> twitch()

  def twitch(assigns) do
    ~H"""
      <a href={@link}>
        <img style={"height: #{@height}px;"} class="image" alt="Twitch" src="/images/brands/twitch_extruded_wordmark_purple.svg" />
      </a>
    """
  end

  attr :link, :string, required: true

  def patreon(assigns) do
    ~H"""
      <a href={@link}>
        <.patreon_image />
      </a>
    """
  end

  def patreon_image(assigns) do
    ~H"""
      <img style="height: 30px;" class="image" alt="Patreon" src="/images/brands/patreon_wordmark_fierycoral.png" />
    """
  end

  attr :tag, :string, required: true

  def x(assigns) do
    ~H"""
      <a class=""
        href={"https://twitter.com/#{@tag}"}
        data-show-screen-name="false"
        data-show-count="false">
        <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAAsTAAALEwEAmpwYAAAEc0lEQVR4nO2XyUsjURDG/UPGm9iJL4lLOu5pcSd4ET0oooKCiHhQULyLKCLePIgbiLcZBuNyURAExQW8CXFBPLggijPRiCsub6gi3bSx7bz3omEOKfgOHV/k91VXvarExcUiFrGIxX8bbrc7XlGU34qi3CiKQt1u9zvl5uZqysnJ0ZSdna0pKyvrnTIzMzVlZGRoSk9P1+RyuagsyzeyLHtlWZYigf8L4KHwLOCh8KzgLp1kWQb5ZVmO5zYQzDwTuFnWWcDTQ+CD4Cin0wn6JfIGbiIpFz04a9blj+CotLS0gIiBb69zlwG4ATyK20CU65x+Bg5KTU0VNxBJnQuWCw2FFzIQ7Tp3GmRdVUpKipiBz8Dhzfh8PmoUc3NzTHXe1tZGX19f6erqKj5/Bq6K20C4rFdXV9PHx0f69vZGl5eX6dLSEt3d3UUTXV1dplmvra2l9/f3eB4SFQoeCp+cnCxmIFydDw4OIvDY2BhmvKCggJ6dndGrqyvq8XgMywU+v7i4QHk8HtOsA7gqbgMsdQ5aW1ujLy8vtLGxEbPd1NSEpbGxsYHP+hqHwXhwcEBvb29pVVUVE7jD4UAJGWBp0JKSEur3++np6SnNy8vDbE9OTuKb6e/v1+Dh7ObmJn1+fqYtLS2G4CmfwAsZ4Bn/nZ2dCOz1etEAnIUmf3h4oBUVFWgAmhuit7eXOesOh4Pa7XYUtwHe+3x+fl5rYACurKzEJodGHR0dxb+Nj49zg9sjNcA6/mHtOD4+xgYuLi7G5hwYGNCu14WFhXfwevBkE3ibzYbiNiAy/hsaGrCB19fXtXsd6h6u2ubmZq6s24LgIEKIuAHe8T8xMYEZ7+vrw4zD27i+vsYmh6uZB9wWhBcyIDr+4cze3h59enqi5eXlmPH29nY0NT09/Q7cESbregkZYFlzQwcR9M3+/j6Wzc7ODn4PMj47O4smOjo6uMAJITQpKYnfAC84ZBo+g5UC4NVbCW4gAIYr+ejoCJs8Pz+fCZwE4YUNsKy5+ptlamoKoYeGhvB5ZWUFmxqmNADX1dXhM0xvvQFiAi5sgDXrqrq7uxF+ZmZGq+/CwkLMODQwTHaAHhkZwXM9PT1M4BEZYAGH+m5tbcV9aGtrCw3rGxTWZnVKQ7bh/Pb2Nk7psrIyJnghA0bgRvCwlN3d3dHDw0NcjY0aFN6K2sAAClsofMfn8+H/MAO3Wq0oIQPhtsWioiJ6fn5OLy8vaWlp6Yfxr9Y4zBNo4EAggCs3mIASghgeHjYFFzYQbuGCmob7HvYd+IES7lqsr6/HBoZ1GtaKxcVF3Eyh9GpqakzhhQyYrblgDNYFAIIhxXqfww8fozg5OcGBaQQesQHevYX1WgyXcWtQFosFxW2Adc39LnCrDj4iAyJ7Szhw1qxbIjEgCv4V5WL5IgM30SoXiwk4SJKka24DdrvdG+06t3wEV/VTxIBECPFHs84tH8FpYmLin4SEhB9xIkEIiSeE/CKEBKJRLpIOXJKkAGReGD4WsYhFLOKiEf8Af1P68HbF1egAAAAASUVORK5CYII=" alt="X (Twitter)">
      </a>
    """
  end
end
