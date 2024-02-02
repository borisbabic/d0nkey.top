defmodule BackendWeb.RegionController do
  use BackendWeb, :html_controller

  alias Hearthstone.DeckTracker
  alias Hearthstone.DeckTracker.Region

  plug(:put_root_layout, {BackendWeb.LayoutView, "torch.html"})
  plug(:put_layout, false)
  plug(Backend.Plug.AdminAuth, role: :regions)

  def index(conn, params) do
    case DeckTracker.paginate_regions(params) do
      {:ok, assigns} ->
        render(conn, :index, assigns)

      {:error, error} ->
        conn
        |> put_flash(:error, "There was an error rendering Regions. #{inspect(error)}")
        |> redirect(to: ~p"/torch/regions")
    end
  end

  def new(conn, _params) do
    changeset = DeckTracker.change_region(%Region{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"region" => region_params}) do
    case DeckTracker.create_region(region_params) do
      {:ok, region} ->
        conn
        |> put_flash(:info, "Region created successfully.")
        |> redirect(to: ~p"/torch/regions/#{region}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    region = DeckTracker.get_region!(id)
    render(conn, :show, region: region)
  end

  def edit(conn, %{"id" => id}) do
    region = DeckTracker.get_region!(id)
    changeset = DeckTracker.change_region(region)
    render(conn, :edit, region: region, changeset: changeset)
  end

  def update(conn, %{"id" => id, "region" => region_params}) do
    region = DeckTracker.get_region!(id)

    case DeckTracker.update_region(region, region_params) do
      {:ok, region} ->
        conn
        |> put_flash(:info, "Region updated successfully.")
        |> redirect(to: ~p"/torch/regions/#{region}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, region: region, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    region = DeckTracker.get_region!(id)
    {:ok, _region} = DeckTracker.delete_region(region)

    conn
    |> put_flash(:info, "Region deleted successfully.")
    |> redirect(to: ~p"/torch/regions")
  end
end
