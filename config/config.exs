# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :nerves_tips,
  ecto_repos: [NervesTips.Repo]

# Configures the endpoint
config :nerves_tips, NervesTipsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "9yxWj4p9iOQLRTbmRE59hZe4Rj3hzu99yuJ5BgPS9VuMriqIijrfb+bLQwQW6pSx",
  render_errors: [view: NervesTipsWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: NervesTips.PubSub,
  live_view: [signing_salt: "qfUZGYpK"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
