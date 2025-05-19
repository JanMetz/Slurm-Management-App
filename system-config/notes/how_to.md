
## Aby przygotować komputer do bycia nodem:
- Zalogować się na komputer 
- Pobrać pliki configuracyjne
- Przejść do folderu do którego się pobrały
- Umieścić w niej klucz munge
- Uruchomić skrypt konfiguracyjny komendą ```sh setup.sh``` w trybie node
- UWAŻNIE PRZECZYTAĆ WYGENEROWANY PRZEZ SKRYPT OUTPUT
- Spróbować z innej konsoli połączyć się do komputera, żeby sprawdzić czy modyfikacja plików PAM nie wprowadziła niechcianych zmian
- W razie potrzeby wycofać zmiany skryptem ```rollback_setup.sh```

## Aby przygotować komputer do bycia zarządcą:
Podstawowe kroki konfiguracyjne są takie same jak dla nodea, tylko odpalając skrypt ```setup.sh``` należy odpalić go z argumentem master. Oprócz tego należy:
- Utworzyć cron job, który będzie odpalał skrypt czyszczący nodey po rezerwacji na zajęcia dydaktyczne:
  - wykonać komendę ```crontab -e```
  - dopisać do pliku crona linie:
  ```
  0 22 * * * /etc/slurm/post_reservation_cleanup.sh
  0 7 * * * /etc/slurm/create_reservation.sh
  ```

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
