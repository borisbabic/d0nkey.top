defmodule TwitchBot.ConfigManager do
  import TwitchBot.Util, only: [parse_chat: 1]

  @type type :: :deck | :custom

  @type message_config :: %{
    type: type(),
    message: String.t() | nil,
    message_regex?: boolean(),
    sender: String.t() | Regex.t(),
    sender_regex?: boolean(),
    response: String.t()
  }
  @spec config(String.t()) :: [message_config()]
  def config(chat) do
    map = case Application.fetch_env(:backend, :twitch_bot_message_config) do
      {:ok, c} -> c
      _ -> test_config_map()
    end
    parsed = parse_chat(chat)
    lower_case = String.downcase(parsed)
    Map.get(map, lower_case, [])
  end

  def test_config_map() do
    %{
      "d0nkeytop" => [
        quoter("d0nkeyhs", "DDANCE :"),
        quoter("goofyronak", "RonkaPoo :"),
        deck(),
        quoter("Sgt_TBag", "Said Once while pooping in Versailles :"),
      ]
    }
  end

  def new(response, props \\ %{}) do
    %{
      type: :custom,
      message: nil,
      message_regex?: false,
      sender: nil,
      sender_regex?: false,
    }
    |> Map.merge(props)
    |> Map.put(:response, response)
  end
  def quoter(sender, sender_in_reply), do:
    new("#{sender_in_reply} \"{{ message }}\"", %{sender: sender})

  def deck(response \\ "{{ deck_url }}"), do:
    new(response, %{type: :deck})
end
