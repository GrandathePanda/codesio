defmodule CodesioWeb.SnippetControllerTest do
  use CodesioWeb.ConnCase
  alias Codesio.SnippetsDisplay
  alias Codesio.Accounts.User
  alias Codesio.Repo

  setup %{conn: conn} do
    user = User.changeset(%User{}, %{username: "testuser", name: "test", email: "test@example.com", password: "test", password_confirmation: "test"})
    |> Repo.insert!
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end
  @create_attrs %{ snippet: "test", tags: ["x","y","z"], language: "test" }
  @update_attrs %{ snippet: "new_test", tags: ["x","y","z"], language: "test" }
  @invalid_attrs %{ snippet: nil, tags: nil, language: nil }

  def fixture(:snippet) do
    {:ok, snippet} = SnippetsDisplay.create_snippet(@create_attrs)
    snippet
  end

  describe "index" do
    test "lists all snippets", %{conn: conn} do
      conn = get conn, snippet_path(conn, :index)
      assert html_response(conn, 200) =~ "Snippets"
    end
  end

  describe "new snippet" do
    test "redirects if not logged in", %{conn: conn} do
      conn = assign(conn, :current_user, nil)
      conn = get conn, snippet_path(conn, :new)
      assert html_response(conn, 302) =~ "<html><body>You are being <a href=\"/sessions/new\">redirected</a>.</body></html>"
    end
    test "makes new snippet", %{conn: conn} do
      conn = get conn, snippet_path(conn, :new)
      assert html_response(conn, 200) =~ "New Snippet"
    end
  end

  describe "create snippet" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, snippet_path(conn, :create), snippet: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == snippet_path(conn, :show, id)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, snippet_path(conn, :create), snippet: @invalid_attrs
      assert html_response(conn, 200) =~ "Oops, something went wrong! Please check the errors below."
    end
  end

  describe "edit snippet" do
    setup [:create_snippet]

    test "renders form for editing chosen snippet", %{conn: conn, snippet: snippet} do
      conn = get conn, snippet_path(conn, :edit, snippet)
      assert html_response(conn, 200) =~ "Edit Snippet"
    end
  end

  describe "update snippet" do
    setup [:create_snippet]

    test "redirects when data is valid", %{conn: conn, snippet: snippet} do
      conn = put conn, snippet_path(conn, :update, snippet), snippet: @update_attrs
      assert redirected_to(conn) == snippet_path(conn, :show, snippet)
    end
    test "redirects when tags is a comma string", %{conn: conn, snippet: snippet} do
      conn = put conn, snippet_path(conn, :update, snippet), snippet: %{ @update_attrs | tags: "a,b,c" }
      assert redirected_to(conn) == snippet_path(conn, :show, snippet)
    end
    test "renders errors when data is invalid", %{conn: conn, snippet: snippet} do
      conn = put conn, snippet_path(conn, :update, snippet), snippet: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Snippet"
    end
  end

  describe "delete snippet" do
    setup [:create_snippet]

    test "deletes chosen snippet", %{conn: conn, snippet: snippet, user: user} do
      delete = delete conn, snippet_path(conn, :delete, snippet)
      assert redirected_to(delete) == snippet_path(delete, :index)
      assert_error_sent 404, fn ->
        get conn, snippet_path(conn, :show, snippet)
      end
    end
  end

  defp create_snippet(_) do
    snippet = fixture(:snippet)
    {:ok, snippet: snippet}
  end
end
