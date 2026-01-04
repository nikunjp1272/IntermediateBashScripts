# CFT is a proprietary file transfert tool, owned by Axway.
# It is installed on an EC2 using MFT load balancers on port 1761.
# The ITB/ines/engie implementation uses folders /transfert_nr/cft (nr for non regulated) ,
# on MFT filesystem, and share the same folders as MFT exchanges by symbolic links.


                        +-------------------+
                        |   Incoming Files  |
                        +-------------------+
                                 |
                                 v
                  +----------------------------------+
                  |  /transfert_nr/cft/IDFNAME/tmp  |
                  |  (temporary holding folder)     |
                  +----------------------------------+
                                 |
              +------------------+-------------------+
              |                                      |
              v                                      v
   +----------------------+              +----------------------+
   |   /in (reception)   |              |   /out (outgoing)    |
   +----------------------+              +----------------------+
              |                                      |
              v                                      v
   +----------------------+              +----------------------+
   |   /archive (store)   |              |   /archive_sortie    |
   +----------------------+              +----------------------+


# Checking for the CFT processes with ps:
ps -edf | grep -i cft
ps -edf | grep CFT

# these commands will return an output like this:
[xyz-ec2 ~]$ ps -edf | grep CFT
cft       3021  1282  0 14:00 pts/0    00:00:00 grep CFT
cft      11121     1  0 06:25 ?        00:00:00 CFTMAIN
cft      11173 11121  0 06:25 ?        00:00:00 CFTLOG
cft      11182 11121  0 06:25 ?        00:00:02 CFTTCOM
cft      11183 11121  0 06:25 ?        00:00:00 CFTPRX
cft      11187 11121  0 06:25 ?        00:00:00 CFTTPRO
cft      11188 11187  0 06:25 ?        00:00:01 CFTTCPS

# for different formatting
ps aux | grep -i cft
ps aux | grep CFT

# these commands will return an output like this:
[xyz-ec2 ~]$ ps aux|grep CFT
cft       3047  0.0  0.0 112820   956 pts/0    S+   14:01   0:00 grep CFT
cft      11121  0.0  2.9 121428 28980 ?        Ss   06:25   0:00 CFTMAIN
cft      11173  0.0  0.2 103484  2364 ?        S    06:25   0:00 CFTLOG
cft      11182  0.0  0.3 110864  3612 ?        S    06:25   0:02 CFTTCOM
cft      11183  0.0  0.2 115416  2124 ?        S    06:25   0:00 CFTPRX
cft      11187  0.0  1.4 119256 14396 ?        S    06:25   0:00 CFTTPRO
cft      11188  0.0  0.3 109576  3576 ?        S    06:25   0:01 CFTTCPS


# for only getting the PIDs and names of processes
pgrep -fl CFT

# this command will return an output like this:
[xyz-ec2 ~]$ pgrep -fl CFT
11121 CFTMAIN
11173 CFTLOG
11182 CFTTCOM
11183 CFTPRX
11187 CFTTPRO
11188 CFTTCPS


# for checking the status, starting, stopping or restarting of the cft service
service cft status
service cft start
service cft stop
service cft restart

# we can also use systemd commands 
systemctl status cft

# list of commands that can be used with 'service': start, stop, restart, try-restart, reload, force-reload, status

# this command will return an output like this:
[xyz-ec2 ~]# service cft status
Redirecting to /bin/systemctl status cft.service
● cft.service - Axway Transfer CFT
   Loaded: loaded (/etc/systemd/system/cft.service; enabled; vendor preset: disabled)
   Active: active (running) since Fri 2025-08-15 06:25:44 CEST; 7h ago
 Main PID: 11121 (CFTMAIN)
   CGroup: /system.slice/cft.service
           ├─11121 CFTMAIN
           ├─11173 CFTLOG
           ├─11182 CFTTCOM
           ├─11183 CFTPRX
           ├─11187 CFTTPRO
           └─11188 CFTTCPS

Aug 15 06:25:40 clip-devrec-cft-1-ec2.devrec-internal.com systemd[1]: Starting Axway Transfer CFT...
Aug 15 06:25:40 clip-devrec-cft-1-ec2.devrec-internal.com sh[11012]: Starting Transfer CFT...
Aug 15 06:25:41 clip-devrec-cft-1-ec2.devrec-internal.com sh[11012]: Starting Transfer CFT with IDPARM "IDPARM0"
Aug 15 06:25:41 clip-devrec-cft-1-ec2.devrec-internal.com sh[11012]: Transfer CFT Working Directory : /appli/cft/runtime
Aug 15 06:25:44 clip-devrec-cft-1-ec2.devrec-internal.com sh[11012]: [271B blob data]
Aug 15 06:25:44 clip-devrec-cft-1-ec2.devrec-internal.com sh[11012]: Transfer CFT started correctly.
Aug 15 06:25:44 clip-devrec-cft-1-ec2.devrec-internal.com systemd[1]: Started Axway Transfer CFT.


# print all environment variables
env | grep -i cft
env | grep CFT
printenv | grep CFT

# checking all variables in the current shell
set | grep CFT

