defmodule Codesio.SnippetsDisplay do
  @moduledoc """
  The SnippetsDisplay context.
  """

  import Ecto.Query, warn: false
  alias Codesio.Repo

  alias Codesio.SnippetsDisplay.Snippet
  alias Codesio.Vote
  import Filtrex.Type.Config

  def sort(params)

  def sort(%{"sort_field" => field, "sort_direction" => direction}) do
    {String.to_atom(direction), String.to_atom(field)}
  end

  def sort(_other) do
    {:asc, :id}
  end

  def paginate_snippets(params, assigns) do
    user_id = cond do
      assigns[:current_user] != nil -> assigns[:current_user].id
      assigns[:user_id] != nil -> assigns[:user_id]
      true -> nil
    end
    case user_id do
      nil -> paginate_snippets(params)
      _ -> paginate_snippets(Map.put(params, "user_id", user_id))
    end
  end
  @doc """
  Paginate the list of paginates using filtrex
  filters.

  ## Examples

      iex> list_snippets(%{})
      %{paginates: [%Paginate{}], ...}
  """
  @spec paginate_snippets(map) :: {:ok, map} | {:error, any}
  def paginate_snippets(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    with {:ok, filter} <- Filtrex.parse_params(filter_config(:paginates), params["paginate"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_snippets(filter, params) do
        format_pagination_results(page, params)
    else
      {:error, error} -> {:error, error}
      error -> {:error, error}
    end
  end
  defp do_paginate_snippets(filter, %{"user_id" => user_id } = params) do
    query = from s in Snippet,
      left_join: v in Vote, on: [snippet_id: s.id, user_id: ^user_id],
      preload: [votes: v]
    Filtrex.query(query, filter)
    |> order_by(^sort(params))
    |> Repo.paginate(params)
  end
  defp do_paginate_snippets(filter, params) do
    Snippet
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> Repo.paginate(params)
  end
  defp format_pagination_results(page, params) do
      {:ok,
        %{
          snippets: page.entries,
          user_id: params["user_id"],
          page_number: page.page_number,
          page_size: page.page_size,
          total_pages: page.total_pages,
          total_entries: page.total_entries,
          sort_field: params["sort_field"],
          sort_direction: params["sort_direction"]
        }
      }
  end
  def paginate_batch_list(ids, params, user_id) do
    query = case user_id do
      nil -> from s in Snippet,
      where: s.id in ^ids
      _ -> from s in Snippet,
      where: s.id in ^ids,
      left_join: v in Vote, on: [snippet_id: s.id, user_id: ^user_id],
      preload: [votes: v]
    end

    page = Repo.paginate(query, params)
    case page do
      :error -> {:error, "Something went wrong."}
      _ -> format_pagination_results(page, params)
    end
  end
  @doc """
  Returns the list of snippets.

  ## Examples

      iex> list_snippets()
      [%Snippet{}, ...]

  """
  def list_snippets do
    Repo.all(Snippet)
  end

  def list_snippets_with_votes(user_id) do
    query = from s in Snippet,
      left_join: v in Vote, on: [snippet_id: s.id, user_id: ^user_id],
      preload: [votes: v]
    Repo.all(query)
  end

  @doc """
  Gets a single snippet.

  Raises `Ecto.NoResultsError` if the Snippet does not exist.

  ## Examples

      iex> get_snippet!(123)
      %Snippet{}

      iex> get_snippet!(456)
      ** (Ecto.NoResultsError)

  """
  def get_snippet!(id), do: Repo.get!(Snippet, id)

  @doc """
  Creates a snippet.

  ## Examples

      iex> create_snippet(%{field: value})
      {:ok, %Snippet{}}

      iex> create_snippet(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_snippet(attrs \\ %{}) do
    %Snippet{}
    |> Snippet.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a snippet.

  ## Examples

      iex> update_snippet(snippet, %{field: new_value})
      {:ok, %Snippet{}}

      iex> update_snippet(snippet, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_snippet(%Snippet{} = snippet, attrs) do
    snippet
    |> Snippet.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Snippet.

  ## Examples

      iex> delete_snippet(snippet)
      {:ok, %Snippet{}}

      iex> delete_snippet(snippet)
      {:error, %Ecto.Changeset{}}

  """
  def delete_snippet(%Snippet{} = snippet) do
    Repo.delete(snippet)
  end

  def batch_list(ids) do
    query = from s in Snippet,
            where: s.id in ^ids
    Repo.all(query)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking snippet changes.

  ## Examples

      iex> change_snippet(snippet)
      %Ecto.Changeset{source: %Snippet{}}

  """
  def change_snippet(%Snippet{} = snippet) do
    Snippet.changeset(snippet, %{})
  end

  defp filter_config(:paginates) do
    defconfig do

    end
  end
end
