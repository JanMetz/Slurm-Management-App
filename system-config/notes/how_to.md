
## Aby przygotować komputer do bycia nodem:
- Pobrać pliki configuracyjne
- Przejść do folderu do którego się pobrały
- Uruchomić skrypt konfiguracyjny komendą ```sh setup.sh```

## Aby zlecić zadanie testowe:
- Zalogować się na maszynę zarządcy, za pomocą swojego konta ldap ```ssh inf123456@lab-net-58```
- Wykonać komendę ```srun -n1 -l /bin/hostname```

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
