defmodule BackendWeb.Plug.StripCloudflareParams do
  @behaviour Plug
  import Plug.Conn

  # You can define a default list of exact matches or prefixes to drop
  @cloudflare_prefixes ["cf_", "__cf_"]

  def init(opts), do: opts

  def call(%Plug.Conn{query_string: ""} = conn, _opts), do: conn

  def call(%Plug.Conn{} = conn, _opts) do
    # Fetch and parse the query parameters safely
    conn = fetch_query_params(conn)

    # Filter out any keys that match Cloudflare patterns
    cleaned_query_params = reject_cf_params(conn.query_params, @cloudflare_prefixes)

    cleaned_params = reject_cf_params(conn.params, @cloudflare_prefixes)

    # Rebuild the query string and update the connection
    new_query_string = URI.encode_query(cleaned_params)

    %{conn | query_string: new_query_string, query_params: cleaned_query_params, params: cleaned_params}
  end

  # Helper to drop keys that start with the forbidden prefixes
  defp reject_cf_params(params, prefixes) do
    Map.reject(params, fn {key, _value} ->
      Enum.any?(prefixes, &String.starts_with?(key, &1))
    end)
  end
end
