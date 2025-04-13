# Wymagania do uruchomienia klastra slurm

## Na każdym komputerze - Należy mieć zainstalowane następujące paczki:
     autofs
     nss_ldap
     openldap2-client
     pam_ldap
     slurm
     slurm-munge
     slurm-pam_slurm
     sssd
     ipmitool

## Na komputerze zarządcy - Opcjonalnie można stworzyć następujące pliki. Będą one odczytywane przy starcie klastra:
    $ touch /var/lib/slurm/state/job_state.old
    $ touch /var/lib/slurm/state/job_state
    $ touch /var/lib/slurm/state/resv_state
    $ touch /var/lib/slurm/state/resv_state.old

## Na komputerze zarządcy - Należy stworzyć dla slurma biblioteki spool oraz state:
    $ mkdir -p /var/lib/slurm/{spool,state}
    $ chown -R slurm:slurm /var/lib/slurm

## Na każdym komputerze - Należy mieć zdefiniowaną grupy oraz userów slurm i munge:
    $ groupadd -r -g 149 munge
    $ useradd -r -u 149 -g munge -d /run/munge -s /bin/false -c "MUNGE authentication service" munge
     
    $ groupadd -r -g 148 slurm
    $ useradd -r -u 148 -g slurm -d /run/slurm -s /usr/bin/bash -c "SLURM workload manager" slurm

## Na każdym komputerze - Należy mieć ten sam klucz munge:
    $ dd if=/dev/random bs=1 count=1024 > /etc/munge/munge.key
    $ scp /etc/munge/munge.key other_host@/etc/munge/munge.key

## Na każdym komputerze - Należy aktywować serwisy slurmd i munge:
    $ systemctl enable munge
    $ systemctl enable slurmd
### Dodatkowo na komputerze zarządcy należy aktywować serwis slurmctld:
    $ systemctl enable slurmctld

## Na każdym komputerze - Należy włączyć serwisy munge i slurmd:
     $ systemctl start munge
     $ systemctl start slurmd

## Na komputerach zarządzanych - Należy uruchomić polecenie:
     $ slurmd -D -c -vv

## Na komputerze zarządcy - Należy uruchomić polecenie:
     $ slurmctld -D -c -vv

## Na każdym komputerze - Aby dokonać restartu i wymazać cache Slurma:
     $ rm -rf /var/lib/slurm/spool/*
