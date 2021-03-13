defmodule BackendWeb.BattletagController do
  use BackendWeb, :controller

  alias Backend.Battlenet
  alias Backend.Battlenet.Battletag
  require Logger

  plug(:put_root_layout, {BackendWeb.LayoutView, "torch.html"})
  plug(Backend.Plug.AdminAuth, role: :battletag_info)

  action_fallback BackendWeb.FallbackController

  def index(conn, params) do
    case Battlenet.paginate_battletag_info(params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)

      error ->
        conn
        |> put_flash(:error, "There was an error rendering Battletag info. #{inspect(error)}")
        |> redirect(to: Routes.battletag_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = Battlenet.change_battletag(%Battletag{})
    render(conn, "new.html", changeset: changeset)
  end

  def batch(conn, _params) do
    render(conn, "batch.html")
  end

  def batch_insert(conn, %{"batch" => batch}) do
    reported_by = reported_by(conn, batch)
    batch_insert(batch, "battletag_full", reported_by)
    batch_insert(batch, "battletag_short", reported_by)
    redirect(conn, to: Routes.battletag_path(conn, :index))
  end

  def batch_insert(p = %{"country" => country, "priority" => priority}, split_attr, rb) do
    base_attrs = %{"country" => country, "priority" => priority, "reported_by" => rb}

    p[split_attr]
    # |> String.split(~r/\R/) would break chinese characters so I use the below two lines instead
    |> String.replace("\r", "")
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(fn btf ->
      base_attrs
      |> Map.put(split_attr, btf)
      |> Battlenet.create_battletag()
    end)
  end

  def reported_by(_, %{"reported_by" => rb}) when is_binary(rb) and bit_size(rb) > 0, do: rb
  def reported_by(conn, _), do: conn |> BackendWeb.AuthUtils.battletag()

  def create(conn, %{"battletag" => battletag_params}) do
    battletag_params
    |> Map.put("reported_by", conn |> BackendWeb.AuthUtils.battletag())
    |> Battlenet.create_battletag()
    |> case do
      {:ok, battletag} ->
        conn
        |> put_flash(:info, "Battletag created successfully.")
        |> redirect(to: Routes.battletag_path(conn, :show, battletag))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    battletag = Battlenet.get_battletag!(id)
    render(conn, "show.html", battletag: battletag)
  end

  def edit(conn, %{"id" => id}) do
    battletag = Battlenet.get_battletag!(id)
    changeset = Battlenet.change_battletag(battletag)
    render(conn, "edit.html", battletag: battletag, changeset: changeset)
  end

  def update(conn, %{"id" => id, "battletag" => battletag_params}) do
    battletag = Battlenet.get_battletag!(id)

    if can_edit?(battletag, battletag_params, conn) do
      case Battlenet.update_battletag(battletag, battletag_params) do
        {:ok, battletag} ->
          conn
          |> put_flash(:info, "Battletag updated successfully.")
          |> redirect(to: Routes.battletag_path(conn, :show, battletag))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", battletag: battletag, changeset: changeset)
      end
    else
      {:error, :unauthorized}
    end
  end

  defp can_edit?(battletag, battletag_params, conn) do
    user = conn |> Guardian.Plug.current_resource()

    is_super = user |> Backend.UserManager.User.can_access?("super")
    reported_by_matches = battletag.reported_by == user.battletag

    params_reported_by_ok =
      battletag_params["reported_by"] == nil || battletag_params["reported_by"] == user.battletag

    is_super || (reported_by_matches && params_reported_by_ok)
  end

  def delete(conn, %{"id" => id}) do
    battletag = Battlenet.get_battletag!(id)
    {:ok, _battletag} = Battlenet.delete_battletag(battletag)

    conn
    |> put_flash(:info, "Battletag deleted successfully.")
    |> redirect(to: Routes.battletag_path(conn, :index))
  end
end
