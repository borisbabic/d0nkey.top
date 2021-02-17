defmodule BackendWeb.FeedItemController do
  use BackendWeb, :controller

  alias Backend.Feed
  alias Backend.Feed.FeedItem

  plug(:put_root_layout, {BackendWeb.LayoutView, "torch.html"})

  def index(conn, params) do
    case Feed.paginate_feed_items(params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)

      error ->
        conn
        |> put_flash(:error, "There was an error rendering Feed items. #{inspect(error)}")
        |> redirect(to: Routes.feed_item_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = Feed.change_feed_item(%FeedItem{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"feed_item" => feed_item_params}) do
    case Feed.create_feed_item(feed_item_params) do
      {:ok, feed_item} ->
        conn
        |> put_flash(:info, "Feed item created successfully.")
        |> redirect(to: Routes.feed_item_path(conn, :show, feed_item))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    feed_item = Feed.get_feed_item!(id)
    render(conn, "show.html", feed_item: feed_item)
  end

  def edit(conn, %{"id" => id}) do
    feed_item = Feed.get_feed_item!(id)
    changeset = Feed.change_feed_item(feed_item)
    render(conn, "edit.html", feed_item: feed_item, changeset: changeset)
  end

  def update(conn, %{"id" => id, "feed_item" => feed_item_params}) do
    feed_item = Feed.get_feed_item!(id)

    case Feed.update_feed_item(feed_item, feed_item_params) do
      {:ok, feed_item} ->
        conn
        |> put_flash(:info, "Feed item updated successfully.")
        |> redirect(to: Routes.feed_item_path(conn, :show, feed_item))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", feed_item: feed_item, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    feed_item = Feed.get_feed_item!(id)
    {:ok, _feed_item} = Feed.delete_feed_item(feed_item)

    conn
    |> put_flash(:info, "Feed item deleted successfully.")
    |> redirect(to: Routes.feed_item_path(conn, :index))
  end
end
