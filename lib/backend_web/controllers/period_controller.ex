defmodule BackendWeb.PeriodController do
  use BackendWeb, :html_controller

  alias Hearthstone.DeckTracker
  alias Hearthstone.DeckTracker.Period

  plug(:put_root_layout, {BackendWeb.LayoutView, "torch.html"})
  plug(:put_layout, false)
  plug(Backend.Plug.AdminAuth, role: :periods)

  def index(conn, params) do
    case DeckTracker.paginate_periods(params) do
      {:ok, assigns} ->
        render(conn, :index, assigns)

      {:error, error} ->
        conn
        |> put_flash(:error, "There was an error rendering Periods. #{inspect(error)}")
        |> redirect(to: ~p"/torch/periods")
    end
  end

  def new(conn, _params) do
    changeset = DeckTracker.change_period(%Period{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"period" => period_params}) do
    case DeckTracker.create_period(period_params) do
      {:ok, period} ->
        conn
        |> put_flash(:info, "Period created successfully.")
        |> redirect(to: ~p"/torch/periods/#{period}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    period = DeckTracker.get_period!(id)
    render(conn, :show, period: period)
  end

  def edit(conn, %{"id" => id}) do
    period = DeckTracker.get_period!(id)
    changeset = DeckTracker.change_period(period)
    render(conn, :edit, period: period, changeset: changeset)
  end

  def update(conn, %{"id" => id, "period" => period_params}) do
    period = DeckTracker.get_period!(id)

    case DeckTracker.update_period(period, period_params) do
      {:ok, period} ->
        conn
        |> put_flash(:info, "Period updated successfully.")
        |> redirect(to: ~p"/torch/periods/#{period}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, period: period, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    period = DeckTracker.get_period!(id)
    {:ok, _period} = DeckTracker.delete_period(period)

    conn
    |> put_flash(:info, "Period deleted successfully.")
    |> redirect(to: ~p"/torch/periods")
  end
end
