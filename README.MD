# Custom tools

## Qconnect

### qconnect:

Script that connects to a running q process and simulates running the process in the foreground.

Inputs:

- name : name of process
- port : port number process is running on

Example:
```
q qconnect.q -name rdb -port 10500
```
### run.sh

Script that takes in process name and user name and searches through users processes to find correct port to connect to via qconnect.q

Inputs:

- procces name
- user

Example:
```
. run.sh rdb $USER
```
