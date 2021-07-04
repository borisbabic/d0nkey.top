defmodule Backend.GMStream do
  @moduledoc """
  Keeps track of GM streams and tweets when a gm goes live
  """
  @name :gm_stream_live
  use Oban.Worker, queue: @name, unique: [period: 3600]
  use GenServer

  import Ecto.Query, warn: false

  alias Backend.Repo
  alias Backend.GMStream.Stream

  @gm_logins [
    "bankyugi_hs",
    "caelesluna",
    "EggowaffleHS",
    "fr0zen",
    "frenetichs",
    "gaby59",
    "glory__hs",
    "jarlahs",
    "lambyseriestv",
    "languagehacker",
    "leta",
    "lunaloveee8",
    "monsantohs",
    "McBanterFace",
    "nalguidan",
    "nohandsgamer",
    "rami94hs",
    "rdulive",
    "thijs",
    "viper__hs",
    "xblyzeshs",
    "surrenderhs",
    "casie1",
    "bunnyhoppor",
    "lambyseriestv"
  ]

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: @name)
  end

  def init(_args) do
    "streaming:hs:twitch_live"
    |> BackendWeb.Endpoint.subscribe()

    configure_twitter()
    {:ok, %{}}
  end

  def configure_twitter() do
    config = Application.fetch_env!(:backend, :gm_stream_twitter_info)
    ExTwitter.configure(:process, config)
  end

  def handle_info(%{topic: "streaming:hs:twitch_live", payload: %{streams: streams}}, state) do
    handle_live_streams(streams)

    {:noreply, state}
  end

  @spec gm?(Twitch.Stream.t()) :: boolean
  def gm?(stream) do
    Twitch.Stream.login(stream) in @gm_logins
  end

  @spec handle_live_streams([Twitch.Stream.t()]) :: any()
  def handle_live_streams(streams) do
    streams
    |> Enum.filter(&gm?/1)
    |> remove_existing()
    |> Enum.map(
      &new(%{
        "stream_id" => &1.id,
        "stream" => &1.user_name,
        "title" => &1.title,
        "login" => Twitch.Stream.login(&1)
      })
    )
    |> Enum.map(&Oban.insert/1)
  end

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{"stream_id" => stream_id, "stream" => stream, "title" => title, "login" => login}
      }) do
    %Stream{}
    |> Stream.changeset(%{"stream_id" => stream_id, "stream" => stream})
    |> Repo.insert()

    notify(login, stream, title)
    :ok
  end

  @spec remove_existing([Twitch.Stream.t()]) :: [Twitch.Stream.t()]
  def remove_existing(streams) do
    live_ids = streams |> Enum.map(& &1.id)

    query =
      from gms in Stream,
        select: gms.stream_id,
        where: gms.stream_id in ^live_ids

    existing_ids =
      query
      |> Repo.all()

    streams
    |> Enum.filter(&(!(to_string(&1.id) in existing_ids)))
  end

  def handle_cast({:notify, login, stream, title}, state) do
    if Application.fetch_env!(:backend, :gm_stream_send_tweet) do
      message = """
      #{stream} is live! #{title}

      #{Backend.Twitch.create_channel_link(login)}
      """

      ExTwitter.update(message)
    end

    {:noreply, state}
  end

  def notify(login, stream, title) when is_binary(login),
    do: GenServer.cast(@name, {:notify, login, stream, title})

  def notify(nil, _, _), do: nil

  # def create_state() do
  # twitch_links
  # |> String.split("\n")
  # |> Enum.map(fn link ->
  # ~r|https://www.twitch.tv/(?<login>.*)|
  # |> Regex.named_captures(link)
  # |> Map.get("login")
  # end)
  # |> Enum.filter(& &1)
  # |> MapSet.new()
  # end
  # def twitch_links() do
  # logins [
  # end
end
