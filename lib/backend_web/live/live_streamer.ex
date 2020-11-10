defmodule BackendWeb.LiveStreamerComponent do
  use Phoenix.LiveComponent

  def render(assigns = %{live_streamer: s}) do
    game_type =
      Hearthstone.Enums.BnetGameType.game_type_name(s.game_type |> Util.to_int_or_orig())

    duration = Util.human_diff(NaiveDateTime.utc_now(), s.started_at)
    thumbnail_url = Twitch.Stream.thumbnail_url(s.thumbnail_url, 256, 144)
    twitch_link = s |> Twitch.Stream.login() |> Backend.Twitch.create_channel_link()

    ~L"""
    <a href="<%= twitch_link %>" class="media card">
      <figure class="media-left is16by9">
        <img src="<%= thumbnail_url %>" alt="<%= s.user_name %>">
      </figure>
      <div class="media-content">
        <p>
          <strong><%= s.user_name %></strong> <small><%= s.viewer_count %></small> <small><%= game_type %></small>  <small><%= duration %></small>  
          <br>
          <%= s.title %>
        </p>
      </div>
    </article>
    """

    # ~L"""
    # <tr>
    # <td> <%= s.user_id %> </td>
    # <td> <%= s.user_name %> </td>
    # <td> <%= s.title %> </td>
    # <td> <%= s.language %> </td>
    # <td> <%= s.viewer_count %> </td>
    # <td> <%= game_type %> </td>
    # <td> <%= duration %> </td>
    # </tr>
    # """
  end
end
