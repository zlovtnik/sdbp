defmodule MarketData.Repo do
  use Ecto.Repo,
    otp_app: :market_data,
    adapter: Ecto.Adapters.Postgres
end
