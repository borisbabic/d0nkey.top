defmodule BackendWeb.RankController do
  use BackendWeb, :html_controller

  alias Hearthstone.DeckTracker.Rank
  alias Hearthstone.DeckTracker

  plug(:put_root_layout, {BackendWeb.LayoutView, "torch.html"})
  plug(:put_layout, false)
  plug(Backend.Plug.AdminAuth, role: :ranks)

  def index(conn, params) do
    case DeckTracker.paginate_ranks(params) do
      {:ok, assigns} ->
        render(conn, :index, assigns)

      {:error, error} ->
        conn
        |> put_flash(:error, "There was an error rendering Ranks. #{inspect(error)}")
        |> redirect(to: ~p"/torch/ranks")
    end
  end

  def new(conn, _params) do
    changeset = DeckTracker.change_rank(%Rank{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"rank" => rank_params}) do
    case DeckTracker.create_rank(rank_params) do
      {:ok, rank} ->
        conn
        |> put_flash(:info, "Rank created successfully.")
        |> redirect(to: ~p"/torch/ranks/#{rank}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    rank = DeckTracker.get_rank!(id)
    render(conn, :show, rank: rank)
  end

  def edit(conn, %{"id" => id}) do
    rank = DeckTracker.get_rank!(id)
    changeset = DeckTracker.change_rank(rank)
    render(conn, :edit, rank: rank, changeset: changeset)
  end

  def update(conn, %{"id" => id, "rank" => rank_params}) do
    rank = DeckTracker.get_rank!(id)

    case DeckTracker.update_rank(rank, rank_params) do
      {:ok, rank} ->
        conn
        |> put_flash(:info, "Rank updated successfully.")
        |> redirect(to: ~p"/torch/ranks/#{rank}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, rank: rank, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    rank = DeckTracker.get_rank!(id)
    {:ok, _rank} = DeckTracker.delete_rank(rank)

    conn
    |> put_flash(:info, "Rank deleted successfully.")
    |> redirect(to: ~p"/torch/ranks")
  end
end
