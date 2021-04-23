defmodule NervesTips.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :avatar_url, :string
      add :name, :string
      add :nickname, :string
      add :uid, :string

      timestamps(type: :utc_datetime)
    end
  end
end
