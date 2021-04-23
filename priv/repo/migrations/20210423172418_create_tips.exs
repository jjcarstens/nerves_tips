defmodule NervesTips.Repo.Migrations.CreateTips do
  use Ecto.Migration

  def change do
    create table(:tips) do
      add :created_by_id, references("users")
      add :description, :string
      add :image, :binary
      add :image_type, :string
      add :number, :integer
      add :published_on, :utc_datetime
      add :title, :string
      add :twitter_link, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:tips, :number)
  end
end
