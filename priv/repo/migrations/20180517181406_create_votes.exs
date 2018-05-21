defmodule Codesio.Repo.Migrations.CreateVotes do
  use Ecto.Migration

  def up do
    VoteTypeEnum.create_type
    create table(:votes) do
      add :user_id, references(:users)
      add :snippet_id, references(:snippets)
      add :type, :vote_type, null: false
      timestamps()
    end
  end
  def down do
    drop table(:votes)
    VoteTypeEnum.drop_type
  end
end
