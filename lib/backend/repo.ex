defmodule Backend.Repo do
  use Ecto.Repo,
    otp_app: :backend,
    adapter: Ecto.Adapters.Postgres

  @spec table_comment(table_name :: String.t()) :: {:ok, String.t()} | {:error, reason :: atom()}
  def table_comment(table_name) do
    sql = """
    SELECT description
    FROM pg_description
    WHERE objoid = (
      SELECT oid
      FROM pg_class
      WHERE relname = '#{table_name}'
    )
    AND objsubid = 0;
    """

    case query(sql) do
      {:ok, %{rows: [[comment]]}} ->
        {:ok, comment}

      _ ->
        {:error, :not_found}
    end
  end
end
