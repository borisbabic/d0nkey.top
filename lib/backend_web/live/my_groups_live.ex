defmodule BackendWeb.MyGroupsLive do
  use BackendWeb, :surface_live_view
  alias Backend.UserManager.User
  alias Components.GroupModal

  data(user, :any)

  def mount(_params, session, socket),
    do: {:ok, socket |> assign_defaults(session) |> put_user_in_context()}

  def render(assigns = %{user: %{id: _}}) do
    ~F"""
      <div>
        <div class="title is-2">My Groups</div>
        <div class="subtitle is-6">
        Powered by <a href="https://www.firestoneapp.com/">Firestone</a> or the <a target="_blank" href="/hdt-plugin">HDT Plugin</a>
        </div>
        <div phx-update="ignore" id="nitropay-below-title-leaderboard"></div><br>
      </div>

      <GroupModal id="group_modal" />

      <table class="table is-fullwidth">
        <thead>
          <tr>
            <th>Group</th>
            <th>Owner</th>
            <th>View</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={group <- groups(@user)}>
            <td>{group.name}</td>
            <td>{User.battletag(group.owner)}</td>
            <td><a href={Routes.live_path(BackendWeb.Endpoint, BackendWeb.GroupLive, group.id)}>View</a></td>
          </tr>
        </tbody>
      </table>
    """
  end

  def render(assigns) do
    ~F"""
      <div>
        <div class="title is-3">Please login to access Groups</div>
      </div>
    """
  end

  defp groups(user) do
    Backend.UserManager.user_groups(user)
  end
end
