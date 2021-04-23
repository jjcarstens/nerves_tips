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
      order_by: [asc: :number]
    )
    |> Repo.all()
  end

  def user_by_uid_or_nickname(uid, nickname) do
    from(u in User, where: [uid: ^uid], or_where: [nickname: ^nickname])
    |> Repo.one()
  end

  def update_user(user, attrs) do
    User.changeset(user, attrs)
    |> Repo.update()
  end
end
