# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     MarketData.Repo.insert!(%MarketData.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# Make seeds idempotent and safe by:
# 1. Checking for existing records before inserting
# 2. Using transactions for related inserts
# 3. Adding conditional guards to prevent duplicates

alias MarketData.Repo

import Ecto.Query

# Example: Safe seeding with existence checks
# Uncomment and modify these examples when adding real seeding logic

# # Check if data already exists before seeding
# unless Repo.exists?(from u in "users", where: u.email == "admin@example.com") do
#   Repo.insert!(%MarketData.User{
#     email: "admin@example.com",
#     name: "Admin User",
#     role: "admin",
#     inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
#     updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
#   })
# end

# # Use transactions for related data
# Repo.transaction(fn ->
#   # Check if watchlist already exists
#   unless Repo.exists?(from w in "watchlists", where: w.name == "Tech Stocks") do
#     watchlist = Repo.insert!(%MarketData.Watchlist{
#       name: "Tech Stocks",
#       description: "Major technology company stocks",
#       inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
#       updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
#     })

#     # Add symbols to watchlist only if they don't exist
#     symbols = ["AAPL", "GOOGL", "MSFT", "AMZN"]
#     for symbol <- symbols do
#       unless Repo.exists?(from s in "watchlist_symbols",
#                          where: s.watchlist_id == ^watchlist.id and s.symbol == ^symbol) do
#         Repo.insert!(%MarketData.WatchlistSymbol{
#           watchlist_id: watchlist.id,
#           symbol: symbol,
#           inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
#           updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
#         })
#       end
#     end
#   end
# end)

# # Example with upsert for settings/config data
# # This ensures the setting exists with the correct value
# case Repo.get_by(MarketData.Setting, key: "default_timezone") do
#   nil ->
#     Repo.insert!(%MarketData.Setting{
#       key: "default_timezone",
#       value: "America/New_York",
#       inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
#       updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
#     })
#   setting ->
#     Repo.update!(MarketData.Setting.changeset(setting, %{
#       value: "America/New_York",
#       updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
#     }))
# end

IO.puts("Seeds completed successfully!")
