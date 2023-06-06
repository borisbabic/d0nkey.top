defmodule Bot.ThlMessageHandler do
  @moduledoc false
  import Bot.MessageHandlerUtil
  import Nostrum.Struct.Embed
  alias Nostrum.Struct.Embed
  alias Nostrum.Struct.Message
  alias Nostrum.Api

  @type checkable :: {String.t(), String.t()}
  @type check_result :: {:ok, checkable, String.t()} | {:error, checkable, any()}
  @spec handle_thl(Message.t()) :: any()
  def handle_thl(msg) do
    with {:ok, _} <- validate_author(msg) do
      embed =
        msg
        |> extract_checkables()
        |> Enum.map(&check_in_discord/1)
        |> create_embed()

      Api.create_message(msg.channel_id, embed: embed)
    end
  end

  def create_embed(results) do
    Enum.reduce(results, %Embed{}, fn
      {:ok, {title, tag}, id}, embed ->
        put_field(embed, title, embed_field(tag, id))

      {:error, {title, tag}, _reason}, embed ->
        put_field(
          embed,
          "ERROR: #{title}",
          "#{tag} isn't in the discord or there is something wrong with the tag"
        )
    end)
  end

  def embed_field(tag, id) do
    "<@#{id}> [#{tag}](https://www.discordapp.com/users/#{id})"
  end

  @spec check_in_discord(checkable) :: check_result
  def check_in_discord(checkable = {_, discord_tag}) do
    case get_thl_user_id(discord_tag) do
      {:ok, id} -> {:ok, checkable, id}
      _ -> {:error, checkable, :not_in_discord_or_bad_tag}
    end
  end

  @spec extract_checkables(Message.t()) :: [checkable]
  def extract_checkables(msg) do
    msg.content
    |> get_options(:list)
    |> Enum.map(&create_checkable/1)
  end

  @spec create_checkable(String.t()) :: checkable
  defp create_checkable(checkable) do
    case String.split(checkable, ":") do
      [title, discord_tag] -> {title, discord_tag}
      [discord_tag] -> {discord_tag, discord_tag}
    end
  end

  @spec handle_thl(Message.t()) :: {:ok, any()} | {:error, any()}
  def validate_author(%{author: %{username: u, discriminator: d}}) do
    get_thl_user_id(u, d)
  end

  @spec get_thl_user_id(String.t()) :: {:ok, String.t()} | {:error, any()}
  def get_thl_user_id(discord_tag) do
    with {:ok, {username, discriminator}} <- split_discord_tag(discord_tag) do
      get_thl_user_id(username, discriminator)
    end
  end

  @spec get_thl_user_id(String.t(), number | String.t()) :: {:ok, String.t()} | {:error, any()}
  def get_thl_user_id(username, discriminator) do
    with {:ok, url} <- search_url(),
         {:ok, response} <- Api.request(:get, url, "", query: username),
         {:ok, decoded} <- Poison.decode(response) do
      case Enum.find_value(decoded, &extract_matching_id(&1, username, discriminator)) do
        nil -> {:error, :could_not_find_user}
        id -> {:ok, id}
      end
    end
  end

  defp extract_matching_id(
         %{"user" => %{"username" => u, "discriminator" => d, "id" => id}},
         username,
         discriminator
       )
       when d == discriminator do
    if String.upcase(u) == String.upcase(username) do
      id
    end
  end

  defp extract_matching_id(_, _, _), do: nil

  @spec search_url() :: {:ok, String.t()} | {:error, any()}
  def search_url() do
    with {:ok, discord_id} <- get_discord_id() do
      {:ok, "/guilds/#{discord_id}/members/search"}
    end
  end

  def get_discord_id() do
    Application.fetch_env(:backend, :thl_discord_id)
  end
end
