# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :channel_demo,
  ecto_repos: [ChannelDemo.Repo]

# Configures the endpoint
config :channel_demo, ChannelDemo.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "jPeYLCf4Sg9YCt6yP6ZIe2JBs2y0NOpsb4QaXGhQpwYJwkXhWtmzfe0aJt4ps8Er",
  render_errors: [view: ChannelDemo.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ChannelDemo.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
