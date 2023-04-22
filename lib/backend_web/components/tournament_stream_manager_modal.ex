defmodule Components.TournamentStreamManagerModal do
  @moduledoc false
  use BackendWeb, :surface_live_component
  alias Components.Modal
  alias Backend.TournamentStreams
  alias Backend.TournamentStreams.TournamentStream
  alias Backend.Stream
  alias Backend.UserManager.User

  prop(user, :map, required: true)
  prop(tournament_source, :string, required: true)
  prop(tournament_id, :string, required: true)
  data(existing, :list)

  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign_existing()}
  end

  def render(assigns) do
    ~F"""
      <div>
        <Modal
        id={"#{@user.id}#{@tournament_source}#{@tournament_id}_stream_modal"}
        button_title={button_title(@existing)}
        title="Manage Streams">
          <button :for={ts <- @existing} class="button" type="button" :on-click="delete_existing" phx-value-id={ts.id}> Remove {TournamentStream.stream_tuple(ts) |> Stream.display_name()}</button>
          <button :for={tuple = {platform, id} <- missing(@existing, @user)} class="button" type="button" :on-click="create_new" phx-value-platform={platform} phx-value-id={id}> Add {Stream.display_name(tuple)}</button>
        </Modal>
      </div>
    """
  end

  defp button_title([]), do: "Add stream"
  defp button_title([_ | _]), do: "Manage stream"

  defp assign_existing(%{assigns: assigns} = socket), do: assign_existing(socket, assigns)

  defp assign_existing(socket, %{tournament_source: source, tournament_id: id, user: user}) do
    existing = TournamentStreams.get_for_tournament_user({source, id}, user)
    assign(socket, :existing, existing)
  end

  def handle_event("delete_existing", %{"id" => id}, %{assigns: %{existing: existing}} = socket) do
    with existing when not is_nil(existing) <- Enum.find(existing, &(to_string(&1.id) == id)) do
      TournamentStreams.delete_tournament_stream(existing)
    end

    {:noreply, assign_existing(socket)}
  end

  def handle_event(
        "create_new",
        %{"platform" => platform, "id" => id},
        %{
          assigns: %{
            tournament_source: source,
            tournament_id: tournament_id,
            user: %{id: user_id}
          }
        } = socket
      ) do
    attrs =
      %{
        streaming_platform: platform,
        stream_id: id,
        user_id: user_id,
        tournament_source: source,
        tournament_id: tournament_id
      }
      |> IO.inspect(label: :attrs)

    TournamentStreams.create_tournament_stream(attrs)
    {:noreply, assign_existing(socket)}
  end

  def missing(existing, user) do
    existing_tuples = Enum.map(existing, &TournamentStream.stream_tuple/1)
    user_tuples = User.stream_tuples(user)

    user_tuples -- existing_tuples
  end
end
