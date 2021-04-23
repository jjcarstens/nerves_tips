defmodule NervesTips.Schema.User do
  use Ecto.Schema

  alias Ecto.Changeset

  schema "users" do
    field :avatar_url, :string
    field :name, :string
    field :nickname, :string
    field :uid, :string

    timestamps()
  end

  def changeset(user, attrs) do
    Changeset.cast(user, attrs, [:avatar_url, :name, :nickname, :uid])
  end
end
