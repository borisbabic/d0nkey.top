defmodule Backend.Bluesky do
  @moduledoc """
  Utilities for Bluesky / AT Protocol URL parsing, handle resolution, and embed helpers.
  """
  use GenServer

  @name :bluesky_did_cache

  def start_link(default \\ []) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    table = ensure_cache_table()
    {:ok, %{table: table}}
  end

  @doc """
  Ensures the ETS cache table exists.
  """
  def ensure_cache_table do
    if :ets.whereis(@name) == :undefined do
      try do
        :ets.new(@name, [:set, :public, :named_table, read_concurrency: true])
      rescue
        ArgumentError -> @name
      end
    else
      @name
    end
  end

  @doc """
  Resolves a Bluesky handle or custom domain (e.g. "hearthstone.blizzard.com") to its DID (e.g. "did:plc:...").
  If the input is already a DID, it is returned as is.
  """
  def resolve_handle("did:" <> _ = did), do: {:ok, did}

  def resolve_handle(handle) when is_binary(handle) do
    case safe_cache_lookup(handle) do
      {:ok, did} -> {:ok, did}
      :miss -> fetch_and_cache_did(handle)
    end
  end

  def resolve_handle(_), do: {:error, :invalid_handle}

  defp safe_cache_lookup(handle) do
    case Util.ets_lookup(@name, handle, nil) do
      did when is_binary(did) -> {:ok, did}
      _ -> :miss
    end
  rescue
    _ -> :miss
  end

  defp fetch_and_cache_did(handle) do
    case fetch_did_from_api(handle) do
      {:ok, did} = ok ->
        safe_cache_insert(handle, did)
        ok

      error ->
        error
    end
  end

  defp safe_cache_insert(handle, did) do
    ensure_cache_table()
    :ets.insert(@name, {handle, did})
  rescue
    _ -> :ok
  end

  @doc """
  Converts a Bluesky post URL or AT-URI to a displayable web link on bsky.app.
  """
  def to_web_link(link) when is_binary(link) do
    if String.starts_with?(link, "at://") do
      case Regex.run(~r/^at:\/\/([^\/]+)\/app\.bsky\.feed\.post\/([^\/?#]+)/, link) do
        [_, repo, rkey] -> "https://bsky.app/profile/#{repo}/post/#{rkey}"
        _ -> link
      end
    else
      link
    end
  end

  def to_web_link(link), do: link

  @doc """
  Converts a Bluesky post URL or AT-URI to an AT-URI with a resolved DID.
  Bluesky's embed widget (embed.bsky.app) strictly requires a DID in the AT-URI,
  so handles and custom domains are automatically resolved to DIDs.
  """
  def to_aturi(link) when is_binary(link) do
    cond do
      String.starts_with?(link, "http://") or String.starts_with?(link, "https://") ->
        case Regex.run(~r/\/profile\/([^\/]+)\/post\/([^\/?#]+)/, link) do
          [_, repo, rkey] ->
            did = resolve_repo_to_did(repo)
            "at://#{did}/app.bsky.feed.post/#{rkey}"

          _ ->
            link
        end

      String.starts_with?(link, "at://") ->
        case Regex.run(~r/^at:\/\/([^\/]+)\/app\.bsky\.feed\.post\/([^\/?#]+)/, link) do
          [_, repo, rkey] ->
            did = resolve_repo_to_did(repo)
            "at://#{did}/app.bsky.feed.post/#{rkey}"

          _ ->
            link
        end

      true ->
        link
    end
  end

  def to_aturi(link), do: link

  defp resolve_repo_to_did(repo) do
    if String.starts_with?(repo, "did:") do
      repo
    else
      case resolve_handle(repo) do
        {:ok, did} -> did
        _ -> repo
      end
    end
  end

  defp fetch_did_from_api(handle) do
    encoded = URI.encode_www_form(handle)
    url = "https://public.api.bsky.app/xrpc/com.atproto.identity.resolveHandle?handle=#{encoded}"

    case Req.get(url, receive_timeout: 3_000) do
      {:ok, %{status: 200, body: %{"did" => did}}} when is_binary(did) ->
        {:ok, did}

      _ ->
        {:error, :resolve_failed}
    end
  rescue
    _ -> {:error, :request_failed}
  end
end
