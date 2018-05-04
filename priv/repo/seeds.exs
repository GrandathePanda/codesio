# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Codesio.Repo.insert!(%Codesio.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
Codesio.Repo.delete_all Codesio.Accounts.User

Codesio.Accounts.User.changeset(%Codesio.Accounts.User{}, %{name: "Test User", email: "testuser@example.com", password: "secret", password_confirmation: "secret"})
|> Codesio.Repo.insert!
