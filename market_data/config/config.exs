# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :market_data,
  ecto_repos: [MarketData.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configure your database
# Moved to config/runtime.exs for environment-based configuration

# Configure Prometheus metrics
config :telemetry_metrics_prometheus,
  port: 9568

# Configures the endpoint
config :market_data, MarketDataWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: MarketDataWeb.ErrorHTML, json: MarketDataWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: MarketData.PubSub

# Session options for endpoint
config :market_data, :session_options,
  store: :cookie,
  key: "_market_data_key",
  signing_salt: System.get_env("SESSION_SIGNING_SALT") || "fallback_signing_salt_for_compile_time",
  same_site: "Lax"

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :market_data, MarketData.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  market_data: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  market_data: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
