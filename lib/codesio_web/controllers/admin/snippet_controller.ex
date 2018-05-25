defmodule CodesioWeb.Admin.SnippetController do
  use CodesioWeb, :controller

  alias Codesio.SnippetsDisplay
  alias Codesio.SnippetsDisplay.Snippet

  plug(:put_layout, {CodesioWeb.LayoutView, "torch.html"})

  def index(conn, params) do
    case SnippetsDisplay.paginate_snippets(params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)
      error ->
        conn
        |> put_flash(:error, "There was an error rendering Snippets. #{inspect(error)}")
        |> redirect(to: admin_snippet_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = SnippetsDisplay.change_snippet(%Snippet{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"snippet" => snippet_params}) do
    case SnippetsDisplay.create_snippet(snippet_params) do
      {:ok, snippet} ->
        conn
        |> put_flash(:info, "Snippet created successfully.")
        |> redirect(to: admin_snippet_path(conn, :show, snippet))
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
        |> redirect(to: admin_snippet_path(conn, :show, snippet))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", snippet: snippet, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    snippet = SnippetsDisplay.get_snippet!(id)
    {:ok, _snippet} = SnippetsDisplay.delete_snippet(snippet)

    conn
    |> put_flash(:info, "Snippet deleted successfully.")
    |> redirect(to: admin_snippet_path(conn, :index))
  end
end
