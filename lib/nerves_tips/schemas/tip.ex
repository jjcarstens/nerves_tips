defmodule NervesTips.Schema.Tip do
  use Ecto.Schema

  alias NervesTips.Repo

  import Ecto.Changeset
  import Ecto.Query

  @char_limit 280

  @title_start "Nerves Tip #"

  schema "tips" do
    belongs_to :created_by, NervesTips.Schema.User

    field :description, :string
    field :image, :binary
    field :image_type, :string
    field :number, :integer
    field :published_on, :utc_datetime
    field :title, :string
    field :twitter_link, :string

    timestamps(type: :utc_datetime)
  end

  def build_body(number, title, description) do
    """
    #{@title_start}#{number} - #{title}

    #{description}
    """
  end

  def changeset(%__MODULE__{} = tip, attrs) do
    tip
    |> cast(attrs, [
      :created_by_id,
      :description,
      :image,
      :image_type,
      :number,
      :published_on,
      :title,
      :twitter_link
    ])
    |> maybe_add_number()
    |> validate_required([:description, :title])
    |> validate_character_limit()
    |> unique_constraint(:number)
  end

  def publish_changeset(tip, attrs) do
    changeset(tip, attrs)
    |> put_change(:published_on, DateTime.utc_now() |> DateTime.truncate(:second))
    # |> validate_required([:twitter_link])
    |> validate_format(:twitter_link, ~r/^https:\/\/twitter.com/)
  end

  defp maybe_add_number(changeset) do
    if get_field(changeset, :number) do
      changeset
    else
      put_change(changeset, :number, next_number())
    end
  end

  defp next_number() do
    indexes =
      from(t in __MODULE__, select: t.number)
      |> Repo.all()

    # Look at all the indexes and get the next number that is
    # missing. This will either be an inner number, or the next
    # number after the max
    next = if Enum.empty?(indexes), do: 1, else: Enum.max(indexes) + 1
    Enum.find(1..next, fn i -> i not in indexes end)
  end

  defp validate_character_limit(changeset) do
    num = get_field(changeset, :number)
    title = get_field(changeset, :title)
    description = get_field(changeset, :description)

    body_len =
      build_body(num, title, description)
      |> String.codepoints()
      |> length

    if body_len > @char_limit do
      changeset
      |> add_error(:description, "over limit: #{body_len}/#{@char_limit}")
      |> add_error(:title, "over limit: #{body_len}/#{@char_limit}")
    else
      changeset
    end
  end
end
