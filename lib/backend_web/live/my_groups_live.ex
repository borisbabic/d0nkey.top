defmodule BackendWeb.MyGroupsLive do
  use BackendWeb, :surface_live_view
  alias Backend.UserManager.User
  alias Components.GroupModal

  data(user, :any)
  def mount(_params, session, socket), do: {:ok, socket |> assign_defaults(session)}

  def render(assigns= %{user: %{id: _}}) do
    ~F"""
    <Context put={user: @user}>
      <div>
        <div class="title is-2">My Groups</div>
        <div class="subtitle is-6">
        Powered by <a href="https://www.firestoneapp.com/">Firestone</a> or the <a target="_blank" href="/hdt-plugin">HDT Plugin</a>
        </div>
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
    </Context>
    """
  end

  def render(assigns) do
    ~F"""
    <Context put={user: @user} >
      <div>
        <div class="title is-3">Please login to access Groups</div>
      </div>
    </Context>
    """
  end

  defp groups(user) do
    Backend.UserManager.user_groups(user)
  end
end
