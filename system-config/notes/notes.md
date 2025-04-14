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

## Munge key
Kopiowanie przez scp może się nie udać, jeżeli z maszyny-celu nie robiło się wcześniej ssh (nie zakceptowało się fingerprinta) do maszyny-źródła.
Po skopiowaniu trzeba zmienić ownera, bo inaczej munge nie chce wystartować. 
```
  $ chown 149:149 /etc/munge/munge.key
```

## Problemy z nodem po restarcie
```
  $ sinfo
  $ sinfo -R
  $ scontrol update nodename=lab-net-57 state=resume
```

## MeshCentral
mesh.cs.put.poznan.pl
Można się zalogować, wybrać z gruba rescue i naprawić np. pama jak coś pójdzie nie tak.

## Front
osobna! maszyna do logowania się i zlecania zadań - ma się odpalać nie vlab tylko jeden system, który będzie pozwalał się użytkownikowi zalogować i zlecać zadania

## Git 
przenieść repo 

## Skrypt
do uruchomienia komputera

odapalanie maszyn (ping czy wgl maszyna jest widoczna)
sprawdzanie konfigu (czy działa sieć 10Gb enp1s0, jaki jest uruchomiony system)
jeżeli nie działa 10gb to można spróbować zrobić reset portu na switchu
odpalanie usług (usługi startowe)
odapalanie zadań (cron) 

lab-net-56 jest dopięte do switcha na porcie 39

sprawdzenie czy port na switchu działa snmpget -v2c -cpublic 192.168.0.239 ifOperStatus.39

przygootwanie systemu tylko do obliczeń, uruchomienie systemu tylko do obliczeń, zebranie danych diag z slurma

jak będzie wszystko działać to zintegrować to z meshem (komunikat na meshu że maszyna jest używana, albo ping do maszyny żeby slurm się zatrzymał, bo ktoś chce skorzystać z MC)
Przygotować harmonaogram - do czerwca z tekstem pracy
