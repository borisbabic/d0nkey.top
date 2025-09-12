defmodule Backend.Repo.Migrations.SeedRanks do
  use Ecto.Migration

  def change do
    sql = """
    INSERT INTO public.ranks
    (slug, display, min_rank, max_rank, min_legend_rank, max_legend_rank, include_in_personal_filters, include_in_deck_filters, auto_aggregate, order_priority, "default", inserted_at, updated_at)
    VALUES
    ('all', 'All', 0, null, 0, null, True, False, False, 9001, True, now(), now()),
    ('top_legend', 'Top 1k', 51, null, 1, 1000, True, True, True, 58, True, now(), now()),
    ('top_5k', 'Top 5k', 51, null, 1, 5000, True, True, True, 54, True, now(), now()),
    ('legend', 'Legend', 51, null, 0, null, True, True, True, 42, True, now(), now()),
    ('diamond_4to1', 'Diamond 4-1', 47, 50, 0, null, True, True, True, 38, True, now(), now()),
    ('diamond_to_legend', 'Diamond-Legend', 47, null, 0, null, True, True, True, 26, True, now(), now()),
    ('all', 'All', 0, null, 0, null, True, False, False, 0, True, now(), now())
    ;
    """

    execute(sql)
  end
end
