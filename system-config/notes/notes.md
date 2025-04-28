## Do analizy:

debug:  Not launching heartbeat.?

Logging from the ResumeProgram/SuspendProgram scripts must be programmed in the scripts. This example may be used:
```
action="start"
echo "`date` User $USER invoked $action $0 $*" >>/var/log/slurm/power_save.log
```

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

trzeba zmienic parametry startowe slurmd i slurmctld za pomocą 
```
systemctl edit slurmd
```
Trzeba dopisać
```
[Service]
ExecStart=
ExecStart=/usr/sbin/slurmd -D -c -vv
```
a następnie wykonać
```
systemctl daemon-reload
systemctl restart slurmd
```

## MeshCentral
mesh.cs.put.poznan.pl
Można się zalogować, wybrać z gruba rescue i naprawić np. pama jak coś pójdzie nie tak.

## Front
osobna! maszyna do logowania się i zlecania zadań - ma się odpalać nie vlab tylko jeden system, który będzie pozwalał się użytkownikowi zalogować i zlecać zadania

## TODO
przenieść repo git
naprawić setup.sh
skrypt do uruchomienia komputera - można wykorzystać wol adres:mac
po uruchomieniu kompa openssl do zarządcy z komunikatem że coś nie działa?

odapalanie maszyn (ping czy wgl maszyna jest widoczna)
sprawdzanie konfigu (czy działa sieć 10Gb enp1s0, jaki jest uruchomiony system)
jeżeli nie działa 10gb to można spróbować zrobić reset portu na switchu
odpalanie usług (usługi startowe)
odapalanie zadań - mozna w specyfikacji wezlow napisac dostepnosc od-do

lab-net-56 jest dopięte do switcha na porcie 39

sprawdzenie czy port na switchu działa snmpget -v2c -cpublic 192.168.0.239 ifOperStatus.39
ping6 ff02::1%enp1s0 -c2

przygootwanie systemu tylko do obliczeń, uruchomienie systemu tylko do obliczeń, zebranie danych diag z slurma

jak będzie wszystko działać to zintegrować to z meshem (komunikat na meshu że maszyna jest używana, albo ping do maszyny żeby slurm się zatrzymał, bo ktoś chce skorzystać z MC)
Przygotować harmonaogram - do czerwca z tekstem pracy

instrukcja obsługi (komendy, batche, etc)

zmienic z bashrc na /etc/profile.d

logowanie po ssh ma byc dostepne tylko dla zleceniodawcy zadania
jezeli nie ma w meshcentral opcji na powiadamianie o zajetosci maszyny to trzeba samemu dopisac
po uruchomieniu systemu tylko do obliczen ma sie pokazywac na ekranie wiadomosc o tym, ze system jest w trakcie uzywania (poszukac w manie do getty - /etc/issue)
dowiedziec sie czy ethers (odwzorowanie ip na mac) jest dostepne gdzies w ldapie

sprawdzic czy katalogi domowe sie poprawnie montuja
stworzyc osobny obraz dla systemu do obliczen
wylaczyc mozliwosc logowania po ssh dla osob, ktore nie sa ownerami zadania

na lab-net-56 zrobic resize images; na lab-net-57 mozna wykorzystac sdf5 - przy odwolywaniu sie do partycji uzywac labeli, a nie nazwy partycji /dev/disk/by/label
