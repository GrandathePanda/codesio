defmodule Codesio.IpControl do
  @moduledoc """
  The IpControl context.
  """

  import Ecto.Query, warn: false
  alias Codesio.Repo

  import Torch.Helpers, only: [sort: 1, paginate: 4]
  import Filtrex.Type.Config

  alias Codesio.IpControl.BannedIp

  @pagination [page_size: 15]
  @pagination_distance 5

  @doc """
  Paginate the list of banned_ips using filtrex
  filters.

  ## Examples

      iex> list_banned_ips(%{})
      %{banned_ips: [%BannedIp{}], ...}
  """
  @spec paginate_banned_ips(map) :: {:ok, map} | {:error, any}
  def paginate_banned_ips(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <- Filtrex.parse_params(filter_config(:banned_ips), params["banned_ip"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_banned_ips(filter, params) do
      {:ok,
        %{
          banned_ips: page.entries,
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

  defp do_paginate_banned_ips(filter, params) do
    BannedIp
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  @doc """
  Returns the list of banned_ips.

  ## Examples

      iex> list_banned_ips()
      [%BannedIp{}, ...]

  """
  def list_banned_ips do
    Repo.all(BannedIp)
  end

  @doc """
  Gets a single banned_ip.

  Raises `Ecto.NoResultsError` if the Banned ip does not exist.

  ## Examples

      iex> get_banned_ip!(123)
      %BannedIp{}

      iex> get_banned_ip!(456)
      ** (Ecto.NoResultsError)

  """
  def get_banned_ip!(id), do: Repo.get!(BannedIp, id)
  @doc """
  Get a single banned_ip by the ip address.
  """
  def get_banned_ip_by_ip(ip), do: Repo.get_by(BannedIp, ip: ip)

  @doc """
  Creates a banned_ip.

  ## Examples

      iex> create_banned_ip(%{field: value})
      {:ok, %BannedIp{}}

      iex> create_banned_ip(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_banned_ip(attrs \\ %{}) do
    %BannedIp{}
    |> BannedIp.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a banned_ip.

  ## Examples

      iex> update_banned_ip(banned_ip, %{field: new_value})
      {:ok, %BannedIp{}}

      iex> update_banned_ip(banned_ip, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_banned_ip(%BannedIp{} = banned_ip, attrs) do
    banned_ip
    |> BannedIp.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a BannedIp.

  ## Examples

      iex> delete_banned_ip(banned_ip)
      {:ok, %BannedIp{}}

      iex> delete_banned_ip(banned_ip)
      {:error, %Ecto.Changeset{}}

  """
  def delete_banned_ip(%BannedIp{} = banned_ip) do
    Repo.delete(banned_ip)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking banned_ip changes.

  ## Examples

      iex> change_banned_ip(banned_ip)
      %Ecto.Changeset{source: %BannedIp{}}

  """
  def change_banned_ip(%BannedIp{} = banned_ip) do
    BannedIp.changeset(banned_ip, %{})
  end

  defp filter_config(:banned_ips) do
    defconfig do
      
    end
  end
end
