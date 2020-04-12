defmodule Backend.HSReplay.ReplayFeedEntry do
  @moduledoc false
  use TypedStruct
  # @players ["player1", "player2"]
  typedstruct enforce: true do
    # Enum.each(@players, fn p ->
    #   field String.to_atom(p <> "_archetype"), String.t()
    #   field String.to_atom(p <> "_rank"), integer | nil
    #   field String.to_atom(p <> "_legend_rank"), integer | nil
    #   field String.to_atom(p <> "_won"), boolean
    # end)
    # todo create oop enum?
    field :player1_archetype, String.t()
    field :player1_rank, integer | nil
    field :player1_legend_rank, integer | nil
    field :player1_won, boolean
    field :player2_archetype, String.t()
    field :player2_rank, integer | nil
    field :player2_legend_rank, integer | nil
    field :player2_won, boolean
    field :id, String.t()
  end

  def parse_int_or_none(int_field) do
    case Integer.parse(int_field) do
      {int, _} -> int
      :error -> nil
    end
  end

  def parse_true_or_false(bool_field) do
    case bool_field do
      "True" -> true
      "False" -> false
    end
  end

  # def key_value(map, p, string) do
  #   key_value(map, p, string, fn x -> x end)
  # end
  # def key_value(map, p, string, mapper) do
  #   value = mapper.(map[p <> string])
  #   key = String.to_atom(p <> string)
  #   {key, value}
  # end

  def from_raw_map(map = %{"player1Rank" => _}) do
    map
    |> Recase.Enumerable.convert_keys(&Recase.to_snake/1)
    |> from_raw_map()
  end

  # def from_raw_map(map = %{"player1_rank" => _, "id" => id}) do
  #   player_fields = enum.flat_map(@players, fn p ->
  #     [
  #       key_value(map, p, "_archetype"),
  #       key_value(map, p, "_rank", &parse_int_or_none/1),
  #       key_value(map, p, "_legend_rank", &parse_int_or_none/1),
  #       key_value(map, p,"_won", &parse_true_or_false/1)
  #     ]
  #   end)
  #   all_fields = player_fields ++ [id: id]
  #   struct(__module__, all_fields)
  # end
  def from_raw_map(%{
        "player1_archetype" => player1_archetype,
        "player1_rank" => player1_rank,
        "player1_legend_rank" => player1_legend_rank,
        "player1_won" => player1_won,
        "player2_archetype" => player2_archetype,
        "player2_rank" => player2_rank,
        "player2_legend_rank" => player2_legend_rank,
        "player2_won" => player2_won,
        "id" => id
      }) do
    %__MODULE__{
      player1_archetype: parse_int_or_none(player1_archetype),
      player1_rank: parse_int_or_none(player1_rank),
      player1_legend_rank: parse_int_or_none(player1_legend_rank),
      player1_won: parse_true_or_false(player1_won),
      player2_archetype: parse_int_or_none(player2_archetype),
      player2_rank: parse_int_or_none(player2_rank),
      player2_legend_rank: parse_int_or_none(player2_legend_rank),
      player2_won: parse_true_or_false(player2_won),
      id: id
    }
  end

  # def from_raw_map(map = %{ "player1_rank" => _}) do
  #   map |> Util.update_map_to_struct(%{
  #     "player1_rank" => &parse_int_or_none/1,
  #     "player1_legend_rank" => &parse_int_or_none/1,
  #     "player1_won" => &parse_true_or_false/1,
  #     "player2_rank" => &parse_int_or_none/1,
  #     "player2_legend_rank" => &parse_int_or_none/1,
  #     "player2_won" => &parse_true_or_false/1,
  #   }, __MODULE__)
  # end
end
