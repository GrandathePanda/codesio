defmodule CodesioWeb.UserControllerTest do
  use CodesioWeb.ConnCase
  alias Codesio.Accounts
  alias Codesio.Accounts.User
  alias Codesio.Repo

  setup %{conn: conn} do
    user = User.changeset(%User{}, %{username: "testuser", name: "test", email: "test@example.com", password: "test", password_confirmation: "test"})
    |> Repo.insert!
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end
  @create_attrs %{email: "some@email", name: "some name", username: "some username", password: "1234"}
  @update_attrs %{email: "someupdated@email", name: "some updated name", username: "some updated username", password: '12345'}
  @invalid_attrs %{email: nil, name: nil, username: nil, password: nil}

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
