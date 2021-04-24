import Config

config :nerves_tips, NervesTipsWeb.Endpoint,
  server: true,
  http: [port: {:system, "PORT"}], # Needed for Phoenix 1.2 and 1.4. Doesn't hurt for 1.3.
  url: [host: System.get_env("APP_NAME") <> ".gigalixirapp.com", port: 443]

config :nerves_tips, NervesTips.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  ssl: true,
  pool_size: 9 # (25-6)/(1+1) size DB
