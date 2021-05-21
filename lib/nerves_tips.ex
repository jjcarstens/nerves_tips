defmodule NervesTips do
  alias NervesTips.{Repo, Schema.Tip, Schema.User}
  import Ecto.Query

  def published() do
    from(t in Tip, where: not is_nil(t.published_on), order_by: [asc: :number])
    |> Repo.all()
  end

  def get_user!(user_id), do: Repo.get!(User, user_id)

  def publish(%Tip{} = tip, link) do
    Tip.publish_changeset(tip, %{twitter_link: link})
    |> Repo.update()
  end

  def queued_tips() do
    from(t in Tip,
      where: is_nil(t.published_on) or is_nil(t.twitter_link),
      order_by: [asc: :number],
      preload: :created_by
    )
    |> Repo.all()
  end

  def user_by_uid_or_nickname(uid, nickname) do
    from(u in User, where: [uid: ^uid], or_where: [nickname: ^nickname])
    |> Repo.one()
  end

  def update(%mod{} = record, attrs) do
    mod.changeset(record, attrs)
    |> Repo.update()
  end

  def swap_tip_numbers!(a, b) do
    # To prevent hitting the unique index on tip number, we need
    # to reset numbers to an available value then do the swap
    Ecto.Multi.new()
    |> Ecto.Multi.update(:next, Tip.changeset(a, %{number: nil}))
    |> Ecto.Multi.update(:new_b, Tip.changeset(b, %{number: a.number}))
    |> Ecto.Multi.update(:new_a, Tip.changeset(a, %{number: b.number}))
    |> Repo.transaction()
    |> case do
      {:ok, result} -> [result.new_a, result.new_b]
      err -> raise("Failed to swap tip numbers - #{inspect(err)}")
    end
  end
end
