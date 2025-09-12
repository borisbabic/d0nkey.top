defmodule Backend.Repo.Migrations.SeedDefaultFormats do
  use Ecto.Migration

  def change do
    sql = """
    INSERT INTO public.formats
    ("default", display, game_type, value, order_priority, include_in_personal_filters, include_in_deck_filters, auto_aggregate, inserted_at, updated_at)
    VALUES
      (false, 'All Formats', 7, null, 9000, true, false, false, now(), now()),
      (true, 'Standard', 7, 2, 128, true, true, true, now(), now()),
      (false, 'Wild', 7, 1, 86, true, true, true, now(), now()),
      (false, 'Twist', 7, 4, 32, true, true, true, now(), now()),
      (false, 'Classic', 7, 3, 16, true, true, true, now(), now()),
      (false, 'Brawl', 15, -1, 16, true, true, true, now(), now())
    ;
    """

    execute(sql)
  end
end
