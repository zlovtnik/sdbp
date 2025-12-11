# kdb+ Tick Architecture Setup

This directory contains the kdb+ tick architecture implementation for the stock market data platform.

## Files

- `tick/tick.q` - Tickerplant (central hub, port 5010)
- `tick/r.q` - Real-time database (port 5011)
- `tick/h.q` - Historical database (port 5012)
- `tick/gateway.q` - Query gateway (port 5013)
- `tick/feed.q` - Feedhandler with test data generation (port 5009)
- `tick/schema.q` - Table schemas (trade, quote, ohlcv)
- `tick/u.q` - Standard tick utility functions
- `tick/sym.q` - Symbol enumeration
- `run.sh` - Startup script for all processes

## Architecture

```
Feedhandler → Tickerplant → RDB
    ↓            ↓
    └────────────┼─────────→ HDB
                 ↓
              Gateway
```

## Starting the System

1. Ensure kdb+ is installed and `q` is in your PATH
2. Run `./run.sh` to start all processes
3. Check logs in the `logs/` directory

## Ports

- Feedhandler: 5009
- Tickerplant: 5010
- RDB: 5011
- HDB: 5012
- Gateway: 5013

## Testing

Connect to any process using q:

```bash
q -p 5010  # Connect to tickerplant
```

Query data:

```q
select from trade where sym=`AAPL
select from quote where sym=`GOOGL
```
