// h.q - Historical database
\l tick/schema.q
if[not "w"=first string .z.o;system "sleep 1"];
upd:insert;
.u.x:.z.x,(count .z.x)_(":5010";":5012");
.u.end:{
  t:tables`.;t@:where `g=attr each t@\:`sym;
  // Check if .u.x[1] looks like a host:port specification (contains exactly one colon)
  hdb_dest:$[.u.x[1] like "*:*";
    // If it looks like host:port, open a socket handle
    hopen `$":",.u.x[1];
    // Otherwise treat as filesystem path
    `$.u.x[1]
  ];
  .Q.hdpf[hdb_dest;`:.;x;`sym];
  @[;`sym;`g#] each t;
};
.u.rep:{
  @[{(.[;();:;].)each x}; x; {'"Failed to apply replay data: ",x}];
  if[null first y;:()];
  @[-11!; y; {'"Failed to deserialize log: ",x}];
  // Extract directory path robustly by splitting on '/' and taking parent directory
  logPath:string first y;
  pathParts:"/" vs logPath;
  dir:"/" sv -1_pathParts;
  // Validate directory path against whitelist
  if[not dir ~/: .Q.a,.Q.A,"0123456789/\\-_.";
    -2 "ERROR: Invalid directory path characters in ",dir;
    :();
  ];
  @[system; "cd ",dir; {'"Failed to change directory to ",dir," - ",x}]
  };
.u.rep .@[{(hopen `$":",.u.x 0)"(.u.sub[`;`];`.u `i`L)"}; ::; {'"Failed to connect to tickerplant at ",.u.x[0],": ",x}];