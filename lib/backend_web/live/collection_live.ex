defmodule BackendWeb.CollectionLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.CardsExplorer
  alias Backend.UserManager.User
  alias Backend.CollectionManager
  alias Backend.CollectionManager.Collection
  alias Components.LivePatchDropdown

  data(user, :any)
  data(params, :map)
  data(collection_display, :any)
  data(can_admin, :boolean, default: false)
  data(public, :boolean, default: false)
  data(collection_id, :any)
  data(share_link, :string)
  data(card_map, :any)
  data(multiple_collection_options, :list, default: nil)
  data(error, :any)

  @non_cards_explorer_params ["collection_id"]
  data(non_cards_explorer_params, :list, default: @non_cards_explorer_params)

  def mount(_params, session, socket),
    do:
      {:ok,
       socket
       |> assign_defaults(session)
       |> put_user_in_context()
       |> assign(:page_title, "Collection")}

  def render(assigns) do
    ~F"""
      <div>
        {#if @error == :collection_not_found}
          <div>
            <div class="title is-2">Collection Not found</div>
            <div class="title is-3">Log in to view your collection</div>
          </div>
        {#elseif @error == :not_authorize_to_view_collection}
          <div>
            <div class="title is-2">Unauthorized</div>
            <div class="title is-3">You do not have permission to view this collection.</div>
          </div>
        {#elseif @error == :not_logged_in}
          <div>
            <div class="title is-2">No Collection</div>
            <div class="title is-3">You're not logged in</div>
          </div>
        {#elseif @error == :no_collection_for_user}
          <div>
            <div class="title is-2">No Collection</div>
            <div class="title is-3">You dont have a current collection</div>
            <div class="title is-4" :if={!@multiple_collection_options}>Use <a href="https://www.firestoneapp.com/" target="_blank">Firestone<HeroIcons.external_link /></a> to sync your collections (you need to enable it in settings under third party)</div>
            <LivePatchDropdown
              :if={@multiple_collection_options}
              id="collection_collection_id"
              param="collection_id"
              title="Select Collection"
              selected_as_title={false}
              selected_to_top={false}
              options={@multiple_collection_options} />
          </div>
        {#elseif @card_map}
          <div>
            <div class="title is-2">{@page_title}</div>
            <div class="subtitle is-6">
              <span :if={current?(@user, @collection_id)}>This is your current collection</span>
              <button :if={@user && !current?(@user, @collection_id)} :on-click="make_current" class="button">Use as current</button>
              <button :if={@can_admin} :on-click="toggle_public" class="button">{public_display(@public)}: Make {public_display(!@public)}</button>
              <a :if={@can_admin && @public && @share_link} target="_blank" href={@share_link}>Share</a>
            </div>
            <FunctionComponents.Ads.below_title/>
            <CardsExplorer
              live_view={__MODULE__}
              id="cards_explorer"
              default_order_by={"mana_in_class"}
              params={@params |> Map.drop(@non_cards_explorer_params)}
              additional_url_params={%{"collection_id" => @collection_id}}
              card_disabled={fn card -> 1 > CollectionManager.card_count(@card_map, card) end}>
              <:below_card :let={card: card}>
                <div class="tw-flex tw-justify-center">
                  <div class="tag">
                    {CollectionManager.card_count(@card_map, card)}
                  </div>
                </div>
              </:below_card>
              <:dropdowns_before>
                <LivePatchDropdown
                  :if={@multiple_collection_options}
                  id="collection_collection_id"
                  param="collection_id"
                  title="Select Collection"
                  selected_as_title={false}
                  selected_to_top={false}
                  options={@multiple_collection_options} />
              </:dropdowns_before>
            </CardsExplorer>
          </div>
        {/if}
      </div>
    """
  end

  def handle_event(
        "toggle_public",
        _,
        %{assigns: %{user: user, collection_id: collection_id}} = socket
      ) do
    {:ok, coll} = CollectionManager.toggle_public(collection_id, user)

    {
      :noreply,
      socket |> assign(public: coll.public)
    }
  end

  def handle_event(
        "make_current",
        _,
        %{assigns: %{user: user, collection_id: collection_id}} = socket
      ) do
    attrs = %{current_collection_id: collection_id}

    user =
      case Backend.UserManager.update_user(user, attrs) do
        {:ok, u} -> u
        _ -> user
      end

    {
      :noreply,
      socket |> assign(user: user)
    }
  end

  def handle_info({:update_filters, params}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, params))}
  end

  def handle_params(params, _uri, socket) do
    params = CardsExplorer.filter_relevant(params, @non_cards_explorer_params)
    result = collection(params, socket)

    additional_assigns =
      case result do
        {:ok, coll} ->
          display = Collection.display(coll)

          [
            collection_id: coll.id,
            collection_display: Collection.display(coll),
            card_map: CollectionManager.card_map(coll),
            can_admin: Collection.can_admin?(coll, socket.assigns.user),
            public: coll.public,
            error: nil,
            multiple_collection_options:
              multiple_collection_options(socket.assigns.user, coll.id, display),
            page_title: "#{Collection.display(coll)}"
          ]

        {:error, error} ->
          [
            collection_id: nil,
            collection_display: nil,
            error: error,
            card_map: nil,
            multiple_collection_options:
              multiple_collection_options(socket.assigns.user, nil, nil)
          ]
      end

    assigns = [{:params, params} | additional_assigns]

    {
      :noreply,
      socket
      |> assign(assigns)
      |> LivePatchDropdown.update_context(
        __MODULE__,
        params,
        nil,
        params
      )
      |> assign_share_link()
    }
  end

  def public_display(true), do: "Public"
  def public_display(false), do: "Private"

  defp current?(%{current_collection_id: current}, collection_id) when current == collection_id,
    do: true

  defp current?(_, _), do: false

  defp assign_share_link(%{assigns: %{collection_id: id}} = socket) when is_binary(id) do
    link = LivePatchDropdown.link_with_new_url_param(socket, "collection_id", id)
    assign(socket, :share_link, link)
  end

  defp assign_share_link(socket) do
    assign(socket, :share_link, nil)
  end

  @spec collection(map(), map()) :: {:ok, Collection.t()} | {:error, atom()}
  def collection(%{"collection_id" => collection_id}, %{assigns: %{user: user}}) do
    CollectionManager.fetch_collection_for_user(user, collection_id)
  end

  def collection(_, %{assigns: %{user: nil}}), do: {:error, :not_logged_in}

  def collection(_, %{assigns: %{user: user}}) do
    case User.current_collection(user) do
      %Collection{} = c -> {:ok, c}
      _ -> {:error, :no_collection_for_user}
    end
  end

  defp multiple_collection_options(%User{} = user, nil, _) do
    case user_collection_options(user) do
      [] -> nil
      options -> options
    end
  end

  defp multiple_collection_options(%User{} = user, collection_id, collection_display) do
    options = collection_options(user, collection_id, collection_display)

    if Enum.count(options) > 1 do
      options
    end
  end

  defp multiple_collection_options(_, _, _), do: nil

  defp collection_options(%User{} = user, collection_id, collection_display) do
    options = user_collection_options(user)

    if collection_id && collection_display do
      [{collection_id, collection_display} | options]
      |> Enum.uniq_by(fn {id, _display} -> id end)
    else
      options
    end
  end

  defp user_collection_options(%User{} = user) do
    choosable = CollectionManager.choosable_by_user(user)
    Enum.map(choosable, &{&1.id, Collection.display(&1)})
  end

  defp user_collection_options(_), do: []
end
