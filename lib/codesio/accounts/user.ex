defmodule Codesio.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  use Coherence.Schema
  schema "users" do
    field :email, :string
    field :name, :string
    field :username, :string
    field :role, UserRoleEnum
    has_many :votes, Codesio.Vote
    coherence_schema()
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :username, :email, :role] ++ coherence_fields)
    |> validate_required([:name, :username, :email, :role])
    |> unique_constraint(:username)
    |> unique_constraint(:email)
    |> validate_format(:email,~r/@/)
    |> validate_coherence(attrs)
  end

  def changeset(user, attrs, :password) do
    user
    |> cast(attrs, ~w(password, password_confirmation reset_password_token, reset_password_sent_at))
    |> validate_coherence_password_reset(attrs)
  end
end
