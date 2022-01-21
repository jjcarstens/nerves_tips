# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :nerves_tips,
  ecto_repos: [NervesTips.Repo]

# Configures the endpoint
config :nerves_tips, NervesTipsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "9yxWj4p9iOQLRTbmRE59hZe4Rj3hzu99yuJ5BgPS9VuMriqIijrfb+bLQwQW6pSx",
  render_errors: [view: NervesTipsWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: NervesTips.PubSub,
  live_view: [signing_salt: "qfUZGYpK"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.12",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :tailwind,
  version: "3.0.15",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, [default_scope: "", allow_private_emails: true]}
  ]

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: {:system, "GITHUB_CLIENT_ID"},
  client_secret: {:system, "GITHUB_CLIENT_SECRET"}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
