defmodule BackendWeb.PatreonTierController do
  use BackendWeb, :html_controller

  alias Backend.Patreon
  alias Backend.Patreon.PatreonTier

  plug(:put_root_layout, {BackendWeb.LayoutView, "torch.html"})
  plug(:put_layout, false)
  plug(Backend.Plug.AdminAuth, role: :patreon)

  def index(conn, params) do
    case Patreon.paginate_patreon_tiers(params) do
      {:ok, assigns} ->
        render(conn, :index, assigns)

      {:error, error} ->
        conn
        |> put_flash(:error, "There was an error rendering Patreon tiers. #{inspect(error)}")
        |> redirect(to: ~p"/torch/patreon-tiers")
    end
  end

  def new(conn, _params) do
    changeset = Patreon.change_patreon_tier(%PatreonTier{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"patreon_tier" => patreon_tier_params}) do
    case Patreon.create_patreon_tier(patreon_tier_params) do
      {:ok, patreon_tier} ->
        conn
        |> put_flash(:info, "Patreon tier created successfully.")
        |> redirect(to: ~p"/torch/patreon-tiers/#{patreon_tier}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    patreon_tier = Patreon.get_patreon_tier!(id)
    render(conn, :show, patreon_tier: patreon_tier)
  end

  def edit(conn, %{"id" => id}) do
    patreon_tier = Patreon.get_patreon_tier!(id)
    changeset = Patreon.change_patreon_tier(patreon_tier)
    render(conn, :edit, patreon_tier: patreon_tier, changeset: changeset)
  end

  def update(conn, %{"id" => id, "patreon_tier" => patreon_tier_params}) do
    patreon_tier = Patreon.get_patreon_tier!(id)

    case Patreon.update_patreon_tier(patreon_tier, patreon_tier_params) do
      {:ok, patreon_tier} ->
        conn
        |> put_flash(:info, "Patreon tier updated successfully.")
        |> redirect(to: ~p"/torch/patreon-tiers/#{patreon_tier}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, patreon_tier: patreon_tier, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    patreon_tier = Patreon.get_patreon_tier!(id)
    {:ok, _patreon_tier} = Patreon.delete_patreon_tier(patreon_tier)

    conn
    |> put_flash(:info, "Patreon tier deleted successfully.")
    |> redirect(to: ~p"/torch/patreon-tiers")
  end
end
