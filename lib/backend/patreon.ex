defmodule Backend.Patreon do
  @moduledoc """
  The Patreon context.
  """

  import Ecto.Query, warn: false
  alias Backend.Repo

  alias Backend.Patreon.PatreonTier

  use Torch.Pagination,
    repo: Backend.Repo,
    model: Backend.Patreon.PatreonTier,
    name: :patreon_tiers

  @doc """
  Returns the list of patreon_tiers.

  ## Examples

      iex> list_patreon_tiers()
      [%PatreonTier{}, ...]

  """
  def list_patreon_tiers do
    Repo.all(PatreonTier)
  end

  @doc """
  Gets a single patreon_tier.

  Raises `Ecto.NoResultsError` if the Patreon tier does not exist.

  ## Examples

      iex> get_patreon_tier!(123)
      %PatreonTier{}

      iex> get_patreon_tier!(456)
      ** (Ecto.NoResultsError)

  """
  def get_patreon_tier!(id), do: Repo.get!(PatreonTier, id)

  @doc """
  Creates a patreon_tier.

  ## Examples

      iex> create_patreon_tier(%{field: value})
      {:ok, %PatreonTier{}}

      iex> create_patreon_tier(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_patreon_tier(attrs \\ %{}) do
    %PatreonTier{}
    |> PatreonTier.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a patreon_tier.

  ## Examples

      iex> update_patreon_tier(patreon_tier, %{field: new_value})
      {:ok, %PatreonTier{}}

      iex> update_patreon_tier(patreon_tier, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_patreon_tier(%PatreonTier{} = patreon_tier, attrs) do
    patreon_tier
    |> PatreonTier.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a PatreonTier.

  ## Examples

      iex> delete_patreon_tier(patreon_tier)
      {:ok, %PatreonTier{}}

      iex> delete_patreon_tier(patreon_tier)
      {:error, %Ecto.Changeset{}}

  """
  def delete_patreon_tier(%PatreonTier{} = patreon_tier) do
    Repo.delete(patreon_tier)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking patreon_tier changes.

  ## Examples

      iex> change_patreon_tier(patreon_tier)
      %Ecto.Changeset{source: %PatreonTier{}}

  """
  def change_patreon_tier(%PatreonTier{} = patreon_tier, attrs \\ %{}) do
    PatreonTier.changeset(patreon_tier, attrs)
  end

  def add_new_tiers() do
    {:ok, response} = Patreon.Api.get_campaign(campaign_id())
    campaign = Patreon.Api.data_with_included(response.body)
    current_tier_ids = list_patreon_tiers() |> MapSet.new(& &1.id)
    new = Enum.reject(campaign.tiers, &MapSet.member?(current_tier_ids, &1.id))

    for %{id: id, title: title} <- new do
      create_patreon_tier(%{id: id, title: title})
    end
  end

  def campaign_id(), do: Application.fetch_env!(:backend, :patreon_campaign_id)

  @spec campaign_user_tiers() :: [%{user_id: String.t(), tier_id: String.t()}]
  def campaign_user_tiers() do
    {:ok, campaign_members} = Patreon.Api.get_all_campaign_members(campaign_id())

    for %{currently_entitled_tiers: [%{id: tier_id} | _], user: %{id: user_id}} <-
          campaign_members do
      %{user_id: user_id, tier_id: tier_id}
    end
  end
end
