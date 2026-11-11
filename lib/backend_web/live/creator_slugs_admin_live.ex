defmodule BackendWeb.CreatorSlugsAdminLive do
  @moduledoc "Admin review of creator page short url requests"
  use BackendWeb, :surface_live_view
  alias Backend.Creators

  data(user, :any)
  data(requests, :list, default: [])
  data(approved, :list, default: [])
  data(error, :string, default: nil)

  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_defaults(session)
     |> put_user_in_context()
     |> assign(page_title: "Creator URL Requests")
     |> assign_requests()}
  end

  defp assign_requests(socket) do
    requests = Creators.slug_requests() |> Enum.map(&with_details/1)
    approved = Creators.approved_slugs() |> Enum.map(&with_details/1)
    assign(socket, requests: requests, approved: approved)
  end

  defp with_details(%{user: user, slug: slug} = profile) do
    %{
      profile: profile,
      battletag: user.battletag,
      twitch_login: Creators.twitch_login(user),
      own_match?: slug in Creators.own_channel_slugs(user),
      path: Creators.canonical_path(profile)
    }
  end

  def render(assigns) do
    ~F"""
    <div class="tw-max-w-6xl tw-mx-auto tw-p-6 tw-space-y-6">
      <.page_header title="Creator URL Requests"/>
      <p :if={@error} id="creator-slugs-error" class="tw-text-rose-300">{@error}</p>

      <section id="creator-slug-requests" class="tw-space-y-2">
        <h2 class="tw-text-lg tw-font-bold tw-text-white">To review ({Enum.count(@requests)})</h2>
        <p class="tw-text-xs tw-text-slate-400">Preapproved urls match the user's own connected Twitch login or YouTube handle and are already live, verify they make sense.</p>
        {render_table(%{rows: @requests, id: "creator-slug-requests-table", review?: true})}
      </section>

      <section id="creator-slug-approved" class="tw-space-y-2">
        <h2 class="tw-text-lg tw-font-bold tw-text-white">Recently approved</h2>
        {render_table(%{rows: @approved, id: "creator-slug-approved-table", review?: false})}
      </section>
    </div>
    """
  end

  defp render_table(assigns) do
    ~H"""
    <.table id={@id}>
      <.thead>
        <.trh>
          <.th>Url</.th>
          <.th>Status</.th>
          <.th>Battletag</.th>
          <.th>Twitch</.th>
          <.th>Matches own channel</.th>
          <.th>Requested</.th>
          <.th>Actions</.th>
        </.trh>
      </.thead>
      <.tbody>
        <.trb :for={row <- @rows} id={"creator-slug-#{row.profile.id}"}>
          <.td><code>/creator/{row.profile.slug}</code></.td>
          <.td>{row.profile.slug_status}</.td>
          <.td>{row.battletag}</.td>
          <.td>{row.twitch_login || "-"}</.td>
          <.td>{if row.own_match?, do: "Yes", else: "No"}</.td>
          <.td>{row.profile.slug_requested_at}</.td>
          <.td>
            <div class="tw-flex tw-gap-2">
              <a :if={row.path} href={row.path} target="_blank" class="button is-small">View</a>
              <button :if={@review?} id={"approve-slug-#{row.profile.id}"} phx-click="approve" phx-value-id={row.profile.id} class="button is-small is-success">Approve</button>
              <button id={"reject-slug-#{row.profile.id}"} phx-click="reject" phx-value-id={row.profile.id} class="button is-small is-danger is-outlined">
                {if @review?, do: "Reject", else: "Revoke"}
              </button>
            </div>
          </.td>
        </.trb>
      </.tbody>
    </.table>
    """
  end

  def handle_event("approve", %{"id" => id}, socket), do: set_status(socket, id, :approved)
  def handle_event("reject", %{"id" => id}, socket), do: set_status(socket, id, :rejected)

  defp set_status(socket, id, status) do
    error =
      case Creators.set_slug_status(id, status) do
        {:ok, _} -> nil
        {:error, %Ecto.Changeset{}} -> "That url is already held by another creator, revoke theirs first"
        {:error, reason} -> "Failed: #{inspect(reason)}"
      end

    {:noreply, socket |> assign(error: error) |> assign_requests()}
  end
end
