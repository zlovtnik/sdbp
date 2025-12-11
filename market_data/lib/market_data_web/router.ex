defmodule MarketDataWeb.Router do
  use MarketDataWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MarketDataWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :metrics do
    plug :accepts, ["json"]
    plug :basic_auth
  end

  scope "/", MarketDataWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Prometheus metrics endpoint
  scope "/metrics" do
    pipe_through :metrics
    forward "/", TelemetryMetricsPrometheus.Router
  end

  # Other scopes may use custom stacks.
  # scope "/api", MarketDataWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:market_data, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MarketDataWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  defp basic_auth(conn, _opts) do
    import Plug.Conn

    with ["Basic " <> encoded] <- get_req_header(conn, "authorization"),
         {:ok, decoded} <- Base.decode64(encoded),
         [username, password] <- String.split(decoded, ":", parts: 2),
         ^username <- System.get_env("METRICS_USERNAME", "admin"),
         ^password <- System.get_env("METRICS_PASSWORD", "password") do
      conn
    else
      _ ->
        conn
        |> put_status(401)
        |> put_resp_header("www-authenticate", "Basic realm=\"Metrics\"")
        |> halt()
    end
  end
end
