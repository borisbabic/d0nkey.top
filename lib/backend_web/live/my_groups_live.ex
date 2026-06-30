defmodule BackendWeb.MyGroupsLive do
  use BackendWeb, :surface_live_view
  alias Backend.UserManager.User
  alias Components.GroupModal

  data(user, :any)

  def mount(_params, session, socket),
    do:
      {:ok,
       socket
       |> assign_defaults(session)
       |> put_user_in_context()
       |> assign(page_title: "My Groups")}

  def render(%{user: nil}) do
    Helper.needs_login(%{})
  end

  def render(%{user: %{id: _}} = assigns) do
    ~F"""
      <div>
        <.page_header title="My Groups">
          <:meta_info>
            <.contribution powered={true} />
          </:meta_info>
        </.page_header>
        <FunctionComponents.Ads.below_title/>
      </div>

      <.filter_container>
        <GroupModal id="group_modal" />
      </.filter_container>

      <.table id="groups_table">
        <.thead>
          <.trh>
            <.th>Group</.th>
            <.th>Owner</.th>
            <.th>View</.th>
          </.trh>
        </.thead>
        <.tbody>
          <.trb :for={group <- groups(@user)}>
            <.td>{group.name}</.td>
            <.td>{User.battletag(group.owner)}</.td>
            <.td><a href={Routes.live_path(BackendWeb.Endpoint, BackendWeb.GroupLive, group.id)}>View</a></.td>
          </.trb>
        </.tbody>
      </.table>
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
