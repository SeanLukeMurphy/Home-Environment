// - Test idea for controller

.controller.procstatus:([procname:`$()]status:`$();pid:())

.controller.BASEPORT:"I"$getenv[`KDBBASEPORT];

.controller.getprocs:{
 path:`$":",getenv[`KDBAPPCONFIG],"/process.csv";
        .controller.procs:1!`procname`proctype xcols ("SSSSSSSSSSSS";enlist",")0:path;
 };

.controller.updateports:{
 p:exec port from .controller.procs;
 ports:0^"I"$ssr[;"+";""] each ssr[;"{KDBBASEPORT}";""] each string p;
 update port:+'[.controller.BASEPORT;ports] from `.controller.procs;
 };

.controller.compilecmds:{
 cmds:{[dict]
  "nohup q ${KDBCODE}/torq.q ",sv[" ";(,/:["-";string[key dict]],'" ",/:string[value dict]) where not null value dict], " </dev/null> /home/smurphy/deploy/logs/torq",string[dict`procname],".txt 2>&1 &"
 }each 0!.controller.procs;
 .controller.procs:.controller.procs,'([]cmd:cmds);
 };

.controller.boot:{ // Startup of system
 // - Start up each process
 // - Start timer for checks
 }

.controller.retrystart:{[dict]
 show .controller.procs[dict`procname;`cmd];
 }

.controller.checkprocs:{
 / TODO (smur) Make windows equivalent 1. Check OS, set .controller.findprocs to either unix or windows command, logic should stay the same after this
 procs:system "ps -ef";
 `.controller.procstatus upsert {[procs;dict]
  i:where 1<=count each ss[;dict`cmd]each procs;
  $[0=count i;
   :(dict`procname;`FAIL;pid:"");
   :(dict`procname;`OK;vs[" ";procs i] 1)
  ];
  }[procs;]each 0!.controller.procs;
 .controller.retrystart each 0!select from .controller.procstatus where status=`FAIL;
 }

init:{
 .controller.getprocs[];
 delete startwithall from `.controller.procs;
 .controller.updateports[];
 .controller.compilecmds[];
 system "t 5000";
 .z.ts:{.controller.checkprocs[]}
 };


