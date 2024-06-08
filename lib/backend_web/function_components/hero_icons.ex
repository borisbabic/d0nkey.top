defmodule HeroIcons do
  @moduledoc "Function component SVG icons from https://heroicons.com/"
  use Phoenix.Component

  attr :size, :string, default: nil

  def copy(assigns) do
    ~H"""
      <.wrapper size={@size}>
        <.svg>
          <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 17.25v3.375c0 .621-.504 1.125-1.125 1.125h-9.75a1.125 1.125 0 0 1-1.125-1.125V7.875c0-.621.504-1.125 1.125-1.125H6.75a9.06 9.06 0 0 1 1.5.124m7.5 10.376h3.375c.621 0 1.125-.504 1.125-1.125V11.25c0-4.46-3.243-8.161-7.5-8.876a9.06 9.06 0 0 0-1.5-.124H9.375c-.621 0-1.125.504-1.125 1.125v3.5m7.5 10.375H9.375a1.125 1.125 0 0 1-1.125-1.125v-9.25m12 6.625v-1.875a3.375 3.375 0 0 0-3.375-3.375h-1.5a1.125 1.125 0 0 1-1.125-1.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H9.75" />
        </.svg>
      </.wrapper>
    """
  end

  attr :size, :string, default: nil

  def chevron_down(assigns) do
    ~H"""
      <.wrapper size={@size}>
        <.svg>
          <path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5" />
        </.svg>
      </.wrapper>
    """
  end

  attr :size, :string, default: nil

  def chevron_up(assigns) do
    ~H"""
      <.wrapper size={@size}>
        <.svg>
          <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 15.75 7.5-7.5 7.5 7.5" />
        </.svg>
      </.wrapper>
    """
  end

  attr :size, :string, default: nil

  def chevron_left(assigns) do
    ~H"""
      <.wrapper size={@size}>
        <.svg>
          <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 19.5 8.25 12l7.5-7.5" />
        </.svg>
      </.wrapper>
    """
  end

  attr :size, :string, default: nil

  def chevron_right(assigns) do
    ~H"""
      <.wrapper size={@size}>
        <.svg>
          <path stroke-linecap="round" stroke-linejoin="round" d="m8.25 4.5 7.5 7.5-7.5 7.5" />
        </.svg>
      </.wrapper>
    """
  end

  attr :size, :string, default: nil

  def eye(assigns) do
    ~H"""
      <.wrapper size={@size}>
        <.svg>
          <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z" />
          <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
        </.svg>
      </.wrapper>
    """
  end

  attr :size, :string, default: nil

  def eye_slash(assigns) do
    ~H"""
      <.wrapper size={@size}>
        <.svg>
          <path stroke-linecap="round" stroke-linejoin="round" d="M3.98 8.223A10.477 10.477 0 0 0 1.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.451 10.451 0 0 1 12 4.5c4.756 0 8.773 3.162 10.065 7.498a10.522 10.522 0 0 1-4.293 5.774M6.228 6.228 3 3m3.228 3.228 3.65 3.65m7.894 7.894L21 21m-3.228-3.228-3.65-3.65m0 0a3 3 0 1 0-4.243-4.243m4.242 4.242L9.88 9.88" />
        </.svg>
      </.wrapper>
    """
  end

  attr :size, :string, default: nil

  def users(assigns) do
    ~H"""
      <.wrapper size={@size}>
        <.svg>
          <path stroke-linecap="round" stroke-linejoin="round" d="M15 19.128a9.38 9.38 0 0 0 2.625.372 9.337 9.337 0 0 0 4.121-.952 4.125 4.125 0 0 0-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 0 1 8.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0 1 11.964-3.07M12 6.375a3.375 3.375 0 1 1-6.75 0 3.375 3.375 0 0 1 6.75 0Zm8.25 2.25a2.625 2.625 0 1 1-5.25 0 2.625 2.625 0 0 1 5.25 0Z" />
        </.svg>
      </.wrapper>
    """
  end

  attr :size, :string, default: nil

  def warning_triangle(assigns) do
    ~H"""
      <.wrapper size={@size}>
        <.svg>
          <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126ZM12 15.75h.007v.008H12v-.008Z" />
        </.svg>
      </.wrapper>
    """
  end

  attr :size, :string, default: nil

  def user(assigns) do
    ~H"""
      <.wrapper size={@size}>
        <.svg>
          <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.501 20.118a7.5 7.5 0 0 1 14.998 0A17.933 17.933 0 0 1 12 21.75c-2.676 0-5.216-.584-7.499-1.632Z" />
        </.svg>
      </.wrapper>
    """
  end

  attr :size, :string, default: nil

  def flag(assigns) do
    ~H"""
      <.wrapper size={@size}>
        <.svg>
          <path stroke-linecap="round" stroke-linejoin="round" d="M3 3v1.5M3 21v-6m0 0 2.77-.693a9 9 0 0 1 6.208.682l.108.054a9 9 0 0 0 6.086.71l3.114-.732a48.524 48.524 0 0 1-.005-10.499l-3.11.732a9 9 0 0 1-6.085-.711l-.108-.054a9 9 0 0 0-6.208-.682L3 4.5M3 15V4.5" />
        </.svg>
      </.wrapper>
    """
  end

  attr :size, :string, default: nil

  def info_circle(assigns) do
    ~H"""
      <.wrapper size={@size}>
        <.svg>
          <path stroke-linecap="round" stroke-linejoin="round" d="m11.25 11.25.041-.02a.75.75 0 0 1 1.063.852l-.708 2.836a.75.75 0 0 0 1.063.853l.041-.021M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-9-3.75h.008v.008H12V8.25Z" />
        </.svg>
      </.wrapper>
    """
  end

  attr :size, :string, default: nil

  def wrapper_only(assigns) do
    ~H"""
      <.wrapper size={@size}>
      </.wrapper>
    """
  end

  attr :stroke, :string, default: "currentColor"
  slot :inner_block

  def svg(assigns) do
    ~H"""
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke={@stroke} class="icon w-6 h-6">
      <%= render_slot(@inner_block) %>
      </svg>
    """
  end

  attr :size, :string, default: nil
  slot :inner_block

  def wrapper(assigns) do
    ~H"""
    <span class={["icon", size_class(@size)]}>
      <%= render_slot(@inner_block) %>
    </span>
    """
  end

  def size_class(size) when size in ["medium", "is-medium"], do: "is-medium"
  def size_class(size) when size in ["large", "is-large"], do: "is-large"
  def size_class(size) when size in ["small", "is-small"], do: "is-small"
  def size_class(_), do: ""
end
