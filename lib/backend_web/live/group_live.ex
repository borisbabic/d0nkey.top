defmodule BackendWeb.GroupLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Backend.UserManager
  alias Backend.UserManager.User
  alias Backend.UserManager.Group
  alias Backend.UserManager.GroupMembership
  alias Components.GroupModal
  alias Components.PlayerName

  data(user, :any)
  data(group_id, :string)
  data(group, :any, default: nil)
  data(membership, :any, default: nil)
  data(group_memberships, :any, default: nil)
  data(error_message, :string, default: nil)
  data(join_code, :string)
  data(rerender, :any, default: true)

  def mount(_params, session, socket),
    do: {:ok, socket |> assign_defaults(session) |> put_user_in_context()}

  def render(%{user: %{id: _}} = assigns) do
    ~F"""
        <div :if={@group && @membership}>
          <div class="title is-2">{@group.name}</div>
          <div class="subtitle is-6">
            Owner: {User.battletag(@group.owner)}
            <span :if={@membership && @group.discord}>
              | <a href={@group.discord} target="_blank">Discord</a>
            </span>
          </div>
          <FunctionComponents.Ads.below_title/>

            <div class="level is-mobile">
              <div class="level-left">

                <div class="level-item" :if={@membership}>
                  <a class="is-link button"  href={Routes.live_path(BackendWeb.Endpoint, BackendWeb.GroupReplaysLive, @group_id)}>Group Replays</a>
                </div>
                <div class="level-item" :if={@membership}>
                  <a class="is-link button"  href={Routes.live_path(BackendWeb.Endpoint, BackendWeb.GroupDecksLive, @group_id)}>Group Decks</a>
                </div>
                <div class="level-item" :if={@membership}>
                  <a class="is-link button"  href={Routes.live_path(BackendWeb.Endpoint, BackendWeb.GroupMatchupsLive, @group_id)}>Group Matchups</a>
                </div>
                <div class="level-item" :if={@membership && !GroupMembership.owner?(@membership)}>
                  <button class="is-link button" :on-click="leave_group"}>Leave Group</button>
                </div>
                <div class="level-item" :if={!@membership}>
                  {#if  @join_code && @join_code == @group.join_code}
                    <button class="button" :on-click="join_group">Join Group</button>
                    Your private replays and stats will be visible to the group
                  {#else }
                    You're not a member of this group. Contact the owner for access
                  {/if}
                </div>

                <div class="level-item" :if={@error_message}>
                  <div class="notification is-warning tag">{@error_message}</div>
                </div>

                <div :if={GroupMembership.admin?(@membership)} class="level-item">
                  <GroupModal id="edit_group_modal" group={@group} />
                </div>

                <div class="level-item" :if={GroupMembership.admin?(@membership)} >
                  <a class="is-link button"  href={Routes.live_path(BackendWeb.Endpoint, __MODULE__, @group_id, %{"join_code" => @group.join_code})}>Join Link</a>
                </div>

              </div>
            </div>
            <table :if={@membership} class="table is-fullwidth">
              <thead>
                <tr>
                  <th>Member</th>
                  <th>Role</th>
                  <th>Included in data</th>
                  <th :if={GroupMembership.admin?(@membership)}>Manage</th>
                </tr>
              </thead>
              <tbody>
                <tr :for={{gm, event, text} <- @memberships}>
                  <td><PlayerName player={gm.user.battletag} /></td>
                  <td>{gm.role}</td>
                  <td>
                    {included(gm)}
                  </td>
                  <td :if={GroupMembership.admin?(@membership)}>
                    <button :if={GroupMembership.admin?(@membership)}
                      class="button" :on-click={event} phx-value-user_id={gm.user.id}>{text}</button>
                    <button :if={!GroupMembership.admin?(gm)} class="button" :on-click="kick_user" phx-value-user_id={gm.user.id}>Kick User</button>
                    <button :if={!GroupMembership.admin?(gm)} class="button" :on-click="make_admin" phx-value-user_id={gm.user.id}>Make Admin</button>
                    <button :if={GroupMembership.admin?(gm) && !GroupMembership.owner?(gm) && GroupMembership.owner?(@membership)} class="button" :on-click="remove_admin" phx-value-user_id={gm.user.id}>Remove Admin</button>
                    <button :if={!GroupMembership.owner?(gm) && GroupMembership.owner?(@membership)} class="button" :on-click="transfer_ownership" phx-value-user_id={gm.user.id}>Transfer Ownership</button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

    """
  end

  def render(assigns) do
    ~F"""
      <div>
        <div class="title is-3">Please login to access this group</div>
      </div>
    """
  end

  defp include_data_button_props(%{include_data: false}),
    do: {"start_using_data", "Start Using Data"}

  defp include_data_button_props(_), do: {"stop_using_data", "Stop Using Data"}
  defp included(%{include_data: false}), do: "No"
  defp included(_), do: "Yes"

  @spec memberships(Group.t()) :: [GroupMembership.t()]
  def memberships(group) do
    UserManager.get_memberships(group)
  end

  def membership_transformer(gm) do
    {event, text} = include_data_button_props(gm)
    {gm, event, text}
  end

  @spec group_membership(integer(), User.t()) :: {Group.t(), GroupMembership.t()} | {nil, nil}
  def group_membership(group_id, user) do
    group = UserManager.get_group(group_id)

    membership =
      case group do
        nil -> nil
        g -> UserManager.group_membership(g, user)
      end

    {group, membership}
  end

  def handle_params(params, _uri, socket) do
    {
      :noreply,
      socket
      |> assign(group_id: params["group_id"], join_code: params["join_code"])
      |> assign_data()
    }
  end

  def assign_data(socket) do
    socket
    |> assign_group_and_membership()
    |> assign_memberships()
  end

  def assign_group_and_membership(%{assigns: %{group_id: group_id, user: %{id: _} = user}} = socket) do
    {group, membership} = group_membership(group_id, user)

    socket
    |> assign(group: group, membership: membership)
  end

  def assign_group_and_membership(socket), do: socket

  def assign_memberships(socket, transformer \\ &membership_transformer/1)

  def assign_memberships(%{assigns: %{group: %{id: _} = group}} = socket, transformer) do
    memberships =
      memberships(group)
      |> Enum.map(transformer)

    socket |> assign(memberships: memberships)
  end

  def assign_memberships(socket, _), do: socket

  def handle_event(
        "kick_user",
        %{"user_id" => user_id},
        %{assigns: %{user: user, group_id: group_id}} = socket
      ) do
    UserManager.kick_user(user_id, group_id, user)
    |> handle_error(socket, &assign_memberships/1)
  end

  def handle_event(
        "make_admin",
        %{"user_id" => user_id},
        %{assigns: %{user: user, group_id: group_id}} = socket
      ) do
    UserManager.make_admin(user_id, group_id, user)
    |> handle_error(socket, &assign_memberships/1)
  end

  def handle_event(
        "remove_admin",
        %{"user_id" => user_id},
        %{assigns: %{user: user, group_id: group_id}} = socket
      ) do
    UserManager.remove_admin(user_id, group_id, user)
    |> handle_error(socket, &assign_memberships/1)
  end

  def handle_event(
        "join_group",
        _,
        %{assigns: %{user: user, join_code: join_code, group_id: group_id}} = socket
      ) do
    UserManager.join_group(user, group_id, join_code)
    |> handle_error(socket, fn s ->
      push_patch(s, to: Routes.live_path(socket, __MODULE__, group_id))
    end)
  end

  def handle_event("leave_group", _, %{assigns: %{user: user, group_id: group_id}} = socket) do
    UserManager.leave_group(user, group_id)
    |> handle_error(socket, fn s ->
      push_navigate(s, to: Routes.live_path(socket, BackendWeb.MyGroupsLive))
    end)
  end

  def handle_event(
        "transfer_ownership",
        %{"user_id" => user_id},
        %{assigns: %{user: user, group_id: group_id}} = socket
      ) do
    UserManager.transfer_ownership(user_id, group_id, user)
    |> handle_error(socket, &assign_data/1)
  end

  def handle_event(
        "start_using_data",
        %{"user_id" => user_id},
        %{assigns: %{user: user, group_id: group_id}} = socket
      ) do
    UserManager.change_include_data(user_id, group_id, user, true)
    |> handle_error(socket, &assign_memberships/1)
  end

  def handle_event(
        "stop_using_data",
        %{"user_id" => user_id},
        %{assigns: %{user: user, group_id: group_id}} = socket
      ) do
    UserManager.change_include_data(user_id, group_id, user, false)
    |> handle_error(socket, &assign_memberships/1)
  end

  defp handle_error({:error, error}, socket, _on_success),
    do: {:noreply, assign(socket, :error_message, error)}

  defp handle_error(_, socket, on_success), do: {:noreply, on_success.(socket)}
end
