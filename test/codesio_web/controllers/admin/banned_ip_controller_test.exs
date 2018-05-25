defmodule CodesioWeb.Admin.BannedIpControllerTest do
  use CodesioWeb.ConnCase

  alias Codesio.IpControl

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  def fixture(:banned_ip) do
    {:ok, banned_ip} = IpControl.create_banned_ip(@create_attrs)
    banned_ip
  end

  describe "index" do
    test "lists all banned_ips", %{conn: conn} do
      conn = get conn, Routes.admin_banned_ip_path(conn, :index)
      assert html_response(conn, 200) =~ "Banned ips"
    end
  end

  describe "new banned_ip" do
    test "renders form", %{conn: conn} do
      conn = get conn, Routes.admin_banned_ip_path(conn, :new)
      assert html_response(conn, 200) =~ "New Banned ip"
    end
  end

  describe "create banned_ip" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, Routes.admin_banned_ip_path(conn, :create), banned_ip: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.admin_banned_ip_path(conn, :show, id)

      conn = get conn, Routes.admin_banned_ip_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Banned ip Details"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, Routes.admin_banned_ip_path(conn, :create), banned_ip: @invalid_attrs
      assert html_response(conn, 200) =~ "New Banned ip"
    end
  end

  describe "edit banned_ip" do
    setup [:create_banned_ip]

    test "renders form for editing chosen banned_ip", %{conn: conn, banned_ip: banned_ip} do
      conn = get conn, Routes.admin_banned_ip_path(conn, :edit, banned_ip)
      assert html_response(conn, 200) =~ "Edit Banned ip"
    end
  end

  describe "update banned_ip" do
    setup [:create_banned_ip]

    test "redirects when data is valid", %{conn: conn, banned_ip: banned_ip} do
      conn = put conn, Routes.admin_banned_ip_path(conn, :update, banned_ip), banned_ip: @update_attrs
      assert redirected_to(conn) == Routes.admin_banned_ip_path(conn, :show, banned_ip)

      conn = get conn, Routes.admin_banned_ip_path(conn, :show, banned_ip)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, banned_ip: banned_ip} do
      conn = put conn, Routes.admin_banned_ip_path(conn, :update, banned_ip), banned_ip: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Banned ip"
    end
  end

  describe "delete banned_ip" do
    setup [:create_banned_ip]

    test "deletes chosen banned_ip", %{conn: conn, banned_ip: banned_ip} do
      conn = delete conn, Routes.admin_banned_ip_path(conn, :delete, banned_ip)
      assert redirected_to(conn) == Routes.admin_banned_ip_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, Routes.admin_banned_ip_path(conn, :show, banned_ip)
      end
    end
  end

  defp create_banned_ip(_) do
    banned_ip = fixture(:banned_ip)
    {:ok, banned_ip: banned_ip}
  end
end
