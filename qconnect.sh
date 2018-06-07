LOGLEVEL=4
DEBUG='\003[0;34m'
ERROR='\003[0;31m'
WARN='\003[0;33m'
INFO='\003[0;32m'
DATA='\003[0;37m'
HLTD='\003[090;97m'

log_debug(){
 [ $LOGLEVEL -ge 4 ] && printf "${DATA}${date "+%Y/%m/%d %H:%M:%S"} ${DEBUG}DEBUG${DATA}: $* \n"
 }
log_error(){
 [ $LOGLEVEL -ge 3 ] && printf "${DATA}${date "+%Y/%m/%d %H:%M:%S"} ${ERROR}ERROR: $* ${DATA} \n"
 }
log_warn(){
 [ $LOGLEVEL -ge 2 ] && printf "${DATA}${date "+%Y/%m/%d %H:%M:%S"} ${WARN}WARN${DATA}: $* \n"
 }
log_info(){
 [ $LOGLEVEL -ge 1 ] && printf "${DATA}${date "+%Y/%m/%d %H:%M:%S"} ${INFO}INFO${DATA}: $* \n"
 }
 
qconnect(){
 [ "$2" == "" ] && user=$USER || user=$2;
 port=$(ps -ef | grep $user | grep $1 | grep -v grep | awk '{print $11}');
 count=$(wc <<<$port);
 if [[ "$port" = "" ]];then
  log_error "Failed to provide process name/type or process name/type not found";
  return 1;
 elif [[ "$count" -gt 1 ]];then
  log_info "Multiple processes found!"
  # Need a better way to view the processes
  echo $port
  log_info "Choose the port you would like to connect to: "
  read port;
  q qconnect.q -name ${1} -port ${port}
 else
  q qconnect.q -name ${1} -port ${port}
 }