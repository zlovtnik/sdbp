import Config

# Configure your database
config :market_data, MarketData.Repo,
  username: System.get_env("DATABASE_USERNAME", "postgres"),
  password: System.get_env("DATABASE_PASSWORD", "postgres"),
  database: System.get_env("DATABASE_NAME", "market_data_dev"),
  hostname: System.get_env("DATABASE_HOST", "localhost"),
  port: (case Integer.parse(System.get_env("DATABASE_PORT", "5432")) do
    {int, _} -> int
    _ ->
      IO.warn("Invalid DATABASE_PORT environment variable, falling back to 5432")
      5432
  end),
  pool_size: (case Integer.parse(System.get_env("DATABASE_POOL_SIZE", "10")) do
    {int, _} -> int
    _ ->
      IO.warn("Invalid DATABASE_POOL_SIZE environment variable, falling back to 10")
      10
  end)

# LiveView signing salt - must be set at runtime
config :market_data, MarketDataWeb.Endpoint,
  live_view: [signing_salt: System.get_env("LIVE_VIEW_SIGNING_SALT") || "dGVzdCBzaWduaW5nIHNhbHQgdGVzdCBzaWduaW5nIHNhbHQgdGVzdCBzaWduaW5nIHNhbHQ="]

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/market_data start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :market_data, MarketDataWeb.Endpoint, server: true
end

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :market_data, MarketData.Repo,
    ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host =
    System.get_env("PHX_HOST") ||
      raise """
      environment variable PHX_HOST is missing.
      For example: myapp.com
      """
  port =
    case Integer.parse(System.get_env("PORT") || "4000") do
      {int, _} -> int
      _ ->
        IO.warn("Invalid PORT environment variable, falling back to 4000")
        4000
    end

  config :market_data, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :market_data, MarketDataWeb.Endpoint,
    # External URL configuration (what clients connect to)
    # Using HTTPS on port 443 for production deployments behind a reverse proxy
    url: [host: host, port: 443, scheme: "https"],
    # Internal HTTP listener (what the reverse proxy forwards to)
    # The PORT environment variable controls the internal port (default: 4000)
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/bandit/Bandit.html#t:options/0
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base,
    session_signing_salt: System.fetch_env!("SESSION_SIGNING_SALT"),
    session_options: [
      store: :cookie,
      key: "_market_data_key",
      signing_salt: System.fetch_env!("SESSION_SIGNING_SALT"),
      same_site: "Lax"
    ],
    # LiveView signing salt for securing LiveView connections
    # Generate with: :crypto.strong_rand_bytes(32) |> Base.encode64()
    live_view: [signing_salt: System.fetch_env!("LIVE_VIEW_SIGNING_SALT")]

  # ## SSL Support
  #
  # This application is configured for deployment behind a reverse proxy
  # that terminates TLS. The proxy handles SSL certificates and forwards
  # requests as HTTP to the internal port (configured above).
  #
  # If you need the application to terminate TLS directly (not recommended
  # for production), uncomment and configure the https block below:
  #
  #     config :market_data, MarketDataWeb.Endpoint,
  #       https: [
  #         ip: {0, 0, 0, 0, 0, 0, 0, 0},
  #         port: 443,
  #         cipher_suite: :strong,
  #         keyfile: System.get_env("SSL_KEY_PATH"),
  #         certfile: System.get_env("SSL_CERT_PATH")
  #       ],
  #       # Remove or modify the http block above when using https
  #       force_ssl: [hsts: true]
  #
  # For all supported SSL configuration options, see:
  # https://hexdocs.pm/plug/Plug.SSL.html#configure/1

  # ## Configuring the mailer
  #
  # In production you need to configure the mailer to use a different adapter.
  # Also, you may need to configure the Swoosh API client of your choice if you
  # are not using SMTP. Here is an example of the configuration:
  #
  #     config :market_data, MarketData.Mailer,
  #       adapter: Swoosh.Adapters.Mailgun,
  #       api_key: System.get_env("MAILGUN_API_KEY"),
  #       domain: System.get_env("MAILGUN_DOMAIN")
  #
  # For this example you need include a HTTP client required by Swoosh API client.
  # Swoosh supports Hackney and Finch out of the box:
  #
  #     config :swoosh, :api_client, Swoosh.ApiClient.Hackney
  #
  # See https://hexdocs.pm/swoosh/Swoosh.html#module-installation for details.
end
