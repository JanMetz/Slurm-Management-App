## TODO
1) wybór odpowiedniego systemu (reset AMT -> logowanie admin ssh -> grub2-once)
2) komunikat na meshu
3) udostępnić dane o zajętości maszyn publicznie; dane zawierające nazwę użytkownika mają być dostępne dopiero po logowaniu
4) Poprosić CS o możliwość logowania na maszyny przez vlab
5) poprosić CS o możliwość wywoływania poleceń amt (potrzebne jest hasło, ale możnaby zrobić możliwość wykonywania polecenia zdalnie przez np serwer meshcentral, który by doklejał dla uprawnionych użytkowników hasło tak, żeby mogli wykonać polecenie)
6) wysyłanie danych z mysql do influxa
7) sprawdzenie konfiguracji mysqla - czy nodey same mają wysyłać dane?

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

## Notes
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

```
sacct --format=jobid,jobname,user,ncpus,avecpu,reqmem,averss,avevmsize,avediskread,avediskwrite,elapsed
sacct --format=user,usercpu,reqcpus,reqmem,reqnodes,maxvmsize,avediskread,avediskwrite
```

ogólne dane o zajętości maszyn mają być publiczne; dane zawierające nazwę użytkownika mają być dostępne dopiero po logowaniu

nie powinno wywalić wszystkich połączeń po ssh do danego nodea; nie powinno być kill wszystkich procesów, tylko tych, które jako JOB_ID mają odpowiednią wartość

sprawdzić czy rezerwacja będzie uniemożliwiała rozpoczęcie pracy dłuższej niż ilość pozostałego czasu - przełączyć tworzenie rezerwacji na następny dzień

musi być montowanie katalogów domowych polluksa przy połączeniu przez ssh

brak możliwości zamonotwania katalogu, jeżeli jądro nie wspiera nfsa

zainstalować certyfikaty ca-certificates z poziomu chroota

przydały by się też certy dla ldapa...

./meshcmd amtpower --host lab-net-57 --password PWD --bootmode 3 --bootdevice 0  --bootname "Windows Boot Manager HD" --restart
./meshcmd amtpower --host lab-net-57 --password PWD --restart

umieścić w pracy wpis 'future works' opisujący że możnaby dodać killowanie sesji ssh powiązanych z konkretnym zadaniem po jego zakończeniu.

przenieść OS na sda1

sprawdzić czy da się wybrać OS przez amttool

skrócić link do grafany http://lab-net-58:3000/public-dashboards/0bc4135c59f74abda318f78c34d1b1ae?orgId=1

dodać do dashboarda informację o ilości zadań aktualnie wykonywanych na nodzie

tune2fs -L primary2 /dev/sdb1

## Aby zlecić zadanie testowe:
- Zalogować się na maszynę zarządcy, za pomocą swojego konta ldap ```ssh inf123456@lab-net-58```
- Wykonać komendę ```srun -n1 -l /bin/hostname```

