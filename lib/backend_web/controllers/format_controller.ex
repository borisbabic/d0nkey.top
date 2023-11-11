defmodule BackendWeb.FormatController do
  use BackendWeb, :html_controller

  alias Hearthstone.DeckTracker
  alias Hearthstone.DeckTracker.Format
  plug(Backend.Plug.AdminAuth, role: :formats)

  plug(:put_root_layout, {BackendWeb.LayoutView, "torch.html"})
  plug(:put_layout, false)

  def index(conn, params) do
    case DeckTracker.paginate_formats(params) do
      {:ok, assigns} ->
        render(conn, :index, assigns)

      {:error, error} ->
        conn
        |> put_flash(:error, "There was an error rendering Formats. #{inspect(error)}")
        |> redirect(to: ~p"/torch/formats")
    end
  end

  def new(conn, _params) do
    changeset = DeckTracker.change_format(%Format{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"format" => format_params}) do
    case DeckTracker.create_format(format_params) do
      {:ok, format} ->
        conn
        |> put_flash(:info, "Format created successfully.")
        |> redirect(to: ~p"/torch/formats/#{format}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    format = DeckTracker.get_format!(id)
    render(conn, :show, format: format)
  end

  def edit(conn, %{"id" => id}) do
    format = DeckTracker.get_format!(id)
    changeset = DeckTracker.change_format(format)
    render(conn, :edit, format: format, changeset: changeset)
  end

  def update(conn, %{"id" => id, "format" => format_params}) do
    format = DeckTracker.get_format!(id)

    case DeckTracker.update_format(format, format_params) do
      {:ok, format} ->
        conn
        |> put_flash(:info, "Format updated successfully.")
        |> redirect(to: ~p"/torch/formats/#{format}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, format: format, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    format = DeckTracker.get_format!(id)
    {:ok, _format} = DeckTracker.delete_format(format)

    conn
    |> put_flash(:info, "Format deleted successfully.")
    |> redirect(to: ~p"/torch/formats")
  end
end
