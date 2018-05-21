defmodule Codesio.Repo.Migrations.AddRatingToSnippet do
  use Ecto.Migration

  def change do
    alter table(:snippets) do
      add :rating, :float, default: 0
    end
  end

end
