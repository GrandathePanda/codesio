defmodule CodesioWeb.Admin.SnippetControllerTest do
  use CodesioWeb.ConnCase

  alias Codesio.SnippetsDisplay

  @create_attrs %{language: "some language", rating: 120.5, snippet: "some snippet", tags: []}
  @update_attrs %{language: "some updated language", rating: 456.7, snippet: "some updated snippet", tags: []}
  @invalid_attrs %{language: nil, rating: nil, snippet: nil, tags: nil}

  def fixture(:snippet) do
    {:ok, snippet} = SnippetsDisplay.create_snippet(@create_attrs)
    snippet
  end

  describe "index" do
    test "lists all snippets", %{conn: conn} do
      conn = get conn, Routes.admin_snippet_path(conn, :index)
      assert html_response(conn, 200) =~ "Snippets"
    end
  end

  describe "new snippet" do
    test "renders form", %{conn: conn} do
      conn = get conn, Routes.admin_snippet_path(conn, :new)
      assert html_response(conn, 200) =~ "New Snippet"
    end
  end

  describe "create snippet" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, Routes.admin_snippet_path(conn, :create), snippet: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.admin_snippet_path(conn, :show, id)

      conn = get conn, Routes.admin_snippet_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Snippet Details"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, Routes.admin_snippet_path(conn, :create), snippet: @invalid_attrs
      assert html_response(conn, 200) =~ "New Snippet"
    end
  end

  describe "edit snippet" do
    setup [:create_snippet]

    test "renders form for editing chosen snippet", %{conn: conn, snippet: snippet} do
      conn = get conn, Routes.admin_snippet_path(conn, :edit, snippet)
      assert html_response(conn, 200) =~ "Edit Snippet"
    end
  end

  describe "update snippet" do
    setup [:create_snippet]

    test "redirects when data is valid", %{conn: conn, snippet: snippet} do
      conn = put conn, Routes.admin_snippet_path(conn, :update, snippet), snippet: @update_attrs
      assert redirected_to(conn) == Routes.admin_snippet_path(conn, :show, snippet)

      conn = get conn, Routes.admin_snippet_path(conn, :show, snippet)
      assert html_response(conn, 200) =~ "some updated language"
    end

    test "renders errors when data is invalid", %{conn: conn, snippet: snippet} do
      conn = put conn, Routes.admin_snippet_path(conn, :update, snippet), snippet: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Snippet"
    end
  end

  describe "delete snippet" do
    setup [:create_snippet]

    test "deletes chosen snippet", %{conn: conn, snippet: snippet} do
      conn = delete conn, Routes.admin_snippet_path(conn, :delete, snippet)
      assert redirected_to(conn) == Routes.admin_snippet_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, Routes.admin_snippet_path(conn, :show, snippet)
      end
    end
  end

  defp create_snippet(_) do
    snippet = fixture(:snippet)
    {:ok, snippet: snippet}
  end
end
