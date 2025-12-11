import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :market_data, MarketData.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "market_data_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :market_data, MarketDataWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "AjqsDk+yetaF/nL3PuPPrkgBv06wjXEzE9n96j5pueT7oPkgoav3QDc/Khu3YBOa",
  session_signing_salt: "AqHmrFAnw4olbMcKz7irCm0VLLByDpvz",
  session_options: [
    store: :cookie,
    key: "_market_data_key",
    signing_salt: "AqHmrFAnw4olbMcKz7irCm0VLLByDpvz",
    same_site: "Lax"
  ],
  live_view: [signing_salt: "QTKkbOHl"]

# In test we don't send emails
config :market_data, MarketData.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
