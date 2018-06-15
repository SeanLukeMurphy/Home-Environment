// - Test idea for controller

.controller.procstatus:([procname:`$()]status:`$();pid:())
.controller.BASEPORT:"I"$getenv[`KDBBASEPORT];

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
 -1 "Starting up system";
 show .controller.procs[;`cmd] where 1b=.controller.procs[;`startwithall];
 }

.controller.startproc:{[dict]
 $[.controller.procs[dict`procname;`startwithall];
  show .controller.procs[dict`procname;`cmd];
  -1"WELL I TRIED DIDN'T I"
 ]
 }

.controller.checkprocs:{[retry]
 / TODO (smur) Make windows equivalent 1. Check OS, set .controller.findprocs to either unix or windows command, logic should stay the same after this
 procs:system "ps -ef";
 `.controller.procstatus upsert {[procs;dict]
  i:where 1<=count each ss[;dict`cmd]each procs;
  $[0=count i;
   :(dict`procname;`DOWN;pid:"");
   :(dict`procname;`UP;vs[" ";first procs i] 1)
  ];
  }[procs;]each 0!.controller.procs;
 down:0!select from .controller.procstatus where status=`DOWN;
 if[not 0=count down;
  $[retry;
  .controller.startproc each down;
  -1"Procs are down but I'm not restarting them."
   ]
  ];
 }; 

.controller.stopproc:{[proc]
  update startwithall:0b from `.controller.procs where procname=proc
 }


init:{
 .controller.getprocs[];
 // - Used in torq.sh but not necessary this controller.
 .controller.updateports[];
 .controller.compilecmds[];
 .controller.boot[];
 / TODO (smur) Replace with TorQ timer
 system "t 10000";
 .z.ts:{.controller.checkprocs[1b]}
 };
