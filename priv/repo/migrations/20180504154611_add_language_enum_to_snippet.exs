defmodule Codesio.Repo.Migrations.AddLanguageEnumToSnippet do
  use Ecto.Migration

  def change do
    alter table(:snippets) do
      add :language, :text
    end
  end
end
