# AI Coding Guidelines for kdb+/Elixir Stock Market Data Platform

## Architecture Overview

This project implements a high-performance stock market data platform combining kdb+'s time-series capabilities with Elixir/Phoenix for real-time distribution.

### Core Components
- **kdb+ Layer**: Feedhandler (port 5009) → Tickerplant (5010) → RDB (5011) + HDB (5012), Gateway (5013)
- **Elixir Layer**: Phoenix app with KDB connection pool, REST API, WebSocket channels
- **Data Flow**: Market feeds → kdb+ processing → Elixir broadcasting → Web/mobile clients

### Key Design Decisions
- kdb+ handles high-frequency time-series data with sub-20ms latency targets
- Elixir manages client connections, API serving, and cross-component coordination
- PostgreSQL stores application metadata (users, watchlists) separate from time-series data

## Development Workflows

### Starting the Full System
```bash
# Terminal 1: Start kdb+ processes
cd kdb && ./run.sh

# Terminal 2: Start Phoenix app
cd market_data && mix phx.server

# Optional: Start PostgreSQL
docker-compose up postgres
```

### kdb+ Development
- Connect to processes: `q -p 5010` (tickerplant), `q -p 5011` (RDB), etc.
- Query examples: `select from trade where sym=\`AAPL`
- Logs: `kdb/logs/` directory
- Schema defined in `kdb/tick/schema.q` with sorted (`s#`) and grouped (`g#`) attributes

### Elixir Development
- Standard Phoenix: `mix deps.get`, `mix test`, `mix phx.server`
- Database: `mix ecto.setup` (create/reset/migrate/seed)
- CI runs on push/PR with Elixir 1.15, OTP 26

## Code Patterns & Conventions

### kdb+ Patterns
- Table schemas use attributed columns: `time:\`s#timestamp$()` for sorted timestamps
- Standard tick architecture: load `schema.q`, `u.q`, call `.u.init[]`
- Process communication via TCP ports, no authentication in dev

### Elixir Patterns
- KDB integration modules under `MarketData.KDB.*` (planned: Connection, Pool, Query, Subscriber)
- IPC communication via Port driver (custom NIF planned for performance)
- Phoenix channels for WebSocket real-time updates
- PubSub integration for internal message broadcasting

### Data Models
- Trade: `[time, sym, price, size, exchange, condition]`
- Quote: `[time, sym, bid, ask, bsize, asize, exchange]`
- OHLCV: `[date, time, sym, open, high, low, close, volume, vwap]`

## Integration Points

### kdb+ ↔ Elixir Communication
- Use IPC protocol with message serialization
- Connection pooling for scalability (5-10 connections planned)
- Handle compressed kdb+ responses and type conversion

### Real-time Broadcasting
- kdb+ subscriber pushes updates to Phoenix PubSub
- WebSocket channels filter and route messages to clients
- Rate limiting and backpressure handling required

## Key Files to Reference

- `devsped.md`: Complete specification and roadmap
- `kdb/tick/schema.q`: Data model definitions
- `kdb/run.sh`: Process startup/shutdown workflow
- `market_data/lib/market_data_web/router.ex`: API structure
- `docker-compose.yml`: Development infrastructure

## Performance Considerations

- kdb+ targets: <10ms query latency, 100k+ msg/sec ingest
- Elixir targets: <5ms WebSocket latency, 10k+ concurrent connections
- End-to-end: <20ms p99 from market data to client

## Testing Strategy

- Unit tests for Elixir modules (80%+ coverage target)
- Integration tests for kdb+ ↔ Elixir communication
- Load testing with k6/Locust for performance validation
- Data quality checks for timestamp ordering and calculations</content>
<parameter name="filePath">/Users/rcs/git/sdbp/.github/copilot-instructions.md