defmodule Codesio.SnippetsDisplay do
  @moduledoc """
  The SnippetsDisplay context.
  """

  import Ecto.Query, warn: false
  alias Codesio.Repo

  alias Codesio.SnippetsDisplay.Snippet
  alias Codesio.Vote

  import Torch.Helpers, only: [sort: 1, paginate: 4]
  import Filtrex.Type.Config

  @pagination [page_size: 15]
  @pagination_distance 5

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

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <- Filtrex.parse_params(filter_config(:paginates), params["paginate"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_snippets(filter, params) do
      {:ok,
        %{
          snippets: page.entries,
          page_number: page.page_number,
          page_size: page.page_size,
          total_pages: page.total_pages,
          total_entries: page.total_entries,
          distance: @pagination_distance,
          sort_field: sort_field,
          sort_direction: sort_direction
        }
      }
    else
      {:error, error} -> {:error, error}
      error -> {:error, error}
    end
  end

  defp do_paginate_snippets(filter, params) do
    Snippet
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
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
