import Config

config :nerves_tips, NervesTipsWeb.Endpoint,
  server: true,
  http: [
    port: {:system, "PORT"}, # Needed for Phoenix 1.2 and 1.4. Doesn't hurt for 1.3.
    transport_options: [socket_opts: [:inet6]]
  ],
  url: [host: System.get_env("APP_NAME") <> ".gigalixirapp.com", port: 443],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  live_view: [signing_salt: System.get_env("LIVE_VIEW_SIGNING_SALT")]

config :nerves_tips, NervesTips.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  ssl: true,
  pool_size: String.to_integer(System.get_env("POOL_SIZE"))

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET")
