defmodule CodesioWeb.RatingChannel do
  alias CodesioHelpers.ElasticsearchHelper
  alias Codesio.SnippetsDisplay
  alias Phoenix.View
  alias CodesioWeb.SnippetView
  alias CodesioWeb.Endpoint
  alias Codesio.Repo
  alias Codesio.Vote
  alias Codesio.SnippetsDisplay.Snippet
  alias Codesio.Accounts
  import Ecto.Query, warn: false
  use Phoenix.Channel

  def join("rating:*", _message, socket) do
    {:ok, socket}
  end

  def handle_in("upvote", %{"body" => body}, socket) do
    {rating, res} = handle_vote(:upvote, :downvote, body, socket)
    if not is_nil(rating) do
      user = Repo.one(Ecto.assoc(SnippetsDisplay.get_snippet(body), :user))
      Accounts.update_user(user, %{ score: user.score + 1 })
      push socket, "rating_change", %{rating: rating, snippet_id: body}
    end
    res
  end

  def handle_in("downvote", %{"body" => body}, socket) do
    {rating, res} = handle_vote(:downvote, :upvote, body, socket)
    if not is_nil(rating) do
      push socket, "rating_change", %{rating: rating, snippet_id: body}
    end
    res
  end

  def handle_in("unvote", %{"body" => id}, socket) do
    user_id = socket.assigns[:user_id]
    query = from v in Vote,
      where: v.user_id == ^user_id,
      where: v.snippet_id == ^id
    vote = List.first(Repo.all(query))
    {status, _} = Repo.transaction(fn ->
      push socket, "rating_change", %{rating: undo_rating(vote.type, id), snippet_id: id}
      Repo.delete(vote)
      user = Repo.one(Ecto.assoc(SnippetsDisplay.get_snippet(id), :user))
      Accounts.update_user(user, %{ score: user.score - 1 })
    end)
    case status do
      :ok -> {:reply, :ok, socket}
      _ -> {:reply, :error, socket}
    end
  end

  defp handle_vote(type, opposite_type, body, socket) do
    user_id = socket.assigns[:user_id]
    query = from v in Vote,
      where: v.user_id == ^user_id,
      where: v.snippet_id == ^body
    vote = Repo.one(query)
    { status, rating } = Repo.transaction(fn ->
      cond do
        is_nil(vote) -> new_vote(user_id, body, type)
        vote.type == opposite_type -> new_vote(user_id, body, type, vote)
        true -> nil
      end
    end)
    case status do
      :ok -> {rating, {:reply, :ok, socket}}
      _ -> {nil, {:reply, :error, socket}}
    end
  end

  defp increase_user_score() do

  end

  defp new_vote(user_id, snippet_id, type, %Vote{} = vote) do
    undo_rating(vote.type, snippet_id)
    Repo.delete(vote)
    new_vote(user_id, snippet_id, type)
  end
  defp new_vote(user_id, snippet_id, type) do
    %Vote{}
    |> Vote.changeset(%{user_id: user_id, snippet_id: snippet_id, type: type})
    |> Repo.insert()
    change_rating(type, snippet_id)
  end

  defp undo_rating(type, id) do
    case type do
      :upvote -> change_rating(:downvote, id)
      :downvote -> change_rating(:upvote, id)
    end
  end
  defp change_rating(type, snippet_id) do
    query = """
      UPDATE snippets SET rating=rating + $1::float WHERE id=$2 RETURNING rating;
    """
    change = case type do
      :upvote -> 1.0
      :downvote -> -1.0
    end
    { _, %{ rows: rows } } = Ecto.Adapters.SQL.query(Repo, query, [change, String.to_integer(snippet_id)])
    hd(List.first(rows))
  end
end
