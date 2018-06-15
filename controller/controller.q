// - Test idea for controller

// - These can be moved to config/settings

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
   "nohup q ${KDBCODE}/torq.q ",sv[" ";(,/:["-";string[key dict]],'" ",/:string[value dict]) where not null value dict], " </dev/null> /home/smurphy/deploy/logs/torq",string[dict`procname],".txt 2>&1 &"
  }each 0!.controller.procs;
  .controller.procs:.controller.procs,'([]cmd:cmds);
 };

.controller.boot:{ // Startup of system
  show "Starting up system";
  show .controller.procs[;`cmd] where 1b=.controller.procs[;`startwithall];
  // @[system;;{LOG FAILURE}] each .controller.procs[;`cmd] where 1b=.controller.procs[;`startwithall];
 };

/|--------------------------------------------------------------------------------------------------------------------|
/| -  Manipulation Functions                                                                                          |
/|--------------------------------------------------------------------------------------------------------------------|

.controller.startproc:{[dict]
  show .controller.procs[dict`procname;`cmd];
  // @[system;.controller.procs[dict`procname;`cmd];{LOG FAILURE}]
  };

.controller.kill:{[proc]
  // TODO (smur) Killing logic: Boot kill.q and use that? Potentially useless process to have now? 
  // hopen to process and kill?
  // use kill.q ? 
  show "Killing ",string[proc]
 };

// - This should: Check for downed processes, and try to restart if and only if startwithall=1b!

.controller.checkprocs:{
  / TODO (smur) Make windows equivalent 1. Check OS, set .controller.findprocs to either unix or windows command, logic should stay the same after this
  procs:system "ps -ef";
  `.controller.procstatus upsert {[procs;dict]
   i:where 1<=count each ss[;dict`cmd]each procs;
   $[0=count i;
    :(dict`procname;`DOWN;dict`startwithall;pid:"");
    :(dict`procname;`UP;dict`startwithall;vs[" ";first procs i] 1)
   ];
   }[procs;]each 0!.controller.procs;
  down:0!select from .controller.procstatus where status=`DOWN;
  if[not 0=count down;
   .controller.startproc each select from 0!.controller.procs where procname in down`procname, 1b=.controller.procs'[down`procname;`startwithall];
   ];
 }; 

.controller.updatestartflag:{[proc;flag]
  update startwithall:flag from `.controller.procs where procname=proc;
 };

.controller.stopproc:{[proc]
  .controller.updatestartflag[proc;0b];
  .controller.kill[proc];
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
 .controller.boot[];
 / TODO (smur) Replace with actual timer
 system "t 10000";
 .z.ts:{.controller.checkprocs[]}
 };
