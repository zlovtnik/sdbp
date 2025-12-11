// feed.q - Feedhandler with test data generation
//
// Required dependencies:
// - tick/u.q: Utility functions for tickerplant operations
//   Location: Must be in QHOME directory or current working directory
//   Resolution: Searches QPATH environment variable, then current directory
//   Failure: Logs error and exits gracefully if not found or fails to load

\l tick/schema.q

// Robust loading of tick/u.q with error handling
loadTickUtils:{
  // Check if tick/u.q exists in search paths
  uFile:key hsym `$"tick/u.q";
  if[not count uFile;
    -2 "ERROR: tick/u.q not found in Q search path. Please ensure tick/u.q is available.";
    -2 "Searched paths: ", " " sv string getenv `QPATH;
    exit 1;
  ];

  // Attempt to load with error handling
  loadResult:@[system; "l tick/u.q"; {[err] -2 "ERROR: Failed to load tick/u.q - ", err; 0b}];
  if[not loadResult;
    -2 "ERROR: Failed to load tick/u.q. Check for syntax errors or missing dependencies.";
    exit 1;
  ];

  -1 "Successfully loaded tick/u.q";
 };

loadTickUtils[];

// Test data generation functions
generateTrade:{
  syms:`AAPL`GOOGL`MSFT`AMZN`TSLA;
  sym:syms[rand count syms];
  time:.z.p;
  price:100.0 + rand[200]%100.0;
  size:100*1+rand 1000;
  exchange:`NASDAQ;
  condition:`REGULAR;
  (time;sym;price;size;exchange;condition)
 };

generateQuote:{
  syms:`AAPL`GOOGL`MSFT`AMZN`TSLA;
  sym:syms[rand count syms];
  time:.z.p;
  spread:0.01 + rand[10]%100.0;
  mid:100.0 + rand[200]%100.0;
  bid:mid - spread%2;
  ask:mid + spread%2;
  bsize:100*1+rand 1000;
  asize:100*1+rand 1000;
  exchange:`NASDAQ;
  (time;sym;bid;ask;bsize;asize;exchange)
 };

// Connect to tickerplant with error handling
tickerplantHost:getenv `TICKERPLANT_HOST;
tickerplantPort:getenv `TICKERPLANT_PORT;
if[""=tickerplantHost; tickerplantHost:"localhost"];
if[""=tickerplantPort; tickerplantPort:"5010"];

connectToTickerplant:{
  hostport:`$":",tickerplantHost,":",tickerplantPort;
  h:@[hopen; hostport; {[err] -2 "ERROR: Failed to connect to tickerplant at ", string[hostport], " - ", err; 0Ni}];
  if[null h;
    -2 "ERROR: Could not establish connection to tickerplant. Please ensure tickerplant is running.";
    exit 1;
  ];
  -1 "Successfully connected to tickerplant at ", string[hostport];
  h
 };

h:connectToTickerplant[];

// Publish test data
publishData:{
  // Generate and publish trade
  tradeData:generateTrade[];
  h(`.u.upd;`trade;enlist tradeData);

  // Generate and publish quote
  quoteData:generateQuote[];
  h(`.u.upd;`quote;enlist quoteData);
 };

// Start publishing loop with error handling and logging
-1 "Initializing tickerplant utilities (.u.init)...";
initResult:@[.u.init;(); {[err] -2 "ERROR: Failed to initialize .u.init - ", err; 0b}];
if[initResult~0b;
  exit 1;
 ];
-1 "Successfully initialized .u.init";

-1 "Setting up tickerplant replay (.u.rep)...";
repResult:@[{.u.rep[]}; {[err] -2 "ERROR: Failed to setup .u.rep - ", err; 0b}; 0b];
if[repResult~0b;
  exit 1;
 ];
-1 "Successfully setup .u.rep";

.z.ts:{publishData[]};
\t 100;  // Timer every 100ms