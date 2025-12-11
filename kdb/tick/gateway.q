// gateway.q - Gateway
\l tick/schema.q

// Robust loading of tick/u.q with error handling
loadTickUtils:{
  // Attempt to load with error handling
  loadResult:@[{{system "l tick/u.q"; 1b}}; {[err] -2 "ERROR: Failed to load tick/u.q - ", err; 0b}; ()];
  if[not loadResult;
    -2 "ERROR: Failed to load tick/u.q. Check for syntax errors or missing dependencies.";
    exit 1;
  ];

  -1 "Successfully loaded tick/u.q";
};

loadTickUtils[];

// Configuration: enable replay for gateways that need historical data replay
// Set replayEnabled:1b to replay tickerplant log on startup (increases memory/time)
// Default: 0b (live updates only) - suitable for most gateway use cases
replayEnabled:0b;

.u.init[];
if[replayEnabled;.u.rep[]];