defmodule Codesio.Repo do
  use Ecto.Repo, otp_app: :codesio
  use Scrivener, page_size: 15

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end
end
