defmodule Components.LiveStreamer do
  @moduledoc false
  use Surface.Component
  alias Hearthstone.Enums.BnetGameType
  use BackendWeb.ViewHelpers
  prop(live_streamer, :map, required: true)
  data(link, :string)
  data(thumbnail_url, :string)
  data(thumbnail_width, :string)
  data(game_type, :integer)
  data(duration, :integer)
  data(legend_rank, :integer)
  data(show_deck, :boolean)
  slot(default)

  def render(assigns = %{live_streamer: s}) do
    game_type =
      s.game_type
      |> Util.to_int_or_orig()
      |> render_game_type()

    duration = Util.human_diff(NaiveDateTime.utc_now(), s.started_at)
    thumbnail_width = 256 + 128
    thumbnail_height = (thumbnail_width * 9 / 16) |> floor()

    thumbnail_url =
      Twitch.Stream.thumbnail_url(s.thumbnail_url, thumbnail_width, thumbnail_height)

    legend_rank = render_legend_rank(s.legend_rank)

    {show_deck, _deck} =
      with deckcode when is_binary(deckcode) <- s.deckcode,
           {:ok, deck} <- Backend.Hearthstone.Deck.decode(deckcode) do
        {BnetGameType.constructed?(s.game_type), deck}
      else
        _ -> {false, nil}
      end

    link = s |> Twitch.Stream.login() |> Backend.Twitch.create_channel_link()

    assigns =
      assigns
      |> assign(
        link: link,
        thumbnail_url: thumbnail_url,
        thumbnail_width: thumbnail_width,
        game_type: game_type,
        duration: duration,
        legend_rank: legend_rank,
        show_deck: show_deck
      )

    ~F"""
    <div class="cestor card live-streamer twitch" >
        <div class="is-parent" style={"width: #{@thumbnail_width}px;"}>
            <div class="card-image" style="margin: 7.5px;">
              <a href={"#{@link}"} target="_blank">
                <img src={"#{@thumbnail_url}"} alt={"#{@live_streamer.user_name}"}/>
              </a>
            </div>
            <div style="margin-left: 7.5px; margin-right: 7.5px;">
              <div style="margin-bottom: 3.75px;">
                <a href={"#{@link}"} target="_blank" >
                  <div class="title is-6">
                    {@live_streamer.title}
                  </div>
                </a>
              </div>
              <div style="margin-bottom: 3.75px;">
                <div class="tags" style="margin-bottom: 0px;">
                  <strong class="tag is-twitch"> {@live_streamer.user_name} </strong>
                  <div class="tag is-info"><HeroIcons.users /><p> {@live_streamer.viewer_count}</p></div>
                  {@game_type}
                  <div class="tag is-info"> {@duration} </div>
                  <div :if={@legend_rank}> {@legend_rank} </div>
                </div>
                <div :if={@show_deck} >
                  <div class="is-deck-wide">
                    <#slot/>
                  </div>
                </div>
              </div>
            </div>
        </div>
    </div>

    """
  end
end
