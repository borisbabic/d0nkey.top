defmodule Backend.Repo.Migrations.FillCardTallyExtraInfo do
  use Ecto.Migration

  def up do
    up = """
    UPDATE public.dt_card_game_tally t SET deck_id = g.player_deck_id, inserted_at = g.inserted_at FROM public.dt_games g WHERE g.id = t.game_id;
    """

    execute(up)
  end

  def down() do
  end
end
