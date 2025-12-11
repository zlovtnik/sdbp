// feed.q - Feedhandler
\l tick/feed.q

// Initialize tickerplant utilities with error handling
initResult:@[.u.init;();{[err]
  -2 "ERROR: Failed to initialize tickerplant utilities (.u.init) - ", err;
  -2 "Context: feed.q startup sequence";
  exit 1;
}];

if[initResult~0b;
  -2 "ERROR: .u.init returned failure status";
  exit 1;
];

-1 "Successfully initialized tickerplant utilities";