defmodule Codesio.Repo.Migrations.RemoveSnippetUserDefault do
  use Ecto.Migration

  def change do
    alter table(:snippets) do
      modify :user_id, :bigint, null: false, default: nil
    end
  end
end
