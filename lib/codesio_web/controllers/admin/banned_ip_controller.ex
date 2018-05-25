defmodule CodesioWeb.Admin.BannedIpController do
  use CodesioWeb, :controller

  alias Codesio.IpControl
  alias Codesio.IpControl.BannedIp
  alias CodesioHelpers.IpBanHelper.ActiveBansAgent

  plug(:put_layout, {CodesioWeb.LayoutView, "torch.html"})

  def index(conn, params) do
    case IpControl.paginate_banned_ips(params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)
      error ->
        conn
        |> put_flash(:error, "There was an error rendering Banned ips. #{inspect(error)}")
        |> redirect(to: admin_banned_ip_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = IpControl.change_banned_ip(%BannedIp{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"banned_ip" => banned_ip_params}) do
    case IpControl.create_banned_ip(banned_ip_params) do
      {:ok, banned_ip} ->
        ActiveBansAgent.add_ip(elem(banned_ip.ip,0))
        conn
        |> put_flash(:info, "Banned ip created successfully.")
        |> redirect(to: admin_banned_ip_path(conn, :show, banned_ip))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    banned_ip = IpControl.get_banned_ip!(id)
    render(conn, "show.html", banned_ip: banned_ip)
  end

  def edit(conn, %{"id" => id}) do
    banned_ip = IpControl.get_banned_ip!(id)
    changeset = IpControl.change_banned_ip(banned_ip)
    render(conn, "edit.html", banned_ip: banned_ip, changeset: changeset)
  end

  def update(conn, %{"id" => id, "banned_ip" => banned_ip_params}) do
    banned_ip = IpControl.get_banned_ip!(id)
    ActiveBansAgent.remove_ip(banned_ip.ip)
    case IpControl.update_banned_ip(banned_ip, banned_ip_params) do
      {:ok, banned_ip} ->
        ActiveBansAgent.add_ip(elem(banned_ip.ip,0))
        conn
        |> put_flash(:info, "Banned ip updated successfully.")
        |> redirect(to: admin_banned_ip_path(conn, :show, banned_ip))
      {:error, %Ecto.Changeset{} = changeset} ->
        ActiveBansAgent.add_ip(elem(banned_ip.ip,0))
        render(conn, "edit.html", banned_ip: banned_ip, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    banned_ip = IpControl.get_banned_ip!(id)
    {:ok, _banned_ip} = IpControl.delete_banned_ip(banned_ip)
    ActiveBansAgent.remove_ip(banned_ip.ip)
    conn
    |> put_flash(:info, "Banned ip deleted successfully.")
    |> redirect(to: admin_banned_ip_path(conn, :index))
  end
end
