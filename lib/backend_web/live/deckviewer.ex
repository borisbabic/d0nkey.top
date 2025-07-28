defmodule BackendWeb.DeckviewerLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.Decklist
  alias Hearthstone.DeckcodeExtractor
  alias Backend.DeckInteractionTracker, as: Tracker
  alias Backend.Hearthstone.Deck
  alias Backend.HSDeckViewer

  data(deckcodes, :any)
  data(current_link, :string)
  data(compare_decks, :boolean)
  data(rotation, :boolean)
  data(show_copy_button, :boolean)
  data(comparison, :list)
  data(user, :any)
  data(title, :string)

  def mount(_params, session, socket) do
    {:ok,
     socket |> assign_defaults(session) |> put_user_in_context() |> assign(page_title: title([]))}
  end

  def render(assigns) do
    ~F"""
      <div>
        <div class="title is-1" :if={@title}> {@title}</div>
        <br>
        <div class="level">
          <div class="level-item">
            <.form for={%{}} as={:new_deck} id="add_deck_form" phx-submit="submit" autocomplete="off">
              <div class="columns is-mobile is-multiline">
                  <div class="column is-narrow">
                    <textarea class="textarea has-fixed-size small" name="new_deck[new_code]" placeholder="Paste deckcode or link" size="30" rows="1"/>
                  </div>
                  <div class="column is-narrow">
                    <button type="submit" class="button">Add</button>
                  </div>
                  <div :if={@show_copy_button} class="column is-narrow">
                    <button class="clip-btn-value button is-shown-js" type="button" data-balloon-pos="down" data-aria-on-copy="Copied!" data-clipboard-text={"#{@current_link}"} >Copy Link</button>
                  </div>
                  <div :if={@compare_decks || @deckcodes |> Enum.count() > 1} class="column is-narrow">
                    <button phx-click="toggle_compare" class="button" type="button">{compare_button_text(@compare_decks)}</button>
                    <button phx-click="class_sort_decks" class="button" type="button">Class Sort</button>
                  </div>
                  <div :if={@deckcodes |> Enum.count() > 0} class="column is-narrow">
                    <button :on-click="toggle_rotation" class="button" type="button">{rotation_text(@rotation)}</button>
                  </div>
                  <div class= "column is-narrow" :if={@deckcodes |> Enum.any?()}>
                    <a class="is-link tag" href={"#{HSDeckViewer.create_link(@deckcodes)}"}>
                      HSDeckViewer
                    </a>
                  </div>
              </div>
            </.form>
          </div>
          <div class="level-item">
            <FunctionComponents.Ads.below_title mobile_video_mode={:off} />
          </div>
        </div>
        <div class="columns is-mobile is-multiline">
          <div class="column is-narrow" :for.with_index = {{deck, index} <- @deckcodes} :if={@compare_decks == @compare_decks}>
            <Decklist deck={deck |> Deck.decode!()} name={"#{deck |> Deck.extract_name()}"} comparison={@comparison} highlight_rotation={@rotation}>
              <:right_button>
                <a class="delete" phx-click="delete" phx-value-index={index}/>
              </:right_button>
            </Decklist>
          </div>
        </div>
      </div>
    """
  end

  def rotation_text(true), do: "Hide Rotation"
  def rotation_text(false), do: "Show Rotation"

  def compare_button_text(true), do: "Stop Comparing"
  def compare_button_text(false), do: "Compare Decks"

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
      |> assign(:title, params["title"])
      |> assign(:new_deck, "")
      |> assign(:page_title, title)
    }
  end

  def handle_event(
        "submit",
        %{"new_deck" => %{"new_code" => new_code}},
        socket = %{assigns: %{deckcodes: dc}}
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

  def handle_event("delete", %{"index" => index}, socket = %{assigns: %{deckcodes: dc}}) do
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

  def handle_event("toggle_compare", _, socket = %{assigns: %{compare_decks: cd}}) do
    {
      :noreply,
      socket
      |> push_patch(
        to: Routes.live_path(socket, __MODULE__, current_params(socket) |> add_compare_param(!cd))
      )
    }
  end

  def handle_event("class_sort_decks", _, socket = %{assigns: %{deckcodes: dc}}) do
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

  def handle_event("toggle_rotation", _, socket = %{assigns: %{rotation: rt}}) do
    {
      :noreply,
      socket
      |> push_patch(
        to:
          Routes.live_path(socket, __MODULE__, current_params(socket) |> add_rotation_param(!rt))
      )
    }
  end

  defp current_params(%{assigns: assigns}), do: current_params(assigns)

  defp current_params(assigns) do
    %{}
    |> add_existing_code(assigns)
    |> add_rotation(assigns)
    |> add_existing_compare_decks(assigns)
  end

  defp add_existing_code(map, %{deckcodes: dc}), do: add_code_param(map, dc)
  defp add_existing_code(map, _), do: map

  defp add_existing_compare_decks(map, %{compare_decks: cd}), do: add_compare_param(map, cd)
  defp add_existing_compare_decks(map, _), do: map

  defp add_rotation(map, %{rotation: rt}), do: add_rotation_param(map, rt)
  defp add_rotation(map, _), do: map

  defp add_rotation_param(map, rt), do: map |> Map.put("rotation", rt)

  defp add_compare_param(map, cd), do: map |> Map.put("compare_decks", cd)
  defp add_code_param(map, deckcodes), do: map |> Map.put("code", deckcodes |> codes_to_param())
  defp codes_to_param(codes), do: codes |> Enum.join(",")

  defp title(codes) when is_list(codes) and length(codes) > 0 do
    "Deckviewer (#{Enum.count(codes)})"
  end

  defp title(_) do
    "Deckviewer"
  end
end
