# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

# Configure Mix tasks and generators
config :foo_bar,
  ecto_repos: [FooBar.Repo]

config :foo_bar_web,
  ecto_repos: [FooBar.Repo],
  generators: [context_app: :foo_bar]

# Configures the endpoint
config :foo_bar_web, FooBarWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "+pGKFlKgpJ7iJL+sBLfg4Bh2yjMgDkeB9nl23EUZddN038bDUierSIDZbqnA+CSr",
  render_errors: [view: FooBarWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: FooBar.PubSub,
  live_view: [signing_salt: "VPDkAjsC"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
