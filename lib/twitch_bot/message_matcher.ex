defmodule TwitchBot.MessageMatcher do
  alias Backend.Hearthstone.Deck

  def match(config, message_info) when is_list(config) do
    config
    |> Enum.filter(& &1.enabled)
    |> Enum.map(&match(&1, message_info))
    |> Enum.map(&handle_random_chance/1)
    |> Enum.filter(& &1)
  end

  def match(%{type: "deck"} = config, %{message: message}) do
    with {:ok, %Deck{} = deck} <- Deck.decode(message),
         {:ok, db_deck} <- Backend.Hearthstone.create_or_get_deck(deck) do
      %{
        "deck_url" => Deck.link(db_deck),
        "deck_class" => deck.class,
        "deckcode" => Deck.deckcode(deck)
      }
      |> handle_result(config)
    else
      _ -> nil
    end
  end

  def match(%{type: "custom"} = config, message_info) do
    with %{} = new_config <- message_matches(config, message_info) |> handle_result(config),
         %{} = final_config <-
           sender_matches(new_config, message_info) |> handle_result(new_config) do
      final_config
    else
      _ -> false
    end
  end

  defp handle_random_chance(%{random_chance: random_chance} = ret)
       when is_number(random_chance) do
    if 100 * :rand.uniform_real() > random_chance do
      nil
    else
      ret
    end
  end

  defp handle_random_chance(ret), do: ret

  defp message_matches(%{message: matcher, message_regex: regex?, message_regex_flags: flags}, %{
         message: target
       }) do
    string_matches(target, matcher, regex?, flags)
  end

  defp sender_matches(%{sender: matcher, sender_regex: true, message_regex_flags: flags}, %{
         sender: target
       }) do
    string_matches(target, matcher, true, flags)
  end

  defp sender_matches(%{sender: nil}, %{sender: _target}), do: true

  defp sender_matches(%{sender: matcher}, %{sender: target}) do
    String.downcase(matcher) == String.downcase(target)
  end

  defp handle_result(%{} = extra_values, config) do
    Map.update(config, :extra_values, extra_values, &Map.merge(&1, extra_values))
  end

  defp handle_result(result, config) do
    result && config
  end

  defp string_matches(_target, matcher, _regex, _flags) when matcher in ["", nil] do
    true
  end

  defp string_matches(target, matcher, true = _regex, flags) when is_binary(matcher) do
    case Regex.compile(matcher, flags) do
      {:ok, r} -> string_matches(target, r, true, flags)
      _ -> nil
    end
  end

  defp string_matches(target, matcher, true = _regex, _flags) do
    case Regex.named_captures(matcher, target) do
      nil -> false
      matches -> matches
    end
  end

  defp string_matches(target, matcher, false = _regex, _flags) do
    String.starts_with?(target, matcher)
  end
end
