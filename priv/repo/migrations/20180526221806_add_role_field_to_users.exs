defmodule Codesio.Repo.Migrations.AddRoleFieldToUsers do
  use Ecto.Migration

  def up do
    UserRoleEnum.create_type
    alter table(:users) do
      add :role, :user_role, null: false, default: "user"
    end
  end

  def down do
    UserRoleEnum.drop_type
  end
end
