defmodule NervesTips.Repo do
  use Ecto.Repo,
    otp_app: :nerves_tips,
    adapter: Ecto.Adapters.Postgres
end