# this command will return an output like this:
[xyz-ec2 ~]# env|grep CFT
CFTCHARSYMB=@
CFT_LFLAGS=-m64
CFTACCNT=/appli/cft/runtime/accnt/cftaccnt
CFTHINI=/appli/cft/runtime/conf/sec.ini
CFTDIRINSTALL=/softs/cft/home
CFTXIP_COMPONENT_PROPERTIES=/softs/cft/home/synInstall/synPatch/component.properties
ENV_CFT_LIBPATH=
CFTDIRRUNTIME=/appli/cft/runtime
CFTLOGA=/appli/cft/runtime/log/cftlog


# checking the path of the log file of CFT
ls $CFTLOGA $CFTLOG


# or directly open the log file form any path
vi $CFTLOG


# path to checking cftlog
# logs from around a month should be present in the directory
cat /appli/cft/runtime/log/cftlog


# checking the size of the cftlog file
du -sh $CFTLOG $CFTLOGA


# for checking any command that you can run with cftutil check the help to see what kind of commands you can run (it is like the man page for Axway CFT)
cftutil help


# to check all transfer catalog entries which are pending, in-progress, completed or errored
cftutil listcat

# to check records with an error
cftutil listcat state=error

# other fields we can filter the outputs by:
  Partner  DTSAPP File     Transfer         Records       Diags        Appli.   Appstate.
                  Id.      Id.       Transmit     Total   CFT Protocol Id.
  -------- ------ -------- -------- ---------- ---------- --- -------- -------- ---------
  SYMPHMP  SFX XX ITBPPS02 H1316385        402        402   0 CP NONE  9LI9I4OM
  ECS4PRD  SFX XX ITBPPR04 H1316443          2          2   0 CP NONE  9LIFO2L4

# the names of the columns can be put instead of state
idf = file ID
idt = transfer ID

# this command will return an output like this:
  SYMPHMP  RFX XX ITBPPS03 H1703333        908        908   0 CP NONE
  SYMPHMP  RFX XX ITBPPS03 H1703334        883        883   0 CP NONE
  SYMPHMP  RFX XX ITBPPS03 H1703335        907        907   0 CP NONE
  SYMPHMP  RFX XX ITBPPS03 H1703340        904        904   0 CP NONE
  SYMPHMP  RFX XX ITBPPS03 H1703341        923        923   0 CP NONE
  SYMPHMP  RFX XX ITBPPS03 H1703342        933        933   0 CP NONE
  SYMPHMP  RFX XX ITBPPS03 H1703343       1969       1969   0 CP NONE
  SYMPHMP  RFX XX ITBPPS03 H1703344       3284       3284   0 CP NONE
  SYMPHMP  RFX XX ITBPPS03 H1703345       3284       3284   0 CP NONE
  SYMPHMP  RFX XX ITBPPS03 H1703350       1381       1381   0 CP NONE

       645 record(s) selected
     10000 record(s) in Catalog file
      9355 record(s) free (93%)

CFTU00I LISTCAT  _ Correct ()


# checking stuck files
cftutil listcat state=WAIT


# checking the partner catalog
cftutil listpart

### Ines/EIT wrapper above CFT
#### folders
# wrappers are in /transfert*/ transfert or transfert_r or transfert_nr

 /transfert_nr/ines/cft_scripts
 /transfert_nr/ines/log
 /transfert_nr/cft/"IDFXXX"/log,conf,in,out,temp,archive,archive_sortie

# wrappers meaning scripts and logs related to the particular IDF
# inside each IDF this is the basic structure per directory
 log -> logging per IDF transfer
 conf -> config files per IDF
 in -> incoming files received from a partner or a system
 out -> outgoing files that are waiting to be sent
 temp -> temporary files during the transfer
 archive -> old completed files kept for reference
 archive_sortie -> archived sent files (sortie=output)


# All the files come-from or go-to /transfert and subfolders, subfolders are (option +/cft/) the IDF name
#### IDF naming
the IDF is usually composed of RRRPPSNN (example - ITB(RRR) RR(PP) R04(SNN))
 - RRR the reception owner : SYM ITB OCT
 - PP the platform RS(dev) RR(acc) PP(prd)
 - SNN the stream like S02 C11 DO1

#### folders path
When files arrive, they go to /transfert_nr/cft/IDFNAME/tmp ("just arrived" but not yet processed)
and after the transfert they go to /in for reception 
or /out for outgoing, then /archive, for sending.

### general path of file chronologically 
/tmp -> /in (or) /out -> /archive (or) /archive_sortie

                        +-------------------+
                        |   Incoming Files  |
                        +-------------------+
                                 |
                                 v
                  +----------------------------------+
                  |  /transfert_nr/cft/IDFNAME/tmp  |
                  |  (temporary holding folder)     |
                  +----------------------------------+
                                 |
              +------------------+-------------------+
              |                                      |
              v                                      v
   +----------------------+              +----------------------+
   |   /in (reception)   |              |   /out (outgoing)    |
   +----------------------+              +----------------------+
              |                                      |
              v                                      v
   +----------------------+              +----------------------+
   |   /archive (store)   |              |   /archive_sortie    |
   +----------------------+              +----------------------+

https://docs.axway.com/bundle/TransferCFT_39_UsersGuide_allOS_en_HTML5/page/Content/Troubleshooting/Messages_and_Codes/diagi_diagnostic_codes.htm



