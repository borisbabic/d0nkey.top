defmodule Twitch.Stream do
  @moduledoc false
  use TypedStruct

  typedstruct enforce: true do
    field :game_id, String.t()
    field :id, String.t()
    field :language, String.t()
    field :started_at, NaiveDateTime.t()
    field :tag_ids, [String.t()]
    field :thumbnail_url, String.t()
    field :title, String.t()
    field :type, String.t()
    field :user_id, String.t()
    field :user_name, String.t()
    field :viewer_count, number
  end

  def live?(%{live: "live"}), do: true
  def live?(_), do: false

  def thumbnail_url(%{thumbnail_url: thumbnail_url}, width, height),
    do: thumbnail_url(thumbnail_url, width, height)

  def thumbnail_url(<<thumbnail_url::binary>>, width, height) do
    thumbnail_url
    |> String.replace("{width}", to_string(width))
    |> String.replace("{height}", to_string(height))
  end

  def from_raw_map(map = %{"started_at" => started_at_raw}) do
    started_at = NaiveDateTime.from_iso8601!(started_at_raw)

    %{
      game_id: map["game_id"],
      id: map["id"],
      language: map["language"],
      started_at: started_at,
      tag_ids: map["tag_ids"],
      thumbnail_url: map["thumbnail_url"],
      title: map["title"],
      type: map["type"],
      user_id: map["user_id"],
      user_name: map["user_name"],
      viewer_count: map["viewer_count"]
    }
  end

  def login(%{thumbnail_url: thumbnail_url}) do
    ~r/live_user_(?<login>.+)-/
    |> Regex.named_captures(thumbnail_url)
    |> Map.get("login")
  end
end
