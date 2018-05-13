defmodule Codesio.SnippetsDisplay.Snippet do
  use Ecto.Schema
  import Ecto.Changeset


  schema "snippets" do
    field :snippet, :string
    field :tags, { :array, :string }
    field :language, :string
    field :rating, :integer, default: 0
    timestamps()
  end

  @doc false
  def changeset(snippet, attrs) do
    snippet
    |> cast(attrs, [:snippet, :tags, :language])
    |> validate_required([:snippet, :tags, :language])
  end
  @doc false
  def changeset(attrs) do
    %{}
    |> cast(attrs, [:snippet, :tags, :language])
    |> validate_required([:snippet, :tags, :language])
  end
end
