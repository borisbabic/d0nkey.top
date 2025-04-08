defmodule BackendWeb.BattlefyParticipantsLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.Battlefy.ParticipantsTable
  alias Surface.Components.Form
  alias Surface.Components.Form.TextInput

  data(tournament_id, :string)
  data(user, :any)
  data(filters, :map)
  data(participants, :any)

  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_defaults(session)
     |> put_user_in_context()}
  end

  def render(assigns) do
    ~F"""
      <div>
        <div class="title is-2">Registered Participants</div>
        <div class="subtitle is-6">
          <a href={~p"/battlefy/tournament/#{@tournament_id}"}>View Tournament</a>
          <span :if={@participants.ok?}>| Registered: #{Enum.count(@participants.result)}</span>
          <span :if={@participants.ok?}>| Checked In: #{Enum.count(@participants.result, & &1.checked_in_at)}</span>
        </div>
        <FunctionComponents.Ads.below_title/>
        <Form as={:search} change="change" submit="change">
          <TextInput id="participants_text_input" class={"input"} opts={placeholder: "Search participants"}/>
        </Form>
        <span :if={@participants.loading}>
          Loading participants...
        </span>
        <ParticipantsTable :if={@participants.ok? && @participants.result} filters={@filters} id={"participants_for_#{@tournament_id}"} participants={@participants.result} highlight={Backend.UserManager.User.battletag(@user)} tournament_id={@tournament_id} />
      </div>
    """
  end

  def handle_event("change", %{"search" => [search]}, socket) do
    {:noreply, update(socket, :filters, &Map.put(&1, "search", search))}
  end

  def handle_params(params, _uri, socket) do
    tournament_id = params["tournament_id"]

    {
      :noreply,
      socket
      |> assign(tournament_id: tournament_id, filters: %{})
      |> assign_async(:participants, fn ->
        {:ok, %{participants: Backend.Battlefy.get_participants(tournament_id)}}
      end)
    }
  end
end
