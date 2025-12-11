// r.q - Real-time database
\l tick/schema.q
if[not "w"=first string .z.o;system "sleep 1"];
upd:insert;
.u.x:.z.x,(count .z.x)_(":5010";":5012");
.u.end:{
  t:tables`.;t@:where `g=attr each t@\:`sym;
  // Check if .u.x[1] looks like a host:port specification (contains exactly one colon and port is numeric)
  parts:":" vs .u.x[1];
  hdb_dest:$[1 = count parts;  // exactly one colon
    port:last parts;
    if[all port in .Q.n;  // port is numeric
      hopen `$ .u.x[1];  // raw host:port string
      // else treat as filesystem path
      `$.u.x[1]
    ];
    // else treat as filesystem path
    `$.u.x[1]
  ];
  .Q.hdpf[hdb_dest;`:.;x;`sym];
  @[;`sym;`g#] each t;
};
.u.rep:{
  (.[;();:;].)each x;
  if[null first y;:()];
  -11!y;
  // Extract directory path robustly by splitting on '/' and taking parent directory
  logPath:string first y;
  pathParts:"/" vs logPath;
  dir:"/" sv -1_pathParts;
  // Validate directory path against whitelist
  if[not dir ~/: .Q.a,.Q.A,"0123456789/\\-_.";
    -2 "ERROR: Invalid directory path characters in ",dir;
    :();
  ];
  system "cd ",dir;
};
.u.rep .[{
  h:hopen `$":",.u.x 0;
  if[null h;
    -2 "ERROR: Failed to connect to tickerplant at ",.u.x[0];
    exit 1;
  ];
  // Subscribe to all tables and get initial data
  subResult:h"(.u.sub[`;`];`.u `i`L)";
  if[not subResult~(::);
    -2 "ERROR: Failed to subscribe to tickerplant at ",.u.x[0];
    hclose h;
    exit 1;
  ];
  h
}; ::; {
  -2 "ERROR: Failed to connect to tickerplant at ",.u.x[0],": ",x;
  exit 1;
}];