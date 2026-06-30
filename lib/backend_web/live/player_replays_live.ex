defmodule BackendWeb.PlayerReplaysLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.ReplayExplorer

  data(user, :any)
  data(player_btag, :any)
  data(filters, :map)

  def mount(_params, session, socket),
    do: {:ok, socket |> assign_defaults(session) |> put_user_in_context()}

  def render(assigns) do
    # filters
    # player class
    # opponent class
    # player rank
    # region
    ~F"""
      <div>
        <.page_header title={@page_title}>
          <:meta_info>
            <.contribution powered={true} />
          </:meta_info>
        </.page_header>
        <FunctionComponents.Ads.below_title />
        <ReplayExplorer
          show_player_btag={true}
          path_params={@player_btag}
          id="my-replays"
          additional_params={additional_params(@player_btag)}
          params={@filters}
          live_view={__MODULE__}/>
      </div>
    """
  end

  def additional_params(player_btag) do
    %{
      "player_btag" => player_btag,
      "public" => true,
      "game_type" => Hearthstone.Enums.GameType.constructed_types()
    }
  end

  def handle_info({:update_params, params}, %{assigns: %{player_btag: player_btag}} = socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, player_btag, params))}
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
      |> assign(:player_btag, params["player_btag"])
      |> assign(:page_title, title(params["player_btag"]))
    }
  end

  defp title(battletag) when is_binary(battletag) do
    "#{battletag}'s Replays"
  end

  defp title(_battletag), do: title("Unknown Player")

  def handle_event("deck_copied", _, socket), do: {:noreply, socket}
end
