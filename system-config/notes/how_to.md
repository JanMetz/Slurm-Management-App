# Wymagania do uruchomienia klastra slurm
  
## Klucz munge:
Każdy komputer należący do klastra (w tym zarządca) muszą posiadać ten sam klucz munge - służy on do uwierzytelniania i jest niezbędny do prawidłowego działania klastra.

Taki klucz można wygenerować za pomocą następującej komendy: ```dd if=/dev/random bs=1 count=1024 > /etc/munge/munge.key```

Po wygenerowaniu należy go rozpowszechnić na wszystkich komputerach klastra, na przykład za pomocą takiej komendy:  ```scp /etc/munge/munge.key other_host@/folder/with/config/files``` 
zastępując nazwę hosta oraz ścieżkę do folderu poprawnymi wartościami.
     
## Przygotowanie komputera do bycia nodem:
### Potrzebne paczki
Należy zainstalować potrzebne paczki następującą komendą:
```
zypper install --no-recommends autofs nss_ldap openldap2-client pam_ldap slurm \
slurm-munge slurm-pam_slurm sssd pmix pmix-devel nfs-utils
```
Można to zrobić korzystając z zyppera - polecenie ```zypper install <nazwa_paczki>```
     
### Konfiguracja
Aby dokonać konfiguracji komputera można wykorzystać skrypt konfiguracyjny setup.sh, który automatycznie wykona praktycznie całość potrzebnej konfiguracji dla node'a.
W tym celu należy:
- Zalogować się na komputer jako konto z uprawnieniami administratora
- Pobrać z repozytorium pliki konfiguracyjne, znajdujące się w folderze system-config
- Przejść do miejsca na dysku, do którego pobraliśmy folder system-config
- Umieścić w nim klucz munge (np. za pomocą polecenia scp, lub generując nowy klucz - patrz wyżej, rozdział 'Klucz munge')
- Uruchomić skrypt konfiguracyjny komendą ```sh setup.sh```
- Wybrać tryb konfiguracji node
- UWAŻNIE PRZECZYTAĆ WYGENEROWANY PRZEZ SKRYPT OUTPUT - szczególnie zwrócić uwagę na linie zaczynające się od WARNING lub ERROR
- Spróbować z innej konsoli połączyć się do konfigurowanego komputera, żeby sprawdzić czy modyfikacja plików PAM nie wprowadziła niechcianych zmian
- W razie potrzeby wycofać zmiany skryptem ```rollback_setup.sh```

## Przygotowanie komputera do bycia zarządcą:
### Potrzebne paczki
Na komputerze zarządcy należy zainstalować wszystkie paczki potrzebne do działania nodea oraz dodatkowo:
```
zypper install --no-recommends influxdb mariadb grafana-server
```
     
### Konfiguracja
Podstawowe kroki konfiguracyjne są takie same jak dla nodea, tylko odpalając skrypt ```setup.sh``` należy po odpaleniu wybrać tryb master. Oprócz tego należy:
- Utworzyć cron job, który będzie odpalał skrypt dokonujący rezerwacji oraz skrypt czyszczący stan węzłów po rezerwacji:
  - wykonać komendę ```crontab -e```
  - dopisać do pliku crona linie:
  ```
  0 22 * * * /etc/slurm/post_reservation_cleanup.sh
  0 7 * * * /etc/slurm/create_reservation.sh
  ```

### Accounting
#### Mysql
Należy odpalić skrypt konfiguracyjny mysql, w którym należy ustawić hasło dla roota oraz usunąć tymczasowych, testowych użytkowników i struktury.
Skrypt można odpalić poleceniem:
```$ mysql_secure_installation```
Następnie, należy zalogować się do bazy danych i stworzyć w niej użytkownika i struktury, które będą przechowywały dane dotyczące wykorzystania zasobów:
```
$ sudo mysql -u root -p
> CREATE DATABASE slurm_acct_db;
> CREATE USER 'slurm'@'localhost' IDENTIFIED BY 'phahbaShei6f';
> GRANT ALL PRIVILEGES ON slurm_acct_db.* TO 'slurm'@'localhost';
> FLUSH PRIVILEGES;
```

#### Influxdb
Aby móc monitorować wykorzystanie zasobów na przestrzeni czasu należy skonfigurować bazę danych influx, która będzie przechowywać informacje o zużyciu zasobów
w sposób, który umożliwia ich łatwy eksport do narzędzi do wizualizacji np. Grafany:
```
$ influx
> CREATE DATABASE slurm
> CREATE USER slurm WITH PASSWORD 'phahbaShei6f'
> GRANT ALL ON slurm TO slurm
> CREATE RETENTION POLICY "default" ON "slurm" DURATION 14d REPLICATION 1 DEFAULT
```

#### Grafana
Aby móc wyświetlać dane dotyczące zużycia zasobów w Grafanie należy dodać influx jako źródło informacji. W tym celu należy:
- Wejść na stronę grafany pod adresem ```http://<adres-komputera-zarzadcy>:3000```
- Zalogować się jako admin (domyślne hasło admin)
- Wejść w ustawienia, a następnie w Data Sources
- Dodać data source - wybrać InfluxDB
- Jako url do Influx podać ```http://localhost:8086```
- Jako bazę danych podać ```slurm```
- Jako użytkownika podać ```slurm```
- Podać hasło użytkownika ```slurm ``` (ustawione w ramach wykonywania instrukcji paragraf wyżej)
- Zapisać źródło danych
- Stworzyć, korzystając z pliku dashboard.json, dashboard, który będzie wyświetlał interesujące nas informacje
