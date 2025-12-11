\d .u
init:{w::t!(count t::tables`.)#()}
del:{w[x]_:w[x;;0]?y};prevpc:.z.pc;.z.pc:{del[;x]each t;if[not null prevpc;prevpc x]}
sel:{$[`~y;x;select from x where sym in y]}
pub:{[t;x]{[t;x;w]if[count x:sel[x]w 1;(neg first w)(`upd;t;x)]}[t;x]each w t}
add:{$[(count w x)>i:w[x;;0]?.z.w;.[`.u.w;(x;i;1);union;y];w[x],:enlist(.z.w;y)];(x;$[99=type v:value x;sel[v]y;@[0#v;`sym;`g#]])}
sub:{if[x~`;:sub[;y]each t];if[not x in t;'x];del[x].z.w;add[x;y]}
end:{if[count handles:distinct raze w[;;0];(neg handles)@\:(`.u.end;x);()]}