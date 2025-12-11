defmodule MarketData do
  @moduledoc """
  MarketData manages real-time financial market data processing and distribution.

  This domain handles high-performance financial data streams combining kdb+ time-series
  database capabilities with Phoenix real-time web distribution. The system processes
  market data through multiple specialized contexts:

  ## Primary Contexts

  - **Pricing**: Manages price data, quotes, and trade information with real-time updates
  - **Feeds**: Handles data ingestion from kdb+ tickerplant and external market feeds
  - **Normalization**: Validates, normalizes, and enriches raw market data
  - **Storage**: Manages data persistence, retrieval, and historical data access
  - **Distribution**: Provides real-time data distribution to web clients via Phoenix channels

  Contexts are responsible for business logic, data validation, and interfacing with
  both the PostgreSQL metadata store and kdb+ time-series database.
  """
end
