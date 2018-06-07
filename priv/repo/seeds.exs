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
Faker.start()
Codesio.Repo.delete_all Codesio.Accounts.User
Codesio.Repo.delete_all Codesio.SnippetsDisplay.Snippet
Codesio.Repo.delete_all Codesio.Votes
users = for _ <- 0..1000 do
  Codesio.Accounts.User.changeset(%Codesio.Accounts.User{}, %{name: Faker.Name.name(),
                                                              email: Faker.Internet.email(),
                                                              username: Faker.Internet.user_name(),
                                                              password: Faker.Random.Elixir.random_bytes(32),
                                                              password_confirmation: "secret"})
  |> Codesio.Repo.insert!
end

snippets = for _ <- 0..10000 do
  tags = for _ < 0..:rand.uniform(10) do
    Faker.Pokemon.En.name()
  end
  Codesio.SnippetsDisplay.Snippet.changeset(%Codesio.SnippetsDisplay.Snippet{}, %{
    snipept: Faker.Lorem.Shakespeare.king_richard_iii(),
    tags: tags,
    rating: 0,
    user_id: Enum.random(users).id,
  })
end

