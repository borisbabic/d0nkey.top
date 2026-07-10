defmodule BackendWeb.MyReplaysLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Backend.UserManager.User
  alias Components.ReplayExplorer

  data(user, :any)
  data(filters, :map)

  def mount(_params, session, socket),
    do:
      {:ok,
       socket
       |> assign_defaults(session)
       |> put_user_in_context()
       |> assign(page_title: "My Replays")}

  def render(assigns) do
    # filters
    # player class
    # opponent class
    # player rank
    # region
    ~F"""
      <div :if={@user}>
        <.page_header title={@page_title}>
          <:nav_links>
            <abbr title="Share your public replays"><a href={Routes.live_path(BackendWeb.Endpoint, BackendWeb.PlayerDecksLive, @user.battletag)} target="_blank">Share</a></abbr>
          </:nav_links>
          <:meta_info>
            <.contribution powered={true} />
          </:meta_info>
        </.page_header>
        <FunctionComponents.Ads.below_title/>
        <ReplayExplorer
          id="my-replays"
          additional_params={additional_params(@user)}
          params={@filters}
          default_period={"all"}
          live_view={__MODULE__}
          filter_context={:personal}
        />
      </div>
    """
  end

  @spec additional_params(any) :: %{optional(<<_::72, _::_*16>>) => any}
  def additional_params(user) do
    %{
      "player_btag" => User.battletag(user),
      "game_type" => Hearthstone.Enums.GameType.constructed_types()
    }
  end

  def handle_info({:update_params, params}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, params))}
  end

  def handle_params(params, _uri, socket) do
    filters = ReplayExplorer.filter_relevant(params)

    {
      :noreply,
      socket
      |> assign(:filters, filters)
    }
  end

  def handle_event("deck_copied", _, socket), do: {:noreply, socket}
end
