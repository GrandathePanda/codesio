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
require Comb
require Benchwarmer
Codesio.Repo.delete_all Codesio.Vote
Codesio.Repo.delete_all Codesio.SnippetsDisplay.Snippet
Codesio.Repo.delete_all Codesio.Accounts.User

config = %{users: 100, snippets: 1000, votes: 500}
defmodule UserFactory do
  def create_user(_) do
    passwd = Faker.Name.name()
    Codesio.Accounts.User.changeset(%Codesio.Accounts.User{}, %{name: Faker.Name.name(),
      email: Faker.Internet.email(),
      username: Faker.Internet.user_name(),
      password: passwd,
      role: :user,
      password_confirmation: passwd})
      |> Codesio.Repo.insert
  end
end

defmodule SnippetFactory do
  def create_snippet(user_id) do
    tags = Enum.map(0..:rand.uniform(10), fn _ ->
      Faker.Pokemon.En.name()
    end)
    language = Enum.random(CodesioWeb.get_supported_languages())
    params = %{
      "snippet" => Faker.Lorem.Shakespeare.king_richard_iii(),
      "tags" => tags,
      "user_id" => user_id,
      "language" => language
    }
    {status, snippet} = res = Codesio.SnippetsDisplay.Snippet.changeset(%Codesio.SnippetsDisplay.Snippet{}, params)
    |> Codesio.Repo.insert
    if status == :ok do
      CodesioHelpers.ElasticsearchHelper.insert_into(Map.put(params, "id", snippet.id))
    end
    res
  end
end

defmodule VoteFactory do
  def create_vote(user_id, snippet_id) do
    vote_type = Enum.random([:upvote, :downvote, :none])
    case vote_type do
      :none -> nil
      _ -> Codesio.Vote.changeset(%Codesio.Vote{}, %{
        snippet_id: snippet_id,
        user_id: user_id,
        type: vote_type
      })
      |> Codesio.Repo.insert!
      |> change_rating(vote_type)
    end
  end

  defp change_rating(vote, type) do
      query = """
        UPDATE snippets SET rating=rating + $1::float WHERE id=$2 RETURNING rating;
      """
      change = case type do
        :upvote -> 1.0
        :downvote -> -1.0
      end
      Ecto.Adapters.SQL.query(Codesio.Repo, query, [change, vote.snippet_id])
      vote
  end
end
users = Enum.map(0..config[:users]-1, &UserFactory.create_user()/1)
snippets = Enum.map(0..config[:snippets]-1, fn n ->
  {status, user} = Enum.random(users)
  case status do
    :ok -> SnippetFactory.create_snippet(user.id)
    _ -> {:error, nil}
  end
end)

user_snippets = Comb.cartesian_product(users, snippets)
votes = user_snippets
        |> Enum.to_list
        |> Enum.take_random(config[:votes])
        |> Enum.map(fn [{u_status, user}, {s_status, snippet}] ->
          if u_status == :error or s_status == :error do
            {:error, nil}
          else
            VoteFactory.create_vote(user.id, snippet.id)
          end
end)
