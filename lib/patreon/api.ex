defmodule Patreon.Api do
  @moduledoc "Module for communicating with the "
  use Tesla
  require Logger
  plug Tesla.Middleware.BaseUrl, "https://www.patreon.com"

  plug Tesla.Middleware.Headers, [
    {"authorization", "Bearer #{Application.fetch_env!(:backend, :patreon_access_token)}"}
  ]

  plug Tesla.Middleware.JSON,
    engine_opts: [keys: :atoms],
    decode_content_types: ["application/json", "application/vnd.api+json"]

  def get_campaigns() do
    get("/api/oauth2/v2/campaigns")
  end

  @default_campaign_include ["tiers", "benefits"]
  @default_campaign_fields [tier: ["title"], campaign: ["url", "vanity"]]
  def get_campaign(
        campaign_id,
        include \\ @default_campaign_include,
        fields \\ @default_campaign_fields
      ) do
    query_part = to_query_part(include, fields)
    url = "/api/oauth2/v2/campaigns/#{campaign_id}?#{query_part}"
    Logger.debug("Fetching patreon campaign #{url}")
    get(url)
  end

  @default_member_include ["currently_entitled_tiers", "user"]
  @default_member_fields [tier: ["title"], member: ["is_follower", "patron_status"]]
  def get_all_campaign_members(
        campaign_id,
        include \\ @default_member_include,
        fields \\ @default_member_fields
      ) do
    do_get_all_campaign_members(campaign_id, include, fields, nil, [])
  end

  def do_get_all_campaign_members(campaign_id, include, fields, cursor, previous_data) do
    case get_campaign_members(campaign_id, include, fields, cursor) do
      {:ok, %{body: %{meta: %{pagination: %{cursors: %{next: next}}}} = body}}
      when not is_nil(next) ->
        data = data_with_included(body)
        do_get_all_campaign_members(campaign_id, include, fields, next, previous_data ++ data)

      {:ok, %{body: body}} ->
        data = data_with_included(body)
        {:ok, previous_data ++ data}

      {:error, _} = error ->
        error
    end
  end

  def get_campaign_members(
        campaign_id,
        include \\ @default_member_include,
        fields \\ @default_member_fields,
        cursor \\ nil
      ) do
    query_part = to_query_part(include, fields, cursor)
    url = "/api/oauth2/v2/campaigns/#{campaign_id}/members?#{query_part}&page%5Bcount%5D=1000"
    Logger.debug("Fetching patreon campaign members #{url}")
    get(url)
  end

  def get_member(member_id, include \\ @default_member_include, fields \\ @default_member_fields) do
    query_part = to_query_part(include, fields)
    url = "/api/oauth2/v2/members/#{member_id}?#{query_part}"
    Logger.debug("Fetching patreon member #{url}")
    get(url)
  end

  defp to_query_part(include, fields, cursor \\ nil) do
    include_part = "include=#{Enum.join(include, ",")}"

    fields_part =
      Enum.map_join(fields, "&", fn {field_key, field_values} ->
        "fields%5B#{field_key}%5D=#{Enum.join(field_values, ",")}"
      end)

    case cursor do
      nil -> "#{include_part}&#{fields_part}"
      not_nil -> "#{include_part}&#{fields_part}&page%5Bcursor%5D=#{not_nil}"
    end
  end

  def data_with_included(%{data: data} = response) do
    data_with_included(data, Map.get(response, :included, []))
  end

  def data_with_included(%{relationships: relationships} = data, included) do
    Enum.reduce(relationships, data, fn
      {base_key, %{data: %{id: id, type: type}}}, acc ->
        value =
          case included_attributes(id, type, included) do
            {:ok, attributes} -> attributes
            _ -> %{id: id, type: type}
          end

        Map.put_new(acc, base_key, value)

      {base_key, %{data: data}}, acc when is_list(data) ->
        values = for d <- data, {:ok, attr} <- [included_attributes(d, included)], do: attr
        Map.put_new(acc, base_key, values)

      _, acc ->
        acc
    end)
  end

  def data_with_included(data, included) when is_list(data),
    do: Enum.map(data, &data_with_included(&1, included))

  def data_with_included(%{id: _id} = data, _included), do: data

  def included_attributes(%{id: id, type: type}, included),
    do: included_attributes(id, type, included)

  def included_attributes(id, type, included) do
    case Enum.find_value(included, false, fn %{type: t, id: i, attributes: attributes} ->
           i == id and t == type && Map.merge(%{id: id, type: type}, attributes)
         end) do
      false -> :error
      attributes -> {:ok, attributes}
    end
  end
end
