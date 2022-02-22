defmodule TwitchBot.MessageMatcher do
  alias Backend.Hearthstone.Deck

  def match(config, message_info) when is_list(config) do
    Enum.map(config, & match(&1, message_info))
    |> Enum.filter(& &1)
  end

  def match(config = %{type: :deck}, %{message: message}) do
    with {:ok, deck} <- Deck.decode(message),
      {:ok, %{id: id}} <- Backend.Hearthstone.create_or_get_deck(deck) do
        %{
          "deck_url" => "https://www.d0nkey.top/deck/#{id}",
          "deck_class" => deck.class,
          "deckcode" => Deck.deckcode(deck)
        }
        |> handle_result(config)
    else
      _ -> nil
    end
  end

  def match(config = %{type: :custom}, message_info) do
    with new_config = %{} <- message_matches(config, message_info) |> handle_result(config) ,
        final_config = %{} <- sender_matches(new_config, message_info) |> handle_result(new_config) do
          final_config
    else
      _ -> false
    end
  end

  defp message_matches(%{message: matcher, message_regex?: regex?}, %{message: target}) do
    string_matches(target, matcher, regex?)
  end
  defp sender_matches(%{sender: matcher, sender_regex?: true}, %{sender: target}) do
    string_matches(target, matcher, true)
  end
  defp sender_matches(%{sender: nil}, %{sender: target}), do: true
  defp sender_matches(%{sender: matcher}, %{sender: target}) do
    String.downcase(matcher) == String.downcase(target)
  end
  defp handle_result(extra_values = %{}, config) do
    Map.update(config, :extra_values, extra_values, & Map.merge(&1, extra_values))
  end
  defp handle_result(result, config) do
    result && config
  end
  defp string_matches(_target, matcher, _regex) when matcher in ["", nil] do
    true
  end
  defp string_matches(target, matcher, _regex = true) when is_binary(matcher) do
    case Regex.compile(matcher) do
      {:ok, r} -> string_matches(target, r, true)
      _ -> nil
    end
  end
  defp string_matches(target, matcher, _regex = true) do
    case Regex.named_captures(matcher, target) do
      nil -> false
      matches -> matches
    end
  end

  defp string_matches(target, matcher, _regex = false) do
    String.starts_with?(target, matcher)
  end
end
