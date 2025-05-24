# Wymagania do uruchomienia klastra slurm

## Na każdym komputerze należy mieć zainstalowane następujące paczki:
     autofs
     nss_ldap
     openldap2-client
     pam_ldap
     slurm
     slurm-munge
     slurm-pam_slurm
     sssd

## Na komputrze zarządcy należy dodatkowo zainstalować następujące paczki:
     influxdb
     mariadb
     grafana-server
     
## Każdy komputer należący do klastra (w tym zarządca) muszą posiadać ten sam klucz munge
     Taki klucz można wygenerować za pomocą następującej komendy:
     $ dd if=/dev/random bs=1 count=1024 > /etc/munge/munge.key

     Po wygenerowaniu należy go rozpowszechnić na wszystkich komputerach klastra na przykład za pomocą takiej komendy:
     $ scp /etc/munge/munge.key other_host@/folder/with/config/files
