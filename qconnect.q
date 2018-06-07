\c 100 200
// - Load in config
.log.g:{[t;h;f;m] neg[h](sv["|";(string[.z.p];string[t];string[f];m)])}
.log.o:.log.g[`OUT;1;;];
.log.e:.log.g[`ERR;1;;];
o:.Q.def[`name`init`port!(`daemon;1b;10701)].Q.opt[.z.x];
history:([time:"p"$()]cmd:`$();status:`$();error:`$());
con:`$"::",string[o`port],":admin:admin";

// - Banner function
banner:{[x]
 w:120;
 wrap:{[w;x] show "|",(w#x),"|"}[w;];
 wrap each ("-";" ");
 show "|",#[floor[a];" "],x,#[ceiling a:%[w-count[x];2];" "],"|";
 wrap each (" ";"-");
 }
 
// - Input commands

input:()!();
input[`close]:{hclose h;.log.o[`PI;"Connection closed, exiting."];exit 0}
input[`history]:{show history}
input[`invalid]:{.log.o[`PI;"Command not allowed!!"];.s.s:`FAIL}
input[`size]:{[x] system "c ",sv[" ";1_vs[" ";-1_x]]}
input[`system]:{[x] show @[system;sv[" ";1_vs[" ";-1_x]];{.s.e:`$x;.log.e[`SYSTEM;"Error with system call: ",x];.s.s:`FAIL}]}
input[`request]:{[x] r:@[h;-1_x;{.s.e:`$x;.log.e[`IP;"Something went wrong, error: ",x];.s.s:`FAIL}];show r;}

// - Initialization function

initcon:{
 .log.o[`INIT;"Connect to ",string[o`name]," with credentials: ",string[con]];
 h::@[hopen;con;{[con;x] .log.e[`INIT;"Connection to ",string[con]," failed with error: ",x];:`FAIL}con];
 if[h~`FAIL;exit 0];
 .log.o[`INIT;"Connection successful!"];
 // - Set .z.po
 .z.po:{
  .log.o[`PO;"Connection on handle ",string[x]," has closed!"];
  / - TODO (smur) reconnection logic
  };
 // - Set .z.pi
 .z.pi:{
  .s.s:`OK;
  .s.e:`;
  $[any ~[-1_x;]each invalidcmds;
   input[`invalid][];
   any key[input] in a:`$first vs[" ";-1_x];
   input[a][x];
   input[`request][x]
  ];
  if[not ""~-1_x;`history insert (.z.p;`$-1_x;.s.s;.s.e)];
  };
 };
 
invalidcmds:("\\\\";"exit");
banner "Qconnect Version 1.0"
if[`~o`name;.log.e[`INIT;"User must specify procname"];exit 0];
if[o`init;initcon[]];
