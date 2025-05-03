# Wymagania do uruchomienia klastra slurm

## Należy mieć zainstalowane następujące paczki:
     autofs
     nss_ldap
     openldap2-client
     pam_ldap
     slurm
     slurm-munge
     slurm-pam_slurm
     sssd
     ipmitool
     
## Każdy komputer należący do klastra (w tym zarządca) muszą posiadać ten sam klucz munge
     Taki klucz można wygenerować za pomocą następującej komendy:
     $ dd if=/dev/random bs=1 count=1024 > /etc/munge/munge.key

     Po wygenerowaniu należy go rozpowszechnić na wszystkich komputerach klastra na przykład za pomocą takiej komendy:
     $ scp /etc/munge/munge.key other_host@/folder/with/config/files
    
## Aby skonfigurować node klastra:
     Należy pobrac archiwum system-config, przejsc do folderu, w ktorym sie znajduje, a nastepnie uruchomic skrypt konfiguracyjny
     $ sh setup.sh
     wymienia on potrzebne pliki na wersje z archiwum system-config.
     Należy obserwować wiadomości logu wyświetlane przez skrypt.
     Wprowadzone przez skrypt setup.sh zmiany dotyczące plików konfiguracyjnych można wycofać uruchamiając skryp
     $ sh rollback_setup.sh

## Na komputerze zarządcy należy ręcznie aktywować serwis slurmctld:
    $ systemctl enable slurmctld
