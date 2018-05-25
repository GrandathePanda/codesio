defmodule Codesio.Repo.Migrations.CreateBannedIpsTable do
  use Ecto.Migration
  def change do
    create table(:banned_ips) do
      add :ip, :inet, null: false
      timestamps()
    end
    create unique_index(:banned_ips, [:ip])
  end
end
