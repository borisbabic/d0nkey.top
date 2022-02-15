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
  data(rerender, :any, default: true)
  def mount(_params, session, socket), do: {:ok, socket |> assign_defaults(session)}
  def render(assigns = %{user: %{id: _}}) do
    ~F"""
      <Context put={user: @user}>
        <div :if={({group, membership} = group_membership(@group_id, @user)) && group && @rerender}>
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
                <div class="level-item" :if={membership && !GroupMembership.owner?(membership)}>
                  <button class="is-link button" :on-click="leave_group"}>Leave Group</button>
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

                <div :if={GroupMembership.admin?(membership)} class="level-item">
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
                  <th>Included in data</th>
                  <th :if={GroupMembership.admin?(membership)}>Manage</th>
                </tr>
              </thead>
              <tbody>
                <tr :for={gm <- memberships(group)}>
                  <td>{gm.user.battletag}</td>
                  <td>{gm.role}</td>
                  <td>
                  {included(gm)}
                    <button :if={({event, text} = include_data_button_props(gm)) && GroupMembership.admin?(membership)}
                      class="button" :on-click={event} phx-value-user_id={gm.user.id}>{text}</button>
                  </td>
                  <td :if={GroupMembership.admin?(membership)}>
                    <button :if={!GroupMembership.admin?(gm)} class="button" :on-click="kick_user" phx-value-user_id={gm.user.id}>Kick User</button>
                    <button :if={!GroupMembership.admin?(gm)} class="button" :on-click="make_admin" phx-value-user_id={gm.user.id}>Make Admin</button>
                    <button :if={GroupMembership.admin?(gm) && !GroupMembership.owner?(gm) && GroupMembership.owner?(membership)} class="button" :on-click="remove_admin" phx-value-user_id={gm.user.id}>Remove Admin</button>
                    <button :if={!GroupMembership.owner?(gm) && GroupMembership.owner?(membership)} class="button" :on-click="transfer_ownership" phx-value-user_id={gm.user.id}>Transfer Ownership</button>
                  </td>
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

  defp include_data_button_props(%{include_data: false}), do: {"start_using_data", "Start Using Data"}
  defp include_data_button_props(_), do: {"stop_using_data", "Stop Using Data"}
  defp included(%{include_data: false}), do: "No"
  defp included(_), do: "Yes"

  @spec memberships(Group.t()) :: [GroupMembership.t()]
  def memberships(group) do
    UserManager.get_memberships(group)
  end

  def group_membership(group_id, user) do
    group = UserManager.get_group(group_id)
    membership = case group do
      nil -> nil
      g -> UserManager.group_membership(g, user)
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
    |> handle_error(socket, rerender_fun())
  end
  def handle_event("make_admin", %{"user_id" => user_id}, socket = %{assigns: %{user: user, group_id: group_id}}) do
    UserManager.make_admin(user_id, group_id, user)
    |> handle_error(socket, rerender_fun())
  end
  def handle_event("remove_admin", %{"user_id" => user_id}, socket = %{assigns: %{user: user, group_id: group_id}}) do
    UserManager.remove_admin(user_id, group_id, user)
    |> handle_error(socket, rerender_fun())
  end
  def handle_event("join_group", _, socket = %{assigns: %{user: user, join_code: join_code, group_id: group_id}}) do
    UserManager.join_group(user, group_id, join_code)
    |> handle_error(socket, fn s ->
      push_patch(s, to: Routes.live_path(socket, __MODULE__, group_id))
    end)
  end

  def handle_event("leave_group", _, socket = %{assigns: %{user: user, group_id: group_id}}) do
    UserManager.leave_group(user, group_id)
    |> handle_error(socket, fn s ->
      push_redirect(s, to: Routes.live_path(socket, BackendWeb.MyGroupsLive))
    end)
  end
  def handle_event("transfer_ownership", %{"user_id" => user_id}, socket = %{assigns: %{user: user, group_id: group_id}}) do
    UserManager.transfer_ownership(user_id, group_id, user)
    |> handle_error(socket, rerender_fun())
  end

  def handle_event("start_using_data", %{"user_id" => user_id}, socket = %{assigns: %{user: user, group_id: group_id}}) do
    UserManager.change_include_data(user_id, group_id, user, true)
    |> handle_error(socket, rerender_fun())
  end

  def handle_event("stop_using_data", %{"user_id" => user_id}, socket = %{assigns: %{user: user, group_id: group_id}}) do
    UserManager.change_include_data(user_id, group_id, user, false)
    |> handle_error(socket, rerender_fun())
  end

  defp handle_error({:error, error}, socket, _on_success \\ & &1), do: {:noreply, assign(socket, :error_message, error)}
  defp handle_error(_, socket, on_success), do: {:noreply, on_success.(socket)}

  # stupid hack, think of something better
  defp rerender_fun(), do: fn socket ->
    socket |> assign(:rerender, Ecto.UUID.generate())
  end
end
