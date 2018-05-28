defmodule CodesioWeb.SnippetController do
  use CodesioWeb, :controller
  alias Codesio.SnippetsDisplay
  alias Codesio.SnippetsDisplay.Snippet
  alias Codesio.Accounts.User
  alias CodesioHelpers.ElasticsearchHelper
  @paginate_params %{ "page_size" => 1 }
  def index(conn, _params) do
    user_id = case conn.assigns[:current_user] do
      nil -> nil
      %User{} -> conn.assigns[:current_user].id
    end
    {status, res} = SnippetsDisplay.paginate_snippets(@paginate_params, conn.assigns)
    assigns = res
              |> Map.put(:user_id, user_id)
              |> Map.put(:languages, CodesioWeb.get_supported_languages())
              |> Map.put(:layout, {CodesioWeb.LayoutView, "snippet_index.html"})
    case status do
      :ok -> render(conn, "index.html", assigns)
      :error -> conn |> put_flash(:error, "Unable to load snippets.") |> redirect(to: snippet_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = SnippetsDisplay.change_snippet(%Snippet{})
    render(conn, "new.html", changeset: changeset, languages: CodesioWeb.get_supported_languages())
  end

  def create(conn, %{"snippet" => %{ "tags" => tags } = snippet_params}) do
    tags = cond do
      is_list(tags) -> tags
      is_binary(tags) -> String.split(tags, ",", trim: true)
      true -> nil
    end
    case SnippetsDisplay.create_snippet(%{ snippet_params | "tags" => tags }) do
      {:ok, snippet} ->
        params = %{ snippet_params | "tags" => tags }
        params = Map.put(params, "id", snippet.id)
        ElasticsearchHelper.insert_into(params)
        conn
        |> put_flash(:info, "Snippet added successfully.")
        |> redirect(to: snippet_path(conn, :show, snippet))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, languages: CodesioWeb.get_supported_languages())
    end
  end

  def show(conn, %{"id" => id}) do
    snippet = SnippetsDisplay.get_snippet!(id)
    render(conn, "show.html", snippet: snippet)
  end

  def edit(conn, %{"id" => id}) do
    snippet = SnippetsDisplay.get_snippet!(id)
    if CodesioHelpers.AuthorizationServices.Policies.authorized?(conn, {:is_snippet_owner, snippet.user_id}) do
      conn
      |> put_flash(:error, "Can only edit snippets you created.")
      |> redirect(to: snippet_path(conn, :index))
    else
      changeset = SnippetsDisplay.change_snippet(snippet)
      render(conn, "edit.html", snippet: snippet, changeset: changeset, languages: CodesioWeb.get_supported_languages())
    end
  end
  defp persist_changes(snippet, snippet_params, conn) do
    case SnippetsDisplay.update_snippet(snippet, snippet_params) do
      {:ok, snippet} ->
        conn
        |> put_flash(:info, "Snippet updated successfully.")
        |> redirect(to: snippet_path(conn, :show, snippet))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", snippet: snippet, changeset: changeset, languages: CodesioWeb.get_supported_languages())
    end
  end
  def update(conn, %{"id" => id, "snippet" => %{ "tags" => tags } = snippet_params}) when is_list(tags) do
    snippet = SnippetsDisplay.get_snippet!(id)
    persist_changes(snippet, snippet_params, conn)
  end
  def update(conn, %{"id" => id, "snippet" => %{ "tags" => tags } = snippet_params}) when is_binary(tags) do
    snippet = SnippetsDisplay.get_snippet!(id)
    tags = String.split(tags, ",", trim: true)
    persist_changes(snippet, %{snippet_params | "tags" => tags}, conn)
  end

  def delete(conn, %{"id" => id}) do
    snippet = SnippetsDisplay.get_snippet!(id)
    if CodesioHelpers.AuthorizationServices.Policies.authorized?(conn, {:is_snippet_owner, snippet.user_id}) do
      conn
      |> put_flash(:error, "Can only delete snippets you have created.")
      |> redirect(to: snippet_path(conn, :index))
    else
      {:ok, _snippet} = SnippetsDisplay.delete_snippet(snippet)

      conn
      |> put_flash(:info, "Snippet deleted successfully.")
      |> redirect(to: snippet_path(conn, :index))
    end
  end
end
