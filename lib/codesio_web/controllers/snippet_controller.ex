defmodule CodesioWeb.SnippetController do
  use CodesioWeb, :controller
  alias Codesio.SnippetsDisplay
  alias Codesio.SnippetsDisplay.Snippet
  def index(conn, _params) do
    snippets = SnippetsDisplay.list_snippets()
    render(conn, "index.html", snippets: snippets)
  end

  def new(conn, _params) do
    changeset = SnippetsDisplay.change_snippet(%Snippet{})
    render(conn, "new.html", changeset: changeset, languages: CodesioWeb.get_supported_languages())
  end

  def create(conn, %{"snippet" => %{ "tags" => tags } = snippet_params}) do
    tags = String.split(tags, ",", trim: true)
    IO.inspect(tags)
    case SnippetsDisplay.create_snippet(%{ snippet_params | "tags" => tags }) do
      {:ok, snippet} ->
        conn
        |> put_flash(:info, "Snippet added successfully.")
        |> redirect(to: snippet_path(conn, :show, snippet))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    snippet = SnippetsDisplay.get_snippet!(id)
    render(conn, "show.html", snippet: snippet)
  end

  def edit(conn, %{"id" => id}) do
    snippet = SnippetsDisplay.get_snippet!(id)
    changeset = SnippetsDisplay.change_snippet(snippet)
    render(conn, "edit.html", snippet: snippet, changeset: changeset)
  end

  def update(conn, %{"id" => id, "snippet" => snippet_params}) do
    snippet = SnippetsDisplay.get_snippet!(id)

    case SnippetsDisplay.update_snippet(snippet, snippet_params) do
      {:ok, snippet} ->
        conn
        |> put_flash(:info, "Snippet updated successfully.")
        |> redirect(to: snippet_path(conn, :show, snippet))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", snippet: snippet, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    snippet = SnippetsDisplay.get_snippet!(id)
    {:ok, _snippet} = SnippetsDisplay.delete_snippet(snippet)

    conn
    |> put_flash(:info, "Snippet deleted successfully.")
    |> redirect(to: snippet_path(conn, :index))
  end
end
