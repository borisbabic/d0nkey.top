defmodule BackendWeb.DeckviewerLive do
  @moduledoc false
  alias Components.Decklist
  alias Backend.DeckInteractionTracker, as: Tracker
  alias Backend.Hearthstone
  alias Backend.Hearthstone.Deck
  alias Backend.HearthstoneJson
  alias Backend.HSDeckViewer
  alias Backend.Yaytears
  alias Surface.Components.Form
  alias Surface.Components.Form.Field
  alias Surface.Components.Form.TextArea
  alias Surface.Components.Form.Submit
  alias BackendWeb.Router.Helpers, as: Routes
  use Surface.LiveView
  data(deckcodes, :any)
  data(current_link, :string)
  data(compare_decks, :boolean)
  require WaitForIt

  def mount(_params, _session, socket) do
    case WaitForIt.wait(HearthstoneJson.up?(), frequency: 500, timeout: 20_000) do
      _ -> {:ok, socket}
    end
  end

  def render(assigns = %{deckcodes: codes, compare_decks: cd}) do
    show_copy_button = codes |> Enum.any?()

    comparison =
      if cd do
        codes
        |> Enum.map(&Deck.decode!/1)
        |> Enum.flat_map(& &1.cards)
        |> Enum.uniq()
        |> Enum.map(&HearthstoneJson.get_card/1)
        |> Hearthstone.sort_cards()
      else
        nil
      end

    ~H"""

    <div class="container">
      <br>
      <Form for={{ :new_deck }} submit="submit" opts={{ autocomplete: "off" }}>
        <div class="columns is-mobile is-multiline">
          <Field name="new_code">
            <div class="column is-narrow">
              <TextArea class="textarea has-fixed-size small" opts={{ placeholder: "Paste deckcode or link", size: "30", rows: "1"}}/>
            </div>
          </Field>
            <div class="column is-narrow">
              <Submit label="Add" class="button"/>
            </div>
            <div :if={{ show_copy_button }} class="column is-narrow">
              <button class="clip-btn-value button is-shown-js" type="button" data-balloon-pos="down" data-aria-on-copy="Copied!" data-clipboard-text="{{ @current_link }}" >Copy Link</button>
            </div>
            <div :if={{ cd || @deckcodes |> Enum.count() > 1}} class="column is-narrow">
              <button phx-click="toggle_compare" class="button" type="button">{{ compare_button_text(@compare_decks) }}</button>
            </div>

            <div class= "column is-narrow" :if={{ @deckcodes |> Enum.any?() }}>
              <a class="is-link tag" href="{{ Yaytears.create_deckstrings_link(@deckcodes)  }}">
                yaytears
            </a>
              <a class="is-link tag" href="{{ HSDeckViewer.create_link(@deckcodes) }}">
                HSDeckViewer
            </a>
        </div>
        </div>
      </Form>
      <div class="columns is-mobile is-multiline">
        <div class="column is-narrow" :for.with_index = {{ {deck, index} <- @deckcodes}} :if={{@compare_decks == @compare_decks}}>
          <Decklist deck={{deck |> Deck.decode!()}} name="{{ deck |> Deck.extract_name() }}" comparison={{ comparison }}>
            <template slot="right_button">
              <a class="delete" phx-click="delete" phx-value-index={{ index }}/>
            </template>
          </Decklist>
        </div>
      </div>
    </div>
    """
  end

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
      "https://www.d0nkey.top" <>
        Routes.live_path(socket, __MODULE__, %{"code" => codes |> Enum.join(",")})

    compare_decks = params["compare_decks"] == "true"

    {
      :noreply,
      socket
      |> assign(:deckcodes, codes)
      |> assign(:current_link, current_link)
      |> assign(:compare_decks, compare_decks)
      |> assign(:new_deck, "")
    }
  end

  def our_link?(new_code) when is_binary(new_code), do: new_code =~ "d0nkey.top"
  def our_link?(_), do: false

  def extract_codes(link) do
    with %{query: query} when is_binary(query) <- link |> URI.parse(),
         <<"code="::binary, codes_part::binary>> <- URI.decode(query) do
      codes_part |> String.split(",") |> Enum.filter(&(bit_size(&1) > 0))
    else
      _ -> []
    end
  end

  def handle_event(
        "submit",
        %{"new_deck" => %{"new_code" => new_code}},
        socket = %{assigns: %{deckcodes: dc}}
      ) do
    new_codes =
      cond do
        HSDeckViewer.hdv_link?(new_code) -> HSDeckViewer.extract_codes(new_code)
        Yaytears.yt_link?(new_code) -> Yaytears.extract_codes(new_code)
        our_link?(new_code) -> extract_codes(new_code)
        true -> [new_code]
      end
      |> Deck.shorten_codes()

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

  defp current_params(%{assigns: assigns}), do: current_params(assigns)

  defp current_params(assigns) do
    %{}
    |> add_existing_code(assigns)
    |> add_existing_compare_decks(assigns)
  end

  defp add_existing_code(map, %{deckcodes: dc}), do: add_code_param(map, dc)
  defp add_existing_code(map, _), do: map

  defp add_existing_compare_decks(map, %{compare_decks: cd}), do: add_compare_param(map, cd)
  defp add_existing_compare_decks(map, _), do: map

  defp add_compare_param(map, cd), do: map |> Map.put("compare_decks", cd)
  defp add_code_param(map, deckcodes), do: map |> Map.put("code", deckcodes |> codes_to_param())
  defp codes_to_param(codes), do: codes |> Enum.join(",")
end
