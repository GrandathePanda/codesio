defmodule Codesio.IpControlTest do
  use Codesio.DataCase

  alias Codesio.IpControl

  describe "banned_ips" do
    alias Codesio.IpControl.BannedIp

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def banned_ip_fixture(attrs \\ %{}) do
      {:ok, banned_ip} =
        attrs
        |> Enum.into(@valid_attrs)
        |> IpControl.create_banned_ip()

      banned_ip
    end

    test "paginate_banned_ips/1 returns paginated list of banned_ips" do
      for _ <- 1..20 do
        banned_ip_fixture()
      end

      {:ok, %{banned_ips: banned_ips} = page} = IpControl.paginate_banned_ips(%{})

      assert length(banned_ips) == 15
      assert page.page_number == 1
      assert page.page_size == 15
      assert page.total_pages == 2
      assert page.total_entries == 20
      assert page.distance == 5
      assert page.sort_field == "inserted_at"
      assert page.sort_direction == "desc"
    end

    test "list_banned_ips/0 returns all banned_ips" do
      banned_ip = banned_ip_fixture()
      assert IpControl.list_banned_ips() == [banned_ip]
    end

    test "get_banned_ip!/1 returns the banned_ip with given id" do
      banned_ip = banned_ip_fixture()
      assert IpControl.get_banned_ip!(banned_ip.id) == banned_ip
    end

    test "create_banned_ip/1 with valid data creates a banned_ip" do
      assert {:ok, %BannedIp{} = banned_ip} = IpControl.create_banned_ip(@valid_attrs)
    end

    test "create_banned_ip/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = IpControl.create_banned_ip(@invalid_attrs)
    end

    test "update_banned_ip/2 with valid data updates the banned_ip" do
      banned_ip = banned_ip_fixture()
      assert {:ok, banned_ip} = IpControl.update_banned_ip(banned_ip, @update_attrs)
      assert %BannedIp{} = banned_ip
    end

    test "update_banned_ip/2 with invalid data returns error changeset" do
      banned_ip = banned_ip_fixture()
      assert {:error, %Ecto.Changeset{}} = IpControl.update_banned_ip(banned_ip, @invalid_attrs)
      assert banned_ip == IpControl.get_banned_ip!(banned_ip.id)
    end

    test "delete_banned_ip/1 deletes the banned_ip" do
      banned_ip = banned_ip_fixture()
      assert {:ok, %BannedIp{}} = IpControl.delete_banned_ip(banned_ip)
      assert_raise Ecto.NoResultsError, fn -> IpControl.get_banned_ip!(banned_ip.id) end
    end

    test "change_banned_ip/1 returns a banned_ip changeset" do
      banned_ip = banned_ip_fixture()
      assert %Ecto.Changeset{} = IpControl.change_banned_ip(banned_ip)
    end
  end
end