## Aby dokonać restartu i wymazać cache Slurma:
     $ rm -rf /var/lib/slurm/spool/*

## Aby zmienić stan nodea:
     $ scontrol update nodename=lab-net-57 state=resume


## Instalacja OS od zera na nowej partycji, z poziomu działającego systemu linux
```
#resize partycji IMAGES i stworzenie partycji pod nowy system
parted /dev/sdX
(parted) > resizepart idx XXXGB #idx to indeks partycji IMAGES, XXX to jej nowy KONIEC - NIE NOWY ROZMIAR! 
(parted) > mkpart ext4 XXXGB XXX+50GB
(parted) > quit
e2fsck -f /dev/sdX
resize2fs /dev/sdX
mkfs.ext4 /dev/sdXY -L SLURM #gdzie Y to numer porządkowy nowo utworzonej partycji

#zamontowanie nowej partycji oraz potrzebnych do instalacji systemu katalogów
mount /dev/sdX2 /mnt
mount --bind /dev /mnt/dev
mount --bind /proc /mnt/proc
mount --bind /sys /mnt/sys
mount --bind /run /mnt/run
mkdir /mnt/boot/efi
mount /dev/sdY1 /mnt/boot/efi  # sdY1 to partycja EFI

#pobranie i instalacja systemu oraz najpotrzebniejszych bibliotek
zypper --root /mnt ar http://download.opensuse.org/distribution/leap/15.6/repo/oss/ main
zypper --root /mnt refresh
zypper --root /mnt install --no-recommends bash coreutils glibc zypper rpm filesystem vim \
ca-certificates coreutils glibc-locale openssh wicked dhcp_client sssd shim kernel-default \
ca-certificates-mozilla timezone grub2

#konfiguracja systemu
chroot /mnt

echo -e "search cs.put.poznan.pl
nameserver 150.254.30.30
nameserver 150.254.5.4
nameserver 150.254.5.11" > etc/resolv.conf

echo -e "BOOTPROTO='dhcp'
STARTMODE='hotplug'
ETHTOOL_OPTIONS='wol g'" >  /etc/sysconfig/network/ifcfg-eth0

#upewnić się, że urządzenie o adresie ATTR{address}=="18:66:da:22:f0:XX" jest określone jako eth0 w pliku /etc/udev/rules.d/70-persistent-net.rules

echo -e 'GRUB_DISABLE_OS_PROBER="false"
GRUB_TERMINAL="console"
GRUB_TIMEOUT="6"
GRUB_ENABLE_CRYPTODISK="n"
GRUB_GFXMODE="auto"
GRUB_DISABLE_RECOVERY="true"
GRUB_DISTRIBUTOR=
GRUB_DEFAULT="saved"
SUSE_BTRFS_SNAPSHOT_BOOTING="false"
GRUB_HIDDEN_TIMEOUT="0"
GRUB_CMDLINE_LINUX_DEFAULT="console=ttyS4,115200n8 preempt=full mitigations=auto quiet"
GRUB_CMDLINE_XEN_DEFAULT="vga=gfx-1024x768x16"
GRUB_BACKGROUND=
GRUB_THEME=/boot/grub2/themes/openSUSE/theme.txt' > /etc/default/grub

echo -e 'LOADER_TYPE="grub2"
SECURE_BOOT="no"
TRUSTED_BOOT="no"
UPDATE_NVRAM="yes"' > /etc/sysconfig/bootloader

echo -e 'menuentry "SLURM compute node" {
  load_video
  set gfxpayload=keep
  insmod gzio
  insmod part_gpt
  insmod ext2
  search --label --set=root SLURM
  linux  /boot/vmlinuz root=/dev/disk/by-label/SLURM quiet splash=silent reboot=pci fastrestore quiet
  initrd /boot/initrd
}' >> /boot/grub2/grub.cfg

echo -e "LABEL=SLURM   /   ext4    defaults  0 0
LABEL=EFI     /boot/efi  vfat  nofail,umask=0002,utf8=true  0  0" > /etc/fstab

grub2-once --list # tu musi się pojawić działający system! inaczej czeka nas commandline gruba i naprawianie po ponownym uruchomieniu systemu

systemctl enable wickedd
systemctl enable wicked
systemctl enable sshd
update-ca-certificates
passwd
timedatectl set-ntp true
timedatectl set-timezone Europe/Warsaw
exit

#odmontowanie nowego systemu i restart komputera ze wskazaniem na ten nowy system 
umount -R /mnt
grub2-once --list
grub2-once X #gdzie jako X wstawiamy numer porządkowy, pod którym znajduje się system 'SLURM compute node'
reboot
```

grub - console mode (warto zapamiętać na jakim dysku i na jakiej partycji znajduje się działający system w razie gdyby coś poszło nie tak)
```
ls
ls (hd5,gpt2)/boot

set root=(hd5,gpt2)
linux /boot/vmlinuz-6.4.0-150600.23.47-default
initrd /boot/initrd-6.4.0-150600.23.47-default
boot
```
