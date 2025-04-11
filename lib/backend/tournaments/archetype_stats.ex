defmodule Backend.Tournaments.ArchetypeStats do
  @moduledoc false
  use TypedStruct
  alias Backend.Tournaments.ArchetypeStats.HeadsUp

  typedstruct do
    field :archetype, String.t()
    field :banned, integer
    field :not_banned, integer
    field :wins, integer
    field :losses, integer
    field :total, integer
    field :heads_up, %{String.t() => HeadsUp.t()}
  end

  def init(archetype, increment \\ []) do
    %__MODULE__{
      archetype: archetype,
      banned: 0,
      not_banned: 0,
      wins: 0,
      losses: 0,
      total: 0,
      heads_up: %{}
    }
    |> increment(increment)
  end

  def increment(as, fields) do
    Enum.reduce(fields, as, fn field, acc -> Map.update!(acc, field, &(&1 + 1)) end)
  end

  @spec add_result_to_bag(
          Backend.Tournaments.archetype_stat_bag(),
          String.t(),
          String.t(),
          :wins | :losses | :draws
        ) :: t()
  def add_result_to_bag(bag, archetype, opponent, result_field) do
    fields = [result_field, :total]

    bag
    |> increment_in_bag(archetype, fields)
    |> HeadsUp.increment_in_bag(archetype, opponent, fields)
  end

  @spec increment_in_bag(Backend.Tournaments.archetype_stat_bag(), [String.t()] | String.t(), [
          atom()
        ]) :: t()
  def increment_in_bag(bag, archetypes, fields) when is_list(archetypes) do
    Enum.reduce(archetypes, bag, fn a, acc ->
      increment_in_bag(acc, a, fields)
    end)
  end

  def increment_in_bag(bag, archetype, fields) do
    Map.update(bag, archetype, init(archetype, fields), fn as -> increment(as, fields) end)
  end

  def winrate(%{wins: wins, total: total}) when total > 0 do
    wins / total
  end

  def winrate(_) do
    0
  end

  # from onkrad
  def adjusted_winrate(%{wins: wins, banned: banned, not_banned: not_banned, total: total}, :bo3)
      when total + banned + not_banned > 0 do
    (wins + banned * 29 / 33) / (total + banned + not_banned / 3.5)
  end

  # from onkrad
  def adjusted_winrate(%{wins: wins, banned: banned, not_banned: not_banned, total: total}, :bo5)
      when total + banned + not_banned > 0 do
    (wins + banned * 10 / 11) / (total + banned + not_banned / 5)
  end

  def adjusted_winrate(stats, _), do: winrate(stats)

  def supports_adjusted_winrate?(atom), do: atom in [:bo3, :bo5]
end

defmodule Backend.Tournaments.ArchetypeStats.HeadsUp do
  @moduledoc false
  use TypedStruct

  typedstruct do
    field :opponent, String.t()
    field :wins, integer
    field :losses, integer
    field :total, integer
  end

  def init(opponent, increment \\ []) do
    %__MODULE__{
      opponent: opponent,
      wins: 0,
      losses: 0,
      total: 0
    }
    |> increment(increment)
  end

  def increment(hu, fields) do
    Enum.reduce(fields, hu, fn field, acc -> Map.update!(acc, field, &(&1 + 1)) end)
  end

  @spec increment_in_bag(Backend.Tournaments.archetype_stat_bag(), String.t(), String.t(), [
          atom()
        ]) :: t()
  def increment_in_bag(bag, archetype, opponent, fields) do
    Map.update!(bag, archetype, fn as ->
      Map.update!(as, :heads_up, fn hu_bag ->
        Map.update(hu_bag, opponent, init(opponent, fields), fn hu -> increment(hu, fields) end)
      end)
    end)
  end
end
