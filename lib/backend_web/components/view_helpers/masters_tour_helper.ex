defmodule Components.ViewHelpers.MastersTourHelper do
  use BackendWeb, :component
  import Components.Helper
  alias Backend.MastersTour
  alias Backend.MastersTour.TourStop
  alias Backend.Blizzard

  @valid_regions [:US, :EU, :CN, :AP, :AM]
  def create_region_tag(region) when region in @valid_regions do
    tag =
      case region do
        r when r in [:US, :AM] -> "is-info"
        :EU -> "is-primary"
        :CN -> "is-warning"
        :AP -> "is-success"
      end

    region_name = Blizzard.get_region_name(region, :short)
    region_tag(%{tag: tag, region_name: region_name})
  end

  def create_region_tag(row) do
    case Blizzard.get_region_identifier(row) do
      {:ok, region} when region in @valid_regions -> create_region_tag(region)
      _ -> ""
    end
  end

  attr :tag, :string, required: true
  attr :region_name, :string, required: true

  def region_tag(assigns) do
    ~H"""
      <span class={"tag #{@tag} is-family-code"}><%= @region_name %></span>
    """
  end

  attr :profile_link, :string, required: true
  attr :country_tag, :any, required: true
  attr :region_tag, :any, required: true
  attr :name, :string, required: true

  def name_cell(assigns) do
    ~H"""
    <span>
      <%= @region_tag %><%= @country_tag %><span> <a class="is-link" href={@profile_link}> <.player_name name={@name}/> </a></span>
    </span>
    """
  end

  def create_name_cell(player_row = %{name: name}) do
    region = create_region_tag(player_row)
    country = create_country_tag(player_row)

    profile_link = ~p"/player-profile/#{MastersTour.mt_profile_name(name)}"

    name_cell(%{country_tag: country, profile_link: profile_link, region_tag: region, name: name})
  end

  def create_country_tag(%{country: nil}), do: ""
  def create_country_tag(%{country: cc, name: name}), do: Helper.country_flag(cc, name)

  attr :tour_stops, :list, default: []
  attr :show_current_score, :boolean, default: false

  def points_headers(assigns) do
    ~H"""
    <tr>
      <th>#</th>
      <th>Name</th>
      <%= for ts <- @tour_stops do %>
        <th class="is-hidden-mobile"><%=TourStop.display_name(ts)%></th>
      <% end %>
        <th :if={@show_current_score}>Current Score</th>
      <th>Total</th>
    </tr>
    """
  end

  attr :warning, :any, default: nil
  attr :name_cell, :string, required: true
  attr :place, :integer, required: true
  attr :total, :integer, required: true
  attr :current_score, :any, default: false
  attr :tour_stop_cells, :list, default: []

  def points_row(assigns) do
    ~H"""
      <tr>
        <td> <%=@place%> </td>
        <td> <%=@name_cell%><Helper.warning_exclamation :if={@warning} warning={@warning}/></td>
        <%= for tsc <- @tour_stop_cells do %>
          <td class="is-hidden-mobile"><%=tsc%></td>
        <% end %>
        <td :if={@current_score}><%= @current_score%></td>
        <td><%=@total%></td>
      </tr>
    """
  end

  attr :link, :string, required: true
  attr :body, :any, required: true

  def text_link(assigns) do
    ~H"""
    <.link class="is-text" navigate={@link}>
    <%= @body %>
    </.link>
    """
  end

  attr :show, :boolean, default: true

  def checkmark(assigns) do
    ~H"""
      <span :if={@show} class="tag is-success">✓</span>
    """
  end

  attr :wins, :integer, required: true
  attr :losses, :integer, required: true
  attr :disqualified, :boolean, default: nil
  attr :class, :string, default: nil

  def player_score(assigns) do
    ~H"""
      <div class={@class || player_score_class(@losses, @disqualified)}>
        <%= @wins %> - <%= @losses %>
      </div>
    """
  end

  def player_score_class(_losses, true), do: "has-text-danger"
  def player_score_class(2, _disqualified), do: "has-text-warning"
  def player_score_class(losses, _disqualified) when losses < 2, do: "has-text-warning"
  def player_score_class(_losses, _disqualified), do: "has-text-danger"
end
