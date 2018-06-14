defmodule Codesio.Repo.Migrations.AddScoreFieldToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :score, :integer, null: false, default: 0
    end
  end
end
