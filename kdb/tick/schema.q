// schema.q - Table schemas for tick architecture
\d .schema

// Trade table schema
trade:([]
  time:`s#timestamp$();     // Nanosecond timestamp
  sym:`g#symbol$();         // Stock symbol
  price:`float$();        // Trade price
  size:`long$();          // Trade size
  exchange:`symbol$();    // Exchange code
  condition:`symbol$()    // Trade condition
);

// Quote table schema
quote:([]
  time:`s#timestamp$();
  sym:`g#symbol$();
  bid:`float$();          // Best bid price
  ask:`float$();          // Best ask price
  bsize:`long$();         // Bid size
  asize:`long$();         // Ask size
  exchange:`symbol$()
);

// OHLCV bars schema (1min, 5min, 1hour, daily)
ohlcv:([]
  date:`date$();
  time:`timestamp$();
  sym:`symbol$();
  open:`float$();
  high:`float$();
  low:`float$();
  close:`float$();
  volume:`long$();
  vwap:`float$()          // Volume-weighted average price
);