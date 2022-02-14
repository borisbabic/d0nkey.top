defmodule BackendWeb.GroupLive do
  use BackendWeb, :surface_live_view
  alias Backend.UserManager
  alias Backend.UserManager.User
  alias Backend.UserManager.Group
  alias Backend.UserManager.GroupMembership
  alias Components.GroupModal


  data(user, :any)
  data(group_id, :string)
  data(error_message, :string, default: nil)
  data(join_code, :string)
  def mount(_params, session, socket), do: {:ok, socket |> assign_defaults(session)}
  def render(assigns = %{user: %{id: _}}) do
    ~F"""
      <Context put={user: @user}>
        <div :if={({group, membership} = group_membership(@group_id, @user)) && group}>
          <div class="title is-2">{group.name}</div>
          <div class="subtitle is-6">
            Owner: {User.battletag(group.owner)}
            <span :if={membership && group.discord}>
              | <a href={group.discord} target="_blank">Discord</a>
            </span>
          </div>

            <div class="level is-mobile">
              <div class="level-left">

                <div class="level-item" :if={membership}>
                  <a class="is-link button"  href={Routes.live_path(BackendWeb.Endpoint, BackendWeb.GroupReplaysLive, @group_id)}>Group Replays</a>
                </div>
                <div class="level-item" :if={membership}>
                  <a class="is-link button"  href={Routes.live_path(BackendWeb.Endpoint, BackendWeb.GroupDecksLive, @group_id)}>Group Decks</a>
                </div>
                <div class="level-item" :if={!membership}>
                  {#if  @join_code && @join_code == group.join_code}
                    <button class="button" :on-click="join_group">Join Group</button>
                    Your private replays and stats will be visible to the group
                  {#else }
                    You're not a member of this group. Contact the owner for access
                  {/if}
                </div>

                <div class="level-item" :if={@error_message}>
                  <div class="notification is-warning tag">{@error_message}</div>
                </div>

                <div :if={GroupMembership.owner?(membership)} class="level-item">
                  <GroupModal id="edit_group_modal"} group={group} />
                </div>

                <div class="level-item" :if={GroupMembership.admin?(membership)} >
                  <a class="is-link button"  href={Routes.live_path(BackendWeb.Endpoint, __MODULE__, @group_id, %{"join_code" => group.join_code})}>Join Link</a>
                </div>

              </div>
            </div>
            <table :if={membership} class="table is-fullwidth">
              <thead>
                <tr>
                  <th>Member</th>
                  <th>Role</th>
                  <th :if={GroupMembership.admin?(membership)}>Manage</th>
                </tr>
              </thead>
              <tbody>
                <tr :for={gm <- memberships(group)}>
                  <td>{gm.user.battletag}</td>
                  <td>{gm.role}</td>
                  <th :if={GroupMembership.admin?(membership)}>
                    <button :if={!GroupMembership.admin?(gm)} class="button" :on-click="kick_user" phx-value-user_id={gm.user.id}>Kick User</button>
                    <button :if={!GroupMembership.admin?(gm)} class="button" :on-click="make_admin" phx-value-user_id={gm.user.id}>Make Admin</button>
                    <button :if={GroupMembership.admin?(gm) && !GroupMembership.owner?(gm) && GroupMembership.owner?(membership)} class="button" :on-click="remove_admin" phx-value-user_id={gm.user.id}>Remove Admin</button>
                  </th>
                </tr>
              </tbody>
            </table>
          </div>

      </Context>
    """
  end

  def render(assigns) do
    ~F"""
    <Context put={user: @user} >
      <div>
        <div class="title is-3">Please login to access this group</div>
      </div>
    </Context>
    """
  end

  @spec memberships(Group.t()) :: [GroupMembership.t()]
  def memberships(group) do
    UserManager.get_memberships(group)
  end

  def group_membership(group_id, user) do
    group = UserManager.get_group(group_id)
    membership = case group do
      nil -> nil
      g -> UserManager.group_membership(group, user)
    end
    {group, membership}
  end

  def handle_params(params, _uri, socket) do
    {
      :noreply,
      socket |> assign(group_id: params["group_id"], join_code: params["join_code"])
    }
  end

  def handle_event("kick_user", %{"user_id" => user_id}, socket = %{assigns: %{user: user, group_id: group_id}}) do
    UserManager.kick_user(user_id, group_id, user)
    {:noreply, socket}
  end
  def handle_event("make_admin", %{"user_id" => user_id}, socket = %{assigns: %{user: user, group_id: group_id}}) do
    UserManager.make_admin(user_id, group_id, user)
    {:noreply, socket}
  end
  def handle_event("remove_admin", %{"user_id" => user_id}, socket = %{assigns: %{user: user, group_id: group_id}}) do
    socket = case UserManager.remove_admin(user_id, group_id, user) do
      {:error, error} -> socket |> assign(:error_message, error)
      _ -> socket
    end
    {:noreply, socket}
  end
  def handle_event("join_group", _, socket = %{assigns: %{user: user, join_code: join_code, group_id: group_id}}) do
    socket = case UserManager.join_group(user, group_id, join_code) do
      {:ok, _membership} ->
        socket
        |> push_patch(
          to: Routes.live_path(socket, __MODULE__, group_id)
        )
      _ -> socket |> assign(:error_message, "Error joining league")
    end
    {:noreply, socket}
  end
end
