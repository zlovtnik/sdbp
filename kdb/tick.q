// q tick.q sym . -p 5001 </dev/null >foo 2>&1 &
/2014.03.12 remove license check
/2013.09.05 warn on corrupt log
/2013.08.14 allow <endofday> when -u is set
/2012.11.09 use timestamp type rather than time. -19h/"t"/.z.Z -> -16h/"n"/.z.P
/2011.02.10 i->i,j to avoid duplicate data if subscription whilst data in buffer
/2009.07.30 ts day (and "d"$a instead of floor a)
/2008.09.09 .k -> .q, 2.4
/2008.02.03 tick/r.k allow no log
/2007.09.03 check one day flip
/2006.10.18 check type?
/2006.07.24 pub then log
/2006.02.09 fix(2005.11.28) .z.ts end-of-day
/2006.01.05 @[;`sym;`g#] in tick.k load
/2005.12.21 tick/r.k reset `g#sym
/2005.12.11 feed can send .u.endofday
/2005.11.28 zero-end-of-day
/2005.10.28 allow`time on incoming
/2005.10.10 zero latency
"kdb+tick 2.8 2014.03.12"
/q tick.q SRC [DST] [-p 5010] [-o h]

// Security: validate and sanitize src parameter to prevent path traversal
src:first .z.x

// Check for missing src parameter
if[0=count .z.x; -2 "src parameter is required"; exit 1];
if[null src; -2 "src parameter cannot be null"; exit 1];

// Only allow safe characters: alphanumerics, underscores, hyphens
if[not all src in .Q.a,.Q.A,"_-"; -2 "src parameter contains invalid characters"; exit 1];

// Prevent path traversal attacks
if[src like "*..*"; -2 "src parameter cannot contain path traversal"; exit 1];
if[src like "/*"; -2 "src parameter cannot be absolute path"; exit 1];

// Check that the corresponding sym.q file exists in tick directory
tickFile:`$":tick/",src,"sym.q";
if[0=count key tickFile; -2 "tick/",(string src),"sym.q file not found"; exit 1];

system"l tick/",(src,enlist"sym"),".q"

if[not system"p";system"p 5010"]
\l tick/u.q
\d .u
ld:{
  // Assign L to the sanitized symbol from the last 10 chars of current L plus x
  L::`$(-10_string L),string x;

  // Check if log file exists, create empty if not
  if[not type key L;
    .[L;();:;()]
  ];

  // Read the log file and assign to i and j
  i::j::-11!(-2;L);

  // Handle corrupt log case with better error reporting
  if[0<=type i;
    -2 (string L)," is a corrupt log. Last valid entry at position ",(string last i),". Consider truncating file manually.";
    '"Corrupt log file detected - manual intervention required"
  ];

  // Open and return the log file handle
  hopen L
};
tick:{init[];if[not min(`time`sym~2#key flip value@)each t;'`timesym];@[;`sym;`g#]each t;d::.z.D;if[l::count y;L::`$":",y,"/",x,10#".";l::ld d]};
endofday:{end d;d+:1;if[l;hclose l;l::.u.ld[d]]};
ts:{if[d<x;if[d<x-1;system"t 0";'"more than one day?"];endofday[]]};
if[system"t";
 .z.ts:{pub'[t;value each t];@[`.;t;@[;`sym;`g#]0#];i::j;ts .z.D};
 upd:{[t;x]
 if[not -16=type first first x;if[d<"d"$a:.z.P;.z.ts[]];a:"n"$a;x:$[0>type first x;a,x;(enlist(count first x)#a),x];
 t insert x;if[l;l enlist (`upd;t;x);j+:1];}];
if[not system"t";system"t 1000";
 .z.ts:{ts .z.D};
 upd:{[t;x]ts"d"$a:.z.P;
 if[not -16=type first first x;a:"n"$a;x:$[0>type first x;a,x;(enlist(count first x)#a),x];
 f:key flip value t;pub[t;$[0>type first x;enlist f!x;flip f!x]];if[l;l enlist (`upd;t;x);i+:1];}];
\d .
.u.tick[src;.z.x 1];
\
 globals used
 .u.w - dictionary of tables->(handle;syms)
 .u.i - msg count in log file
 .u.j - total msg count (log file plus those held in buffer)
 .u.t - table names
 .u.L - tp log filename, e.g. `:./sym2008.09.11
 .u.l - handle to tp log file
 .u.d - date
/test
>q tick.q
>q tick/ssl.q
/run
>q tick.q sym  .  -p 5010	/tick
>q tick/r.q :5010 -p 5011	/rdb
>q sym            -p 5012	/hdb
>q tick/ssl.q sym :5010		/feed