#!/bin/bash

swap_config_files(){ #$1=local-filename, $2=path-to-original-file 
  if test -f $1; 
  then
    mv $2 $2.old;
    mv $1 $2;
    echo "+++ [DEBUG] przeniesiono plik ${1}";
  else
    echo "+++ [ERROR] Brak pliku ${1}!";
  fi;
}

remove_user_and_group(){ #$1=group/user name
  if ! [ -z "$(getent passwd $1)" ]; then
    pkill -u $1
    userdel $1;
  fi

  if ! [ -z "$(getent group $1)" ]; then
    groupdel $1;
  fi
}

adjust_dir_permissions() { #$1=dirname=groupname=username
  chmod 700 /etc/$1
  chown -R $1:$1 /etc/$1/

  chmod 755 /var/log/$1
  chown -R $1:$1 /var/log/$1/

  chmod 755 /var/lib/$1
  chown -R $1:$1 /var/lib/$1/
}

echo "+++ Wybierz typ konfiguracji w zaleznosci od tego, czy zalezy Ci na skonfigurowaniu wezla do obliczen czy maszyny zarzadcy [node/master]" 
read opt

while ! echo $opt | grep -E -q 'node|master';
do
  read opt;
  echo "+++ [ERROR] Wybrano niepoprawna opcje! Poprawne opcje to node lub master!";
done;

echo "+++ [INFO] Zmiana nazwy starych i przenoszenie nowych plikow konfiguracyjnych..." 
swap_config_files common-auth 		/etc/pam.d/common-auth-pc
swap_config_files common-session 	/etc/pam.d/common-session-pc
swap_config_files common-password 	/etc/pam.d/common-password-pc

swap_config_files nsswitch.conf 	/etc/nsswitch.conf
swap_config_files ldap.conf 		/etc/ldap.conf
swap_config_files openldap.conf 	/etc/openldap/ldap.conf
swap_config_files auto.master 		/etc/auto.master
swap_config_files auto.home 		/etc/auto.home
swap_config_files auto.a		/etc/auto.a
swap_config_files autofs		/etc/sysconfig/autofs

swap_config_files access.conf 		/etc/security/access.conf
swap_config_files sshd_config 		/etc/ssh/sshd_config

swap_config_files my.cnf 		/etc/my.cnf

mkdir -p /etc/prometheus
swap_config_files prometheus.yml	/etc/prometheus/prometheus.yml

mkdir -p /etc/slurm
swap_config_files slurm.conf 		/etc/slurm/slurm.conf
swap_config_files slurm-epilog.sh 	/etc/slurm/slurm-epilog.sh
swap_config_files slurm-resume.sh 	/etc/slurm/slurm-resume.sh
swap_config_files slurm-suspend.sh 	/etc/slurm/slurm-suspend.sh
swap_config_files slurmdbd.conf 	/etc/slurm/slurmdbd.conf
swap_config_files acct_gather.conf 	/etc/slurm/acct_gather.conf


if [ $opt == "master" ]; then
  swap_config_files ethers 			/etc/ethers;
 
  swap_config_files sshd-master 		/etc/pam.d/sshd;
  swap_config_files common-account-master 	/etc/pam.d/common-account-pc;

  mkdir -p					/etc/systemd/system/slurmctld.service.d/;
  swap_config_files slurmctld.override.conf	/etc/systemd/system/slurmctld.service.d/override.conf;
  
  mv post_reservation_cleanup.sh 		/etc/slurm/;
  mv reverse_proxy_grafana.conf			/etc/nginx/conf.d/
 else
  swap_config_files sshd-node 			/etc/pam.d/sshd;
  swap_config_files common-account-node 	/etc/pam.d/common-account-pc;

  mkdir -p					/etc/systemd/system/slurmd.service.d/;
  swap_config_files slurmd.override.conf 	/etc/systemd/system/slurmd.service.d/override.conf;
 fi

echo "+++ [WARNING] ZMIENIONO KONFIGURACJE PAM. SPRAWDZ, CZY MOZESZ SIE ZALOGOWAC ODPALAJAC SESJE SSH Z INNEGO TERMINALA!"
echo "+++ [INFO] W przypadku problemow uruchom skrypt rollback.sh"

echo "+++ [INFO] Tworzenie grupy i uzytkownika Slurm i Munge..."
remove_user_and_group munge
groupadd -r -g 149 munge
useradd -r -u 149 -g munge -d /run/munge -s /bin/false -c "MUNGE authentication service" munge

remove_user_and_group slurm
groupadd -r -g 148 slurm
useradd -r -u 148 -g slurm -d /run/slurm -s /usr/bin/bash -c "SLURM workload manager" slurm

echo "+++ [INFO] Tworzenie katalogow dla Slurma..."
mkdir -p /var/lib/slurm/{spool,state}
mkdir -p /var/log/munge/
mkdir -p /var/log/slurm

echo "+++ [INFO] Zmiana praw dostepu do plikow i katalogow uzywanych przez Slurma i Munge"
chmod 700 /var/run/slurm
chown -R slurm:slurm /var/run/slurm/

chmod 775 /var/log

adjust_dir_permissions slurm
adjust_dir_permissions munge

echo "+++ [INFO] Tworzenie plikow dla Slurma..."
touch /var/lib/slurm/state/job_state.old
touch /var/lib/slurm/state/job_state
touch /var/lib/slurm/state/resv_state
touch /var/lib/slurm/state/resv_state.old

echo "+++ [INFO] Przenoszenie klucza Munge..."
if test -f munge.key; then
  mv munge.key /etc/munge/munge.key;
  chown munge:munge /etc/munge/munge.key;
  chmod 400 /etc/munge/munge.key;
else
  echo "+++ [WARNING] NIE ODNALEZIONO PLIKU MUNGE.KEY!";
fi

echo "+++ [INFO] Przenoszenie certyfikatu LDAP..."
if test -f cs.local.pem; then
  mv cs.local.pem /etc/pki/trust/anchors/cs.local.pem;
else
  echo "+++ [CRITICAL] NIE ODNALEZIONO PLIKU CS.LOCAL.PEM! MODULY PAM_LDAP NIE BEDA POZWALALY NA ZALOGOWANIE!";
  echo "+++ [INFO] Uruchamiam skrypt rollback";
  sh rollback_setup.sh;
  exit 1;
fi

echo "+++ [INFO] Aktywacja serwisow..."
systemctl daemon-reload

systemctl enable munge
systemctl restart munge

systemctl enable autofs
systemctl restart autofs

systemctl enable sshd

if [ $opt == "master" ]; then
  systemctl enable slurmctld;
  systemctl restart slurmctld;
  
  systemctl enable mariadb;
  systemctl restart mariadb;

  systemctl enable mysql;
  systemctl restart mysql;

  systemctl enable slurmdbd;
  systemctl restart slurmdbd;
else
  systemctl enable slurmd;
  systemctl restart slurmd;
fi

if [ $opt == "master" ]; then 
  echo "+++ [INFO] Konfiguracja bazy accounting...";
  sacctmgr add cluster dcc;

  systemctl enable influxdb;
  systemctl restart influxdb;

  systemctl enable grafana-server;
  systemctl restart grafana-server;

  systemctl enable prometheus-slurm-exporter;
  systemctl restart prometheus-slurm-exporter;
fi
