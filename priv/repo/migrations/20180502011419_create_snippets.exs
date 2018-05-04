defmodule Codesio.Repo.Migrations.CreateSnippets do
  use Ecto.Migration

  def change do
    create table(:snippets) do
      add :tags, {:array, :string}
      add :snippet, :text

      timestamps()
    end

  end
end
