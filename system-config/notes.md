## Do analizy:
read_slurm_conf: backup_controller not specified??

debug:  No backup controllers, not launching heartbeat.?

Logging from the ResumeProgram/SuspendProgram scripts must be programmed in the scripts. This example may be used:
```
action="start"
echo "`date` User $USER invoked $action $0 $*" >>/var/log/slurm/power_save.log
```

W plikach /etc/pam.d/common-* znajdują się warningi, ostrzegające przed ich ręczną modyfikacją, gdyż zostanie ona nadpisana przez pam-config. Dopytać o to CS

## Żeby nie krzyczał, że nie może otworzyć skryptów:
  ```
  $ chmod a+rx /etc/slurm/slurm-resume.sh
  $ chmod a+rx /etc/slurm/slurm-suspend.sh
  $ chmod a+rx /etc/slurm/slurm-epilog.sh
```

do rozważenia - zamiast a+rx jakieś g+rx albo coś

## W slurm.conf zwrócić uwagę na parametry:
```
SlurmctldDebug=6
SlurmctldLogFile=/var/log/slurmctld.log
SlurmdDebug=6
SlurmdLogFile=/var/log/slurmd.log
```

im wyższa liczba tym więcej wiadomości debugu się loguje

The level of detail to provide slurmd daemon's logs.
Values from 0 to 9 are legal, with 0 being
"quiet" operation and 9 being insanely verbose. The
default value is 3. Each increment of the number generates about 5 times as many messages.

The DebugFlags configuration parameter can be used to enable
additional logging for specific SLURM sub-systems (e.g. Backfill,
CPU_Bind, Gres, Triggers, etc.)

https://slurm-dev.schedmd.narkive.com/wHoDrxll/debug-mode
