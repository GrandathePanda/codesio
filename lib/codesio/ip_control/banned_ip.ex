defmodule Codesio.IpControl.BannedIp do
  use Ecto.Schema
  import Ecto.Changeset

  schema "banned_ips" do
    field :ip, Codesio.Inet
    timestamps()
  end

  @doc false
  def changeset(snippet, attrs) do
    snippet
    |> cast(attrs, [:ip])
    |> validate_required([:ip])
  end
  @doc false
  def changeset(attrs) do
    %{}
    |> cast(attrs, [:ip])
    |> validate_required([:ip])
  end
end
