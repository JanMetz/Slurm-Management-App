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

## Opcjonalnie można stworzyć następujące pliki:
    $ touch /var/lib/slurm/state/job_state.old
    $ touch /var/lib/slurm/state/job_state
    $ touch /var/lib/slurm/state/resv_state
    $ touch /var/lib/slurm/state/resv_state.old

## Należy wykonać następujące polecenia:
    $ mkdir -p /var/lib/slurm/{spool,state}
    $ chown -R slurm:slurm /var/lib/slurm

## Należy mieć zdefiniowaną grupy oraz userów slurm i munge:
    $ groupadd -r -g 149 munge
    $ useradd -r -u 149 -g munge -d /run/munge -s /bin/false -c "MUNGE authentication service" munge
     
    $ groupadd -r -g 148 slurm
    $ useradd -r -u 148 -g slurm -d /run/slurm -s /usr/bin/bash -c "SLURM workload manager" slurm

## Oraz na wszystkich komputerach, należących do klastra mieć ten sam klucz munge:
    $ dd if=/dev/random bs=1 count=1024 > /etc/munge/munge.key
    $ scp /etc/munge/munge.key other_host@/etc/munge/munge.key
