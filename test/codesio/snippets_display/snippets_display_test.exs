defmodule Codesio.SnippetsDisplayTest do
  use Codesio.DataCase

  alias Codesio.SnippetsDisplay

  describe "snippets" do
    alias Codesio.SnippetsDisplay.Snippet

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def snippet_fixture(attrs \\ %{}) do
      {:ok, snippet} =
        attrs
        |> Enum.into(@valid_attrs)
        |> SnippetsDisplay.create_snippet()

      snippet
    end

    test "list_snippets/0 returns all snippets" do
      snippet = snippet_fixture()
      assert SnippetsDisplay.list_snippets() == [snippet]
    end

    test "get_snippet!/1 returns the snippet with given id" do
      snippet = snippet_fixture()
      assert SnippetsDisplay.get_snippet!(snippet.id) == snippet
    end

    test "create_snippet/1 with valid data creates a snippet" do
      assert {:ok, %Snippet{} = snippet} = SnippetsDisplay.create_snippet(@valid_attrs)
    end

    test "create_snippet/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SnippetsDisplay.create_snippet(@invalid_attrs)
    end

    test "update_snippet/2 with valid data updates the snippet" do
      snippet = snippet_fixture()
      assert {:ok, snippet} = SnippetsDisplay.update_snippet(snippet, @update_attrs)
      assert %Snippet{} = snippet
    end

    test "update_snippet/2 with invalid data returns error changeset" do
      snippet = snippet_fixture()
      assert {:error, %Ecto.Changeset{}} = SnippetsDisplay.update_snippet(snippet, @invalid_attrs)
      assert snippet == SnippetsDisplay.get_snippet!(snippet.id)
    end

    test "delete_snippet/1 deletes the snippet" do
      snippet = snippet_fixture()
      assert {:ok, %Snippet{}} = SnippetsDisplay.delete_snippet(snippet)
      assert_raise Ecto.NoResultsError, fn -> SnippetsDisplay.get_snippet!(snippet.id) end
    end

    test "change_snippet/1 returns a snippet changeset" do
      snippet = snippet_fixture()
      assert %Ecto.Changeset{} = SnippetsDisplay.change_snippet(snippet)
    end
  end
end
