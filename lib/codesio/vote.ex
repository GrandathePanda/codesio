defmodule Codesio.Vote do
  use Ecto.Schema
  import Ecto.Changeset


  schema "votes" do
    belongs_to :snippet, Codesio.Snippet
    belongs_to :user, Codesio.User
    field :type, VoteTypeEnum
    timestamps()
  end

  @doc false
  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [:user_id, :snippet_id, :type])
    |> validate_required([:user_id, :snippet_id, :type])
  end
end
