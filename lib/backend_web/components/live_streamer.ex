defmodule Components.LiveStreamer do
  @moduledoc false
  use Surface.Component
  alias Surface.Components.Link
  alias Components.ExpandableDecklist
  prop(live_streamer, :map, required: true)

  def render(assigns = %{live_streamer: s}) do
    game_type =
      Hearthstone.Enums.BnetGameType.game_type_name(s.game_type |> Util.to_int_or_orig())

    duration = Util.human_diff(NaiveDateTime.utc_now(), s.started_at)
    thumbnail_width = 256 + 128
    thumbnail_height = (thumbnail_width * 9 / 16) |> floor()

    thumbnail_url =
      Twitch.Stream.thumbnail_url(s.thumbnail_url, thumbnail_width, thumbnail_height)

    legend_rank =
      if s.legend_rank && s.legend_rank > 0 do
        ~H"""
        <small>{{ s.legend_rank }}<i class="fas fa-trophy"></i></small>
        """
      else
        ""
      end

    {show_deck, deck} =
      with deckcode when is_binary(deckcode) <- s.deckcode,
           {:ok, deck} <- Backend.Hearthstone.Deck.decode(deckcode) do
        {true, deck}
      else
        _ -> {false, nil}
      end

    link = s |> Twitch.Stream.login() |> Backend.Twitch.create_channel_link()

    ~H"""
    <div class="cestor card" > 
        <div class="is-parent">
            <div class="card-header"> 
              <slot/>
              <a href="{{ link }}" target="_blank">
                <p> <strong>{{ s.user_name }}</strong> <small>{{ s.viewer_count }}<i class="fas fa-users"></i></small> <small>{{ game_type }}</small>  <small>{{ duration }}</small>  {{ legend_rank }} </p>
              </a>
            </div>
            <div class="card-image">
              <a href="{{ link }}" target="_blank">
                <img src="{{ thumbnail_url}}" alt="{{ @live_streamer.user_name }}"/>
              </a>
            </div>
          <div class="card-content" style="width: {{ thumbnail_width }}px;  text-overflow: ellipsis;">
            <a href="{{ link }}" target="_blank">
              {{ @live_streamer.title }}
            </a>
          </div>
        </div>
      <div class="card-content">
      </div>
    </div>

    """
  end
end
