defmodule Codesio.SnippetsDisplay.Snippet do
  use Ecto.Schema
  import Ecto.Changeset


  schema "snippets" do
    field :snippet, :string
    field :tags, Codesio.Tags
    field :language, :string
    field :rating, :float, default: 0.0
    belongs_to :user, Codesio.Accounts.User
    has_many :votes, Codesio.Vote
    timestamps()
  end

  @doc false
  def changeset(snippet, attrs) do
    snippet
    |> cast(attrs, [:snippet, :tags, :language, :user_id])
    |> validate_required([:snippet, :tags, :language, :user_id])
  end
  @doc false
  def changeset(attrs) do
    %{}
    |> cast(attrs, [:snippet, :tags, :language, :user_id])
    |> validate_required([:snippet, :tags, :language, :user_id])
  end
end
