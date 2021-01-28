defmodule BackendWeb.DeckviewerLive do
  @moduledoc false
  alias Components.Decklist
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
  require WaitForIt

  def mount(_params, _session, socket) do
    case WaitForIt.wait(HearthstoneJson.up?(), frequency: 500, timeout: 20_000) do
      _ -> {:ok, socket}
    end
  end

  def render(%{deckcodes: codes} = assigns) do
    show_copy_button = codes |> Enum.any?()

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
        <div class="column is-narrow" :for.with_index = {{ {deck, index} <- @deckcodes}}>
          <Decklist deck={{deck |> Deck.decode!()}} name="{{ deck |> Deck.extract_name() }}">
            <template slot="right_button">
              <a class="delete" phx-click="delete" phx-value-index={{ index }}/>
            </template>
          </Decklist>
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
      "https://www.d0nkey.top" <>
        Routes.live_path(socket, __MODULE__, %{"code" => codes |> Enum.join(",")})

    {
      :noreply,
      socket
      |> assign(:deckcodes, codes)
      |> assign(:current_link, current_link)
      |> assign(:new_deck, "")
    }
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
        to: Routes.live_path(socket, __MODULE__, %{"code" => (dc ++ new_codes) |> Enum.join(",")})
      )
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

  def handle_event("delete", %{"index" => index}, socket = %{assigns: %{deckcodes: dc}}) do
    new_codes = dc |> List.delete_at(index |> Util.to_int_or_orig())

    {
      :noreply,
      socket
      |> push_patch(
        to: Routes.live_path(socket, __MODULE__, %{"code" => new_codes |> Enum.join(",")})
      )
    }
  end
end
