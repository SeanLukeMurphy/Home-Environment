/Test idea for controller

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
  "nohup q ${KDBCODE}/torq.q ",sv[" ";(,/:["-";string[key[dict]]],'" ",/:string[value dict]) where not null value dict], " </dev/null> /home/smurphy/deploy/logs/torq",string[dict`procname],".txt 2>&1 &"
 }each 0!.controller.procs; 
 .controller.procs:.controller.procs,'([]cmd:cmds);
 };

.controller.boot:{ // Startup of system
 // - Start up each process
 // - Start timer for checks
 }

.controller.checkprocs:{
 // - Check ps -ef for your proccess running
 // - If its not try and start instance
 }

// NEED ANOTHER TABLE WITH PROCESS STATUSES

init:{
 .controller.getprocs[];
 delete startwithall from `.controller.procs;
 .controller.updateports[];
 .controller.compilecmds[];
 };

