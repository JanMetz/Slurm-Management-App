
## Aby uruchomić daemona slurma na komputerach zarządzanych:
     $ slurmd -D -c -vv

## Aby uruchomić daemona slurma na komputerze zarządcy:
     $ slurmctld -D -c -vv

## Aby zlecić zadanie testowe:
     $ srun -n1 -l /bin/hostname

## Aby dokonać restartu i wymazać cache Slurma:
     $ rm -rf /var/lib/slurm/spool/*

## Aby sprawdzić stan nodeów:
     $ sinfo
     $ sinfo -R

## Aby zmienić stan nodea:
     $ scontrol update nodename=lab-net-57 state=resume

## Aby wyłączyć Slurm:
     $ systemctl stop slurmd
     $ ps aux | grep slurm
     $ kill -9 pid
Wg dokumentacj: 
    "SIGINT SIGTERM SIGQUIT
    slurmstepd will shutdown cleanly." 
