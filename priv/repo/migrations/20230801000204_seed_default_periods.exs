defmodule Backend.Repo.Migrations.SeedDefaultPeriods do
  use Ecto.Migration

  def change do
    # [inserted_at | _] =
    inserted_at =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.to_iso8601()

    # |> String.replace("T", " ")
    # |> String.split(".")

    sql = """
          INSERT INTO public.dt_periods
          (slug, display, type, period_start, period_end, hours_ago, include_in_personal_filters, include_in_deck_filters, auto_aggregate, inserted_at, updated_at)
          VALUES
          ('past_30_days', 'Past 30 days', 'rolling', null, null, #{24 * 30}, true, true, true, '#{inserted_at}', '#{inserted_at}'),
          ('past_2_weeks', 'Past 2 Weeks', 'rolling', null, null, #{24 * 14}, true, true, true, '#{inserted_at}', '#{inserted_at}'),
          ('past_week', 'Past Week', 'rolling', null, null, #{24 * 7}, true, true, true, '#{inserted_at}', '#{inserted_at}'),
          ('past_3_days', 'Past 3 Days', 'rolling', null, null, #{24 * 3}, true, true, true, '#{inserted_at}', '#{inserted_at}'),
          ('past_day', 'Past 3 Days', 'rolling', null, null, #{24}, true, true, true, '#{inserted_at}', '#{inserted_at}');
    """

    execute(sql)
  end
end
