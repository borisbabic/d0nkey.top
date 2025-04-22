defmodule Components.Helper do
  @moduledoc false
  use Phoenix.Component
  import Phoenix.HTML.Form
  alias FunctionComponents.Dropdown

  def warning_triangle(), do: warning_triangle(%{})

  attr :before, :any, required: false, default: false
  attr :after_warning, :any, required: false, default: false

  def warning_triangle(assigns) do
    ~H"""
    <span>
      <span :if={@before}><%= @before %></span>
      <HeroIcons.warning_triangle size="small" />
      <span :if={@after_warning}><%= @after_warning %></span>
    </span>
    """
  end

  def concat(first, second) do
    concat(%{first: first, second: second})
  end

  attr :first, :any, required: true
  attr :second, :any, required: true

  def concat(assigns) do
    ~H"""
    <%= @first %><%=@second%>
    """
  end

  attr :datetime, :any, required: true

  def datetime(assigns) do
    ~H"""
      <time class="datetime-human" phx-hook="LocalDateTime" datetime={NaiveDateTime.to_iso8601(@datetime)} id={random_id()} aria-label={timestamp(@datetime)}><%= human_readable(@datetime)%> UTC</time>
    """
  end

  defp timestamp(maybe_naive) do
    {:ok, not_naive} = DateTime.from_naive(maybe_naive, "Etc/UTC")
    DateTime.to_unix(not_naive, :millisecond)
  end

  defp human_readable(maybe_naive) do
    Util.datetime_to_presentable_string(maybe_naive)
  end

  defp random_id() do
    :crypto.strong_rand_bytes(42) |> Base.encode64() |> binary_part(0, 42)
  end

  attr :rank, :any, required: true

  def legend_rank(assigns) do
    ~H(<span class="tag legend-rank"><%= @rank %></span>)
  end

  attr :type, :any, required: true

  def game_type(assigns) do
    ~H"""
    <span class="tag" style={"background-color: #{game_type_color(@type)};"}>
      <%= game_type_name(@type) %>
    </span>
    """
  end

  defp game_type_name(type) do
    Hearthstone.Enums.BnetGameType.game_type_name(type)
  end

  defp game_type_color(type) do
    name = game_type_name(type)

    normalized =
      name
      |> String.replace(" ", "")
      |> String.downcase()

    "var(--color-#{normalized})"
  end

  attr :show, :boolean, default: true

  def checkmark(assigns) do
    ~H"""
      <span :if={@show} class="tag is-success">✓</span>
    """
  end

  def empty() do
    assigns = %{}

    ~H"""

    """
  end

  def render_player_icon(player) when is_binary(player) do
    case Backend.PlayerIconBag.get_map(player) do
      nil -> empty()
      map -> player_icon(map)
    end
  end

  attr :player, :string, required: true
  attr :path, :string, required: false
  attr :link, :string, required: false
  attr :icon, :string, required: false
  attr :type, :atom, required: true

  def player_icon(%{type: _type} = assigns) do
    ~H"""
      <span class="icon small">
        <object>
          <a {optional_href(@link)} target="_blank">
            <span :if={@type == :unicode}><%= @icon %></span>
            <img :if={@type == :image} src={@path} alt={@player}/>
          </a>
        </object>
      </span>
    """
  end

  defp optional_href(link) when is_binary(link), do: %{href: link}
  defp optional_href(_), do: %{}

  def player_name(nil, _with_country), do: ""

  def player_name(name, with_country) when is_binary(name) and is_boolean(with_country) do
    country =
      if with_country do
        Backend.PlayerInfo.get_country(name)
      end

    player_name(%{name: name, country: country})
  end

  attr :name, :string, required: true
  attr :country, :any, required: false, default: nil

  def player_name(assigns) do
    ~H"""
    <%= if @country do %>
      <%= country_flag(@country, @name) %>
    <% end %>
    <span><%= render_player_icon(@name) %><%= @name %></span>
    """
  end

  attr :country_code, :string, required: true
  attr :show_flag, :boolean, default: true

  def country(assigns) do
    ~H"""
    <.country_flag :if={@show_flag} country={@country_code}/><span><%=Util.get_country_name(@country_code)%></span>
    """
  end

  def country_flag(country, player) when is_binary(player) do
    pref = Backend.PlayerCountryPreferenceBag.get(player, country)
    country_flag(country, pref)
  end

  def country_flag(country, %{show_region: true}) do
    %{world_region: region} = Countriex.get_by(:alpha2, country)
    image = "/images/region_#{String.downcase(region)}.png"

    region_flag(%{image: image, region: region})
  end

  def country_flag(region, _) when region in ["AP", "APAC", "AM", "AMER", "EU", "EMEA"] do
    image = "/images/region_#{String.downcase(region)}.png"

    region_flag(%{image: image, region: region})
  end

  def country_flag(country, user_preferences) do
    name = Util.get_country_name(country)

    assigns =
      user_preferences
      |> Map.put_new(:cross_out_country, false)
      |> Map.put(:country, String.downcase(country))
      |> Map.put(:country_name, name)

    country_flag(assigns)
  end

  attr :country, :string, required: true
  attr :cross_out_country, :boolean, default: false

  def country_flag(assigns) do
    ~H"""
      <span data-balloon-pos="up" aria-label={Util.get_country_name(@country) || @country} class="icon">
      <img
        src={"https://flagcdn.com/64x48/#{ String.downcase(@country) }.png"}
        srcset={"https://flagcdn.com/128x96/#{ String.downcase(@country) }.png 2x,\n  https://flagcdn.com/192x144/#{ String.downcase(@country) }.png 3x"}
        width="64"
        height="48"
        >
        <%= if @cross_out_country do %>
          <img src="/images/cross.png" width="64" height="48" class="cross-image">
        <% end %>
      </span>
    """
  end

  attr :image, :string, required: true
  attr :region, :string, required: true

  def region_flag(assigns) do
    ~H"""
      <span data-balloon-pos="up" aria-label={@region}class="icon">
          <img
              class="icon"
              src={@image}
              width="64"
              height="48"
              >
      </span>
    """
  end

  attr :link, :string, required: false, default: nil
  attr :name, :string, required: true
  attr :with_country, :boolean, default: true

  def player_link(assigns) do
    ~H"""
    <a href={@link || "/player-profile/#{@name}"}>
      <%= player_name(@name, @with_country) %>
    </a>
    """
  end

  attr :class, :string, required: true
  attr :current, :any, required: true
  attr :arrow, :any, required: true
  attr :diff, :any, required: true

  def comparison(assigns) do
    ~H"""
      <span><%= @current %></span>
      <span class={@class}><%= @arrow %><%= @diff %></span>
    """
  end

  attr :deckcode, :boolean, required: true
  attr :hide_no_js, :boolean, default: true

  def deckcode(assigns) do
    ~H"""
    <div>
        <button type="button" data-balloon-pos="up" data-aria-on-copy="Copied!" class="clip-btn-value is-shown-js" style={if @hide_no_js, do: "display: none;"} aria-label="Copy" data-clipboard-text={@deckcode}>
            <HeroIcons.copy size="small"/>
        </button>
        <noscript>
            <textarea class="textarea has-fixed-size is-hidden-js" readonly rows="1" style="white-space: nowrap; overflow: hidden; width: 50px;">
                <%= @deckcode %>
            </textarea>
        </noscript>
    </div>
    """
  end

  attr :warning, :string, required: true

  def warning_exclamation(assigns) do
    ~H"""
    <span data-balloon-pos="up" aria-label={@warning} class="icon is-small">
      <i class="fas fa-exclamation"></i>
    </span>
    """
  end

  attr :options, :list, required: true
  attr :title, :string, required: true

  def dropdown(assigns) do
    ~H"""
      <Dropdown.menu title={@title}>
        <Dropdown.item :for={%{link: link, selected: selected, display: display} <- @options} selected={selected} href={link}>
          <%= display %>
        </Dropdown.item>
      </Dropdown.menu>
    """
  end

  attr :dropdowns, :list, required: true

  def dropdowns(assigns) do
    ~H"""
      <%= for {options, title} <- @dropdowns do %>
        <.dropdown options={options} title={title}/>
      <% end %>
    """
  end

  attr :options, :list, required: true
  attr :show_search, :boolean, required: true
  attr :search_class, :string, required: true
  attr :checkbox_class, :string, required: true
  attr :top_buttons, :boolean, default: false
  attr :bottom_buttons, :boolean, default: true
  attr :selected_first, :boolean, default: true
  attr :placeholder, :any, required: true
  attr :title, :string, required: true

  def multiselect_dropdown(assigns) do
    ~H"""
    <div class={["has-dropdown", "dropdown", "is-hoverable"]} x-on:mouseleave="if(window.canCloseDropdown($event)) open=false;" x-data="{open: false}" x-bind:class="{'is-active': open}" x-bind:aria-expanded="open" x-on:keydown.esc={"open=false"}>
        <Dropdown.title title={@title}/>
        <div class="dropdown-menu" role="menu">
            <div class="dropdown-content">
                <%= if @top_buttons do %>
                    <div class="dropdown-item is-flex">
                        <%= submit "Submit", class: "button" %>
                        <button class="button" type="button" onclick={"uncheck('#{ @checkbox_class }')"}>
                            Clear
                        </button>
                    </div>
                <% end %>

                <%= if @show_search do %>
                    <input
                        class="input has-text-black "
                        autocomplete="off"
                        placeholder={"#{ @placeholder }"}
                        id={"#{ @search_id }"}
                        onpaste={"hide_based_on_search('#{ @search_id }', '#{ @search_class }', '#{"value_" <> @search_class}')"}
                        oninput={"hide_based_on_search('#{ @search_id }', '#{ @search_class }', '#{"value_" <> @search_class}')"}
                        onkeyup={"hide_based_on_search('#{ @search_id }', '#{ @search_class }', '#{"value_" <> @search_class}')"}
                        oncut={"hide_based_on_search('#{ @search_id }', '#{ @search_class }', '#{"value_" <> @search_class}')"}
                        onchange={"hide_based_on_search('#{ @search_id }', '#{ @search_class }', '#{"value_" <> @search_class}')"}
                        type="text">
                <% end %>
                <%= for %{value: value, display: display, selected: selected, name: name} <- sort_by_selected(@options, @selected_first) do %>
                    <Dropdown.item class={@search_class}>
                      <label for={"#{ @attr }[#{ value }]"} data-target-value={"#{ name }"} class={"value_#{ @search_class }"}>
                          <div class="is-flex">
                              <span class="multi-select-text"><%= display %></span>
                              <input
                                  class={"#{ @checkbox_class }"}
                                  id={"#{ "#{@attr}[#{value}]" }"}
                                  name={"#{ "#{@attr}[#{value}]" }"}
                                  style="margin-left: auto"
                                  type="checkbox"
                                  value="true"
                                  checked={selected}
                              >
                          </div>
                      </label>
                    </Dropdown.item>
                <% end %>
                <%= if @bottom_buttons do %>
                    <div class="dropdown-item is-flex">
                        <%= submit "Submit", class: "button" %>
                        <button class="button" type="button" onclick={"uncheck('#{ @checkbox_class }')"}>
                            Clear
                        </button>
                    </div>
                <% end %>
            </div>
        </div>
    </div>
    """
  end

  defp sort_by_selected(options, false), do: options

  defp sort_by_selected(options, true),
    do: options |> Enum.sort_by(fn o -> o.selected end, :desc)

  attr :link, :string, required: true
  attr :body, :string, required: true
  attr :class, :string, default: "is-link"

  def simple_link(assigns) do
    ~H"""
    <.link navigate={@link} class={@class}>
      <%= @body %>
    </.link>
    """
  end

  attr :viewable_url, :string, default: nil

  def needs_login(assigns) do
    ~H"""
      <div class="title is-3">You need to log in to view this page</div>
      <span :if={@viewable_url}><a class="link" href={@viewable_url}>View the page without features that require login</a> | </span>
      <a class="link" href={"/auth/bnet"}>Log in</a>
    """
  end
end
