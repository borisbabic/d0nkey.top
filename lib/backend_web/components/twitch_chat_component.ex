defmodule Components.TwitchChat do
  @moduledoc "Subscribes and shows a twitch chat"
  use BackendWeb, :surface_live_component

  prop(channel, :string, required: true)
  prop(limit, :integer, default: -20)
  data(incoming_items, :list, default: [])

  defmacro __using__(opts) do
    subs_quote =
      for component_id <-  Keyword.get(opts, :component_ids) do
        quote do
          def handle_info(
                %{topic: "twitch:chat:" <> _, event: "new_message", payload: %{message_info: message_info}},
                socket
              ) do
            send_update(Components.TwitchChat,
              id: unquote(component_id),
              incoming_items: [message_info]
            )

            {:noreply, socket}
          end
      end
    end

    if Keyword.get(opts, :alias, true) do
      alias_quote =
        quote do
          alias Components.TwitchChat
        end

      [alias_quote | subs_quote]
    else
      subs_quote
    end
  end

  def update(%{incoming_items: unfiltered_incoming_items}, socket) do
    normalized_chat = socket.assigns.channel |> TwitchBot.Handler.normalize_chat()
    incoming_items = Enum.filter(unfiltered_incoming_items, fn %{chat: chat} ->
      TwitchBot.Handler.normalize_chat(chat) == normalized_chat
    end)

    {:ok, socket |> stream(:twitch_chat, incoming_items, limit: socket.assigns.limit)}
  end

  def update(assigns, socket) do
    normalized_channel = TwitchBot.Handler.normalize_chat(assigns.channel)
    TwitchBot.Handler.subscribe_to_chat(normalized_channel)
    {:ok, socket |> assign(assigns) |> assign(channel: normalized_channel) |> init_stream()}
  end

  def render(assigns) do
    ~F"""
      <div>
        Hello World {@channel}
        <div
        id={"twitch_chat_viewport" <> @id <> @channel}
        phx-update={"stream"}
        >
          <div id={dom_id} :for={{dom_id, message_info} <- @streams.twitch_chat}>
            <span><span class="tw-font-bold" style={style(message_info.tags)}>{message_info.sender}</span>: <span>{message_info.message}</span></span>
          </div>
        </div>
      </div>
    """
  end

  defp style(%{"color" => color}) when is_binary(color) do
    "color: #{color}"
  end

  defp style(_), do: ""

  defp init_stream(socket) do
    stream(socket, :twitch_chat, [])
  end
end
