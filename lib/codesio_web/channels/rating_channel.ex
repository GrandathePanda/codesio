defmodule CodesioWeb.RatingChannel do
  alias CodesioHelpers.ElasticsearchHelper
  alias Codesio.SnippetsDisplay
  alias Phoenix.View
  alias CodesioWeb.SnippetView
  alias CodesioWeb.Endpoint
  alias Codesio.Repo
  alias Codesio.Vote
  import Ecto.Query, warn: false
  use Phoenix.Channel

  def join("rating:*", _message, socket) do
    {:ok, socket}
  end
  def handle_in("upvote", %{"body" => body}, socket) do
    handle_vote(:upvote, :downvote, body, socket)
  end
  def handle_in("downvote", %{"body" => body}, socket) do
    handle_vote(:downvote, :upvote, body, socket)
  end
  defp handle_vote(type, opposite_type, body, socket) do
    user_id = socket.assigns[:user_id]
    query = from v in Vote,
      where: v.user_id == ^user_id,
      where: v.snippet_id == ^body
    vote = Repo.one(query)
    res = cond do
      is_nil(vote) -> new_vote(user_id, body, type)
      vote.type == opposite_type -> new_vote(user_id, body, type, vote)
      true -> {:reply, :ok}
    end
    Tuple.append(res, socket)
  end
  defp new_vote(user_id, snippet_id, type) do
    %Vote{}
    |> Vote.changeset(%{user_id: user_id, snippet_id: snippet_id, type: type})
    |> Repo.insert()
    {:reply, :ok}
  end
  defp new_vote(user_id, snippet_id, type, %Vote{} = vote) do
    Repo.delete(vote)
    new_vote(user_id, snippet_id, type)
  end
end
