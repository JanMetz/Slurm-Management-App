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
     
## Należy mieć ten sam klucz munge:
    $ dd if=/dev/random bs=1 count=1024 > /etc/munge/munge.key
    $ scp /etc/munge/munge.key other_host@/folder/with/config/files
    
## Aby skonfigurować node klastra:
     # sh setup.sh

## Na komputerze zarządcy należy aktywować serwis slurmctld:
    $ systemctl enable slurmctld

## Należy włączyć serwisy munge i slurmd:
     $ systemctl start munge
     $ systemctl start slurmd
