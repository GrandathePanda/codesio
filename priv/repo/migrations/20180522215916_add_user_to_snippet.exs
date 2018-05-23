defmodule Codesio.Repo.Migrations.AddUserToSnippet do
  use Ecto.Migration

  def change do
    alter table(:snippets) do
      add :user_id, references(:users), null: false, default: 1
    end
  end
end
