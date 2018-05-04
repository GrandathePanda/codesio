defmodule CodesioWeb.UserControllerTest do
  use CodesioWeb.ConnCase

  alias Codesio.Accounts

  @create_attrs %{email: "some email", name: "some name", username: "some username"}
  @update_attrs %{email: "some updated email", name: "some updated name", username: "some updated username"}
  @invalid_attrs %{email: nil, name: nil, username: nil}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get conn, user_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Users"
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
