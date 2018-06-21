// - Test idea for controller

// - These can be moved to config/settings
.controller.IGNORELIST:`compression1;
.controller.procstatus:([procname:`$()]status:`$();start:();pid:())
.controller.BASEPORT:"I"$getenv[`KDBBASEPORT];

/|--------------------------------------------------------------------------------------------------------------------|
/| - Initialization Functions                                                                                         |
/|--------------------------------------------------------------------------------------------------------------------|

.controller.getprocs:{
  path:`$":",getenv[`KDBAPPCONFIG],"/process.csv";
  .controller.procs:1!`procname`proctype xcols ("SSSSSSSSSSbS";enlist",")0:path;
 };

.controller.updateports:{
  p:exec port from .controller.procs;
  ports:0^"I"$ssr[;"+";""] each ssr[;"{KDBBASEPORT}";""] each string p;
  update port:+'[.controller.BASEPORT;ports] from `.controller.procs;
 };

.controller.compilecmds:{
  cmds:{[dict]
   dict:`host`startwithall _ dict;
   ("nohup ";"q ",getenv[`TORQHOME],"/torq.q ",sv[" ";(,/:["-";string[key dict]],'" ",/:string[value dict]) where not null value dict];" </dev/null> /home/smurphy/deploy/logs/torq_",string[dict`procname],".txt 2>&1 &")
  }each 0!.controller.procs;
  cmds[;1]:{ssr[x;"${",string[y],"}";getenv[y]]}/[;`APPHOME`KDBHDB`KDBCODE`TORQHOME`KDBCONFIG`KDBAPPCODE`KDBAPPCONFIG]each cmds[;1];
  .controller.procs:.controller.procs,'([]cmd:cmds);
 };

.controller.boot:{ // Startup of system
  @[system;;{-2"Something went wrong and nothing started";}] each (,/) each .controller.procs[;`cmd] where 1b=.controller.procs[;`startwithall];
  .controller.checkprocs[];
 };

/|--------------------------------------------------------------------------------------------------------------------|
/| -  Manipulation Functions                                                                                          |
/|--------------------------------------------------------------------------------------------------------------------|

.controller.startproc:{[dict]
  .lg.o[`startproc;"Attempting to start process ",string[dict`procname]," with command:", cmd:(,/) .controller.procs[dict`procname;`cmd]];
  @[system;cmd;{.lg.o[`starproc;"Failed to start process."];}]
  };

.controller.softkill:{[proc]
 if[.controller.procstatus[proc;`status]~`UP;
   h:@[.servers.opencon;`$"::",string[.controller.procs[proc;`port]],":admin:admin";{.lg.o[`softkill;"Failed to connect to process, "x];}];
   @[h;"exit 0";{.lg.o[`softkill;"Failed to send exit code: ",x]}];
   hclose h;
  ];
 };
 
.controller.kill9:{[proc]
 @[system;"kill -9 ",.controller.procstatus[proc;`pid];{.lg.o[`kill9;"Failed to kill the process: ",x];}]
 };

.controller.shutdown:{
 .controller.updatestartflag[;0b] each exec procname from 0!.controller.procstatus;
 .controller.checkprocs[];
 .controller.stopproc each exec procname from .controller.procstatus where status=`UP;
 .controller.checkprocs[];
 if[count select from .controller.procstatus where status=`UP;exit 0]; 
 };

.controller.showlog:{[proc;f;n]
 show system "tail -n ",string[n]," ",getenv[`KDBLOG],"/",string[f],"_",string[proc],".log";
 };
.controller.showerr:.controller.showlog[;`err;5];
.controller.showout:.controller.showlog[;`out;10];
// - This should: Check for downed processes, and try to restart if and only if startwithall=1b!

.controller.checkprocs:{
  / TODO (smur) Make windows equivalent 1. Check OS, set .controller.findprocs to either unix or windows command, logic should stay the same after this
  procs:trim each system "ps -eo pid,cmd";
  `.controller.procstatus upsert {[procs;dict]
   i:where 1<=count each ss[;dict[`cmd] 1]each procs;
   $[0=count i;
    :(dict`procname;`DOWN;dict`startwithall;pid:"");
    :(dict`procname;`UP;dict`startwithall;first vs[" ";first procs i])
   ];
   }[procs;]each 0!.controller.procs;
  down:0!select from .controller.procstatus where status=`DOWN,start=1,not procname in .controller.IGNORELIST;
  if[not 0=count down;
   .lg.o[`checkprocs;"Procceses not started: "," " sv string exec procname from down];
   .controller.startproc each select procname from 0!.controller.procs where procname in down`procname, 1b=.controller.procs'[down`procname;`startwithall];
   ];
 }; 

.controller.updatestartflag:{[proc;flag]
  update startwithall:flag from `.controller.procs where procname=proc;
 };

.controller.stopproc:{[proc]
  .controller.updatestartflag[proc;0b];
  .controller.softkill[proc];
  .controller.checkprocs[];
 };

.controller.restartproc:{[proc]
  .controller.updatestartflag[proc;1b];
  .controller.checkprocs[];
 };

/|--------------------------------------------------------------------------------------------------------------------|
/| Function Definitions End                                                                                           |
/|--------------------------------------------------------------------------------------------------------------------|

init:{
 .controller.getprocs[];
 .controller.updateports[];
 .controller.compilecmds[];
 //.controller.boot[];
 / TODO (smur) Replace with actual timer
 system "t 2000";
 .z.ts:{.controller.checkprocs[]}
 };

