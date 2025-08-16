defmodule BackendWeb.TournamentStreamController do
  use BackendWeb, :controller

  alias Backend.Streaming
  alias Backend.Tournaments
  alias Backend.TournamentStreams
  alias Backend.TournamentStreams.TournamentStream

  plug(:put_root_layout, {BackendWeb.LayoutView, "torch.html"})
  plug(:put_layout, false)
  plug(Backend.Plug.AdminAuth, role: :tournament_streams)

  def index(conn, params) do
    case TournamentStreams.paginate_tournament_streams(params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)

      error ->
        conn
        |> put_flash(:error, "There was an error rendering tournament_streams. #{inspect(error)}")
        |> redirect(to: Routes.tournament_stream_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = TournamentStreams.change_tournament_stream(%TournamentStream{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"tournament_stream" => tournament_stream_params}) do
    case TournamentStreams.create_tournament_stream(tournament_stream_params) do
      {:ok, tournament_stream} ->
        conn
        |> put_flash(:info, "Tournament stream created successfully.")
        |> redirect(to: Routes.tournament_stream_path(conn, :show, tournament_stream))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    tournament_stream = TournamentStreams.get_tournament_stream!(id)
    render(conn, "show.html", tournament_stream: tournament_stream)
  end

  def edit(conn, %{"id" => id}) do
    tournament_stream = TournamentStreams.get_tournament_stream!(id)
    changeset = TournamentStreams.change_tournament_stream(tournament_stream)
    render(conn, "edit.html", tournament_stream: tournament_stream, changeset: changeset)
  end

  def update(conn, %{"id" => id, "tournament_stream" => tournament_stream_params}) do
    tournament_stream = TournamentStreams.get_tournament_stream!(id)

    case TournamentStreams.update_tournament_stream(tournament_stream, tournament_stream_params) do
      {:ok, tournament_stream} ->
        conn
        |> put_flash(:info, "Tournament stream updated successfully.")
        |> redirect(to: Routes.tournament_stream_path(conn, :show, tournament_stream))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", tournament_stream: tournament_stream, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    tournament_stream = TournamentStreams.get_tournament_stream!(id)

    {:ok, _tournament_stream} =
      TournamentStreams.delete_tournament_stream(
        tournament_stream,
        BackendWeb.AuthUtils.user(conn)
      )

    conn
    |> put_flash(:info, "Tournament stream deleted successfully.")
    |> redirect(to: Routes.tournament_stream_path(conn, :index))
  end

  def twitch_batch(conn, _params) do
    render(conn, "twitch_batch.html")
  end

  def twitch_batch_insert(conn, %{"batch" => batch}) do
    tournament_source = batch["tournament_source"] |> Tournaments.parse_source()
    tournament_id = batch["tournament_id"] |> Tournaments.parse_id(tournament_source)

    base_attrs = %{
      "tournament_source" => tournament_source,
      "tournament_id" => tournament_id,
      "streaming_platform" => "twitch"
    }

    twitch_logins = parse_twitch_links(batch["twitch_links"])

    existing_ids =
      TournamentStreams.get_for_tournament({tournament_source, tournament_id})
      |> Enum.map(& &1.stream_id)

    new_streamers =
      Streaming.streamers([{"twitch_login", twitch_logins}])
      |> Enum.filter(&(&1.twitch_id not in existing_ids))

    for %{twitch_id: twitch_id} <- new_streamers do
      attrs = Map.put(base_attrs, "stream_id", twitch_id |> to_string())
      TournamentStreams.create_tournament_stream(attrs)
    end

    redirect(conn, to: Routes.tournament_stream_path(conn, :index))
  end

  defp parse_twitch_links(twitch_links) when is_binary(twitch_links) do
    String.split(twitch_links, ["\n", "\r\n"])
    |> parse_twitch_links()
  end

  defp parse_twitch_links(twitch_links) when is_list(twitch_links) do
    Enum.map(twitch_links, &Streaming.extract_twitch_login/1)
    |> Enum.filter(& &1)
  end
end
