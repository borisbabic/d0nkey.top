defmodule BackendWeb.DeckviewerLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.Decklist
  alias Components.DeckCardsHorizontalRow
  alias Hearthstone.DeckcodeExtractor
  alias Backend.DeckInteractionTracker, as: Tracker
  alias Backend.Hearthstone.Deck
  alias Backend.HSDeckViewer
  alias FunctionComponents.ToggleGroup

  data(deckcodes, :any)
  data(current_link, :string)
  data(compare_decks, :boolean)
  data(rotation, :boolean)
  data(show_copy_button, :boolean)
  data(comparison, :list)
  data(user, :any)
  data(title, :string)
  data(view_mode, :string, default: "vertical")
  data(card_mode, :string, default: "card_top")

  def mount(_params, session, socket) do
    {:ok, socket |> assign_defaults(session) |> put_user_in_context() |> assign(page_title: title([]))}
  end

  def render(assigns) do
    ~F"""
      <div>
        <.page_header :if={@title} title={@title} />
        <br>
        <div class="level">
          <div class="level-item">
            <.form for={%{}} as={:new_deck} id="add_deck_form" phx-submit="submit" autocomplete="off">
              <div class="columns is-mobile is-multiline tw-items-center">
                  <div class="column is-narrow">
                    <textarea class="textarea has-fixed-size small" name="new_deck[new_code]" placeholder="Paste deckcode or link" aria-label="Paste deckcode or link" size="30" rows="1"/>
                  </div>
                  <div class="column is-narrow">
                    <button type="submit" class="button">Add</button>
                  </div>
                  <div :if={@show_copy_button} class="column is-narrow">
                    <button class="clip-btn-value button is-shown-js" type="button" data-balloon-pos="down" data-aria-on-copy="Copied!" data-clipboard-text={"#{@current_link}"} >Copy Link</button>
                  </div>
                  <div :if={@compare_decks || @deckcodes |> Enum.count() > 1} class="column is-narrow">
                    <ToggleGroup.group>
                      <ToggleGroup.option patch={link_with_compare(assigns, !@compare_decks)} active={@compare_decks} title="Highlight card differences between decks">
                        <:icon><ToggleGroup.compare_icon /></:icon>
                        Compare
                      </ToggleGroup.option>
                    </ToggleGroup.group>
                  </div>
                  <div :if={@compare_decks || @deckcodes |> Enum.count() > 1} class="column is-narrow">
                    <button phx-click="class_sort_decks" class="button is-small is-dark tw-inline-flex tw-items-center tw-gap-1.5" type="button" title="Sort decks by class">
                      <span class="icon is-small"><ToggleGroup.sort_icon /></span>
                      <span>Class Sort</span>
                    </button>
                  </div>
                  <div :if={@deckcodes |> Enum.count() > 0} class="column is-narrow">
                    <ToggleGroup.group>
                      <ToggleGroup.option patch={link_with_rotation(assigns, !@rotation)} active={@rotation} title="Highlight cards rotating out of Standard">
                        <:icon><ToggleGroup.rotate_icon /></:icon>
                        Rotation
                      </ToggleGroup.option>
                    </ToggleGroup.group>
                  </div>
                  <div :if={@deckcodes |> Enum.count() > 0} class="column is-narrow">
                    <ToggleGroup.group>
                      <ToggleGroup.option patch={link_with_view_mode(assigns, "vertical")} active={@view_mode != "horizontal"} title="Vertical View">
                        <:icon><ToggleGroup.grid_icon /></:icon>
                        Vertical
                      </ToggleGroup.option>
                      <ToggleGroup.option patch={link_with_view_mode(assigns, "horizontal")} active={@view_mode == "horizontal"} title="Horizontal View">
                        <:icon><ToggleGroup.table_icon /></:icon>
                        Horizontal
                      </ToggleGroup.option>
                    </ToggleGroup.group>
                  </div>
                  <div :if={@view_mode == "horizontal" and @deckcodes |> Enum.count() > 0} class="column is-narrow">
                    <ToggleGroup.group>
                      <ToggleGroup.option
                        patch={link_with_card_mode(assigns, "card_top")}
                        active={@card_mode != "cropped_art"}
                        title="Card Top View (Cut off below rarity gem)"
                      >
                        <:icon><ToggleGroup.card_top_icon /></:icon>
                        Card Top
                      </ToggleGroup.option>
                      <ToggleGroup.option
                        patch={link_with_card_mode(assigns, "cropped_art")}
                        active={@card_mode == "cropped_art"}
                        title="Cropped Card View (Card art with stat overlays)"
                      >
                        <:icon><ToggleGroup.cropped_icon /></:icon>
                        Cropped Card
                      </ToggleGroup.option>
                    </ToggleGroup.group>
                  </div>
                  <div class="column is-narrow" :if={@deckcodes |> Enum.any?()}>
                    <Components.Socials.social link={HSDeckViewer.create_link(@deckcodes)} label="HSDeckViewer" />
                  </div>
              </div>
            </.form>
          </div>
          <div class="level-item">
            <FunctionComponents.Ads.below_title mobile_video_mode={:off} />
          </div>
        </div>
        <div :if={@view_mode != "horizontal"} class="columns is-mobile is-multiline">
          <div class="column is-narrow" :for.with_index = {{deck, index} <- @deckcodes} :if={@compare_decks == @compare_decks}>
            <Decklist deck={deck |> Deck.decode!()} name={"#{deck |> Deck.extract_name()}"} comparison={@comparison} highlight_rotation={@rotation}>
              <:right_button>
                <button type="button" class="delete" aria-label="Remove deck" phx-click="delete" phx-value-index={index}></button>
              </:right_button>
            </Decklist>
          </div>
        </div>
        <div :if={@view_mode == "horizontal"} class="tw-flex tw-flex-col tw-gap-3">
          <div
            :for.with_index={{deck, index} <- @deckcodes}
            class="tw-rounded-xl tw-border tw-border-slate-800 has-background-dark tw-p-3"
          >
            <DeckCardsHorizontalRow deck={deck |> Deck.decode!()} name={"#{deck |> Deck.extract_name()}"} user={@user} card_mode={@card_mode}>
              <:right>
                <button type="button" class="delete" aria-label="Remove deck" phx-click="delete" phx-value-index={index}></button>
              </:right>
            </DeckCardsHorizontalRow>
          </div>
        </div>
      </div>
    """
  end

  def handle_params(params, _uri, socket) do
    codes =
      params["code"]
      |> case do
        code = [_ | _] -> code
        string when is_binary(string) -> string |> String.split(",")
        _ -> []
      end
      |> Enum.filter(fn code -> :ok == code |> Deck.decode() |> elem(0) end)

    current_link =
      "https://www.hsguru.com" <>
        Routes.live_path(socket, __MODULE__, %{"code" => codes |> Enum.join(",")})

    compare_decks = params["compare_decks"] == "true"

    rotation = params["rotation"] == "true"

    view_mode = if params["view_mode"] == "horizontal", do: "horizontal", else: "vertical"
    card_mode = if params["card_mode"] == "cropped_art", do: "cropped_art", else: "card_top"

    title =
      with nil <- params["title"] do
        title(codes)
      end

    show_copy_button = codes |> Enum.any?()

    comparison =
      if compare_decks do
        codes
        |> Deck.create_comparison_map()
      else
        nil
      end

    {
      :noreply,
      socket
      |> assign(:deckcodes, codes)
      |> assign(:current_link, current_link)
      |> assign(:compare_decks, compare_decks)
      |> assign(:comparison, comparison)
      |> assign(:show_copy_button, show_copy_button)
      |> assign(:rotation, rotation)
      |> assign(:view_mode, view_mode)
      |> assign(:card_mode, card_mode)
      |> assign(:title, params["title"])
      |> assign(:new_deck, "")
      |> assign(:page_title, title)
    }
  end

  def handle_event(
        "submit",
        %{"new_deck" => %{"new_code" => new_code}},
        %{assigns: %{deckcodes: dc}} = socket
      ) do
    new_codes = DeckcodeExtractor.extract_decks(new_code)

    {
      :noreply,
      socket
      |> push_patch(
        to:
          Routes.live_path(
            socket,
            __MODULE__,
            current_params(socket) |> add_code_param(dc ++ new_codes)
          )
      )
    }
  end

  def handle_event("delete", %{"index" => index}, %{assigns: %{deckcodes: dc}} = socket) do
    new_codes = dc |> List.delete_at(index |> Util.to_int_or_orig())

    {
      :noreply,
      socket
      |> push_patch(
        to:
          Routes.live_path(
            socket,
            __MODULE__,
            current_params(socket) |> add_code_param(new_codes)
          )
      )
    }
  end

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end

  def handle_event("class_sort_decks", _, %{assigns: %{deckcodes: dc}} = socket) do
    new_codes = dc |> Enum.sort_by(&(&1 |> Deck.decode!() |> Deck.class()))

    {
      :noreply,
      socket
      |> push_patch(
        to:
          Routes.live_path(
            socket,
            __MODULE__,
            current_params(socket) |> add_code_param(new_codes)
          )
      )
    }
  end

  defp current_params(%{assigns: assigns}), do: current_params(assigns)

  defp current_params(assigns) do
    %{}
    |> add_existing_code(assigns)
    |> add_rotation(assigns)
    |> add_existing_compare_decks(assigns)
    |> add_existing_view_mode(assigns)
    |> add_existing_card_mode(assigns)
  end

  defp add_existing_code(map, %{deckcodes: dc}), do: add_code_param(map, dc)
  defp add_existing_code(map, _), do: map

  defp add_existing_compare_decks(map, %{compare_decks: cd}), do: add_compare_param(map, cd)
  defp add_existing_compare_decks(map, _), do: map

  defp add_existing_view_mode(map, %{view_mode: vm}), do: add_view_mode_param(map, vm)
  defp add_existing_view_mode(map, _), do: map

  defp add_existing_card_mode(map, %{card_mode: cm}), do: add_card_mode_param(map, cm)
  defp add_existing_card_mode(map, _), do: map

  defp add_rotation(map, %{rotation: rt}), do: add_rotation_param(map, rt)
  defp add_rotation(map, _), do: map

  defp add_rotation_param(map, rt), do: map |> Map.put("rotation", rt)

  defp add_view_mode_param(map, vm), do: map |> Map.put("view_mode", vm)

  defp add_card_mode_param(map, cm), do: map |> Map.put("card_mode", cm)

  defp add_compare_param(map, cd), do: map |> Map.put("compare_decks", cd)
  defp add_code_param(map, deckcodes), do: map |> Map.put("code", deckcodes |> codes_to_param())
  defp codes_to_param(codes), do: codes |> Enum.join(",")

  defp link_with_rotation(assigns, rt), do: link_with(assigns, "rotation", rt)
  defp link_with_compare(assigns, cd), do: link_with(assigns, "compare_decks", cd)
  defp link_with_view_mode(assigns, vm), do: link_with(assigns, "view_mode", vm)
  defp link_with_card_mode(assigns, cm), do: link_with(assigns, "card_mode", cm)

  defp link_with(assigns, param, value) do
    params = current_params(assigns) |> Map.put(param, value)
    Routes.live_path(BackendWeb.Endpoint, __MODULE__, params)
  end

  defp title(codes) when is_list(codes) and (is_list(codes) and codes != []) do
    "Deckviewer (#{Enum.count(codes)})"
  end

  defp title(_) do
    "Deckviewer"
  end
end
