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

## Rezerwacje
Nie należy korzystać z rezerwacji z flagą DAILY, ponieważ powoduje ona zablokowanie dostępu do zasobów NAWET POZA wyznaczonym okresem. Co więcej, to nie bug, to feature :))) Problem uniemożliwienia korzystania z nodeów w czasie zajęć dydaktycznych należy rozwiązać korzystając z crona,
który będzie codziennie odpalał rezerwację na określone godziny.

## Zlecanie zadań
Zlecając zadania za pomocą sbatch należy określić ich zapotrzebowanie na zasoby oraz limit czasowy. Ponadto, można określić pliki, do których trafią wyniki działania skryptu. Przykładowy nagłówek skryptu:
```
#!/bin/bash
#SBATCH --job-name=NAME
#SBATCH --output=/tmp/job.out
#SBATCH --error=/tmp/job.err
#SBATCH --time=00:02:00
#SBATCH --ntasks=1
#SBATCH --mincpus=1
#SBATCH --mem=100M
```

## MeshCentral
mesh.cs.put.poznan.pl
Można się zalogować, wybrać z gruba rescue i naprawić np. pama jak coś pójdzie nie tak.

## TODO
w slurm.conf node musi miec taka sama liste jak partycja - inaczej daemon nie dziala i krzyczy ze lookup failure 

odapalanie maszyn (ping czy wgl maszyna jest widoczna)
sprawdzanie konfigu (czy działa sieć 10Gb enp1s0, jaki jest uruchomiony system)
jeżeli nie działa 10gb to można spróbować zrobić reset portu na switchu
odpalanie usług (usługi startowe)
odapalanie zadań - mozna w specyfikacji wezlow napisac dostepnosc od-do

lab-net-56 jest dopięte do switcha na porcie 39

sprawdzenie czy port na switchu działa snmpget -v2c -cpublic 192.168.0.239 ifOperStatus.39
ping6 ff02::1%enp1s0 -c2

przygotowanie systemu tylko do obliczeń, uruchomienie systemu tylko do obliczeń, zebranie danych diag z slurma

jak będzie wszystko działać to zintegrować to z meshem (komunikat na meshu że maszyna jest używana, albo ping do maszyny żeby slurm się zatrzymał, bo ktoś chce skorzystać z MC)
Przygotować harmonogram - do czerwca z tekstem pracy

instrukcja obsługi (komendy, batche, etc)

zmienic z bashrc na /etc/profile.d

logowanie po ssh ma byc dostepne tylko dla zleceniodawcy zadania
jezeli nie ma w meshcentral opcji na powiadamianie o zajetosci maszyny to trzeba samemu dopisac
po uruchomieniu systemu tylko do obliczen ma sie pokazywac na ekranie wiadomosc o tym, ze system jest w trakcie uzywania (poszukac w manie do getty - /etc/issue)

sprawdzic czy katalogi domowe sie poprawnie montuja
stworzyc osobny obraz dla systutofsemu do obliczen
wylaczyc mozliwosc logowania po ssh dla osob, ktore nie sa ownerami zadania - zapytac o pam_slurm_adopt

na lab-net-56 zrobic resize images; na lab-net-57 mozna wykorzystac sdf5 - przy odwolywaniu sie do partycji uzywac labeli, a nie nazwy partycji /dev/disk/by/label

musi byc dostepne logowanie po ldapie

czy rezerwacja zostanie zerwana jezeli ktorys z komputerow nie bedzie dostepny

czy da sie wywalic uzytkownika po ssh po zakoczeniu zadania slurm - tak, wstawiając odpowiedni wpis w epilogu

zrobic weryfikacje zuzywanych zasobow

sacct --format=jobid,jobname,user,ncpus,avecpu,reqmem,averss,avevmsize,avediskread,avediskwrite,elapsed

ogólne dane o zajętości maszyn mają być publiczne; dane zawierające nazwę użytkownika mają być dostępne dopiero po logowaniu

nie powinno wywalić wszystkich połączeń po ssh do danego nodea; nie powinno być kill wszystkich procesów, tylko tych, które jako JOB_ID mają odpowiednią wartość

sprawdzić czy rezerwacja będzie uniemożliwiała rozpoczęcie pracy dłuższej niż ilość pozostałego czasu - przełączyć tworzenie rezerwacji na następny dzień

musi być montowanie katalogów domowych polluksa przy połączeniu przez ssh

brak możliwości zamonotwania katalogu, jeżeli jądro nie wspiera nfsa

zainstalować certyfikaty ca-certificates z poziomu chroota

przydały by się też certy dla ldapa...

## Aby zlecić zadanie testowe:
- Zalogować się na maszynę zarządcy, za pomocą swojego konta ldap ```ssh inf123456@lab-net-58```
- Wykonać komendę ```srun -n1 -l /bin/hostname```

## Aby dokonać restartu i wymazać cache Slurma:
     $ rm -rf /var/lib/slurm/spool/*

## Aby zmienić stan nodea:
     $ scontrol update nodename=lab-net-57 state=resume
