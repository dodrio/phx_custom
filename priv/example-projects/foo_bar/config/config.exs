# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :foo_bar,
  ecto_repos: [FooBar.Repo]

# Configures the endpoint
config :foo_bar, FooBarWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "66towUUOuWjbNhW2zooz1wsPZRhKUuLRg5sM1Zlg3nS3uCRRUeTk7A0NAZSm4UP+",
  render_errors: [view: FooBarWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: FooBar.PubSub,
  live_view: [signing_salt: "UoZZCZlv"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
