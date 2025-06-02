#!/bin/bash

swap_config_files(){ #$1=local-filename, $2=path-to-original-file 
  if test -f $1; 
  then
	mv $2 $2.old
	mv $1 $2
 	echo "+++ [DEBUG] przeniesiono plik ${1}"
  else
	echo "+++ [ERROR] Brak pliku ${1}!"
  fi;
}

remove_user_and_group(){ #$1=group/user name
  if ! [ -z "$(getent passwd $1)" ]; then
	userdel $1;
  fi

  if ! [ -z "$(getent group $1)" ]; then
	groupdel $1;
  fi
}

echo "+++ Wybierz typ konfiguracji w zaleznosci od tego, czy zalezy Ci na skonfigurowaniu wezla do obliczen czy maszyny zarzadcy [node/master]" 
read opt

while ! echo $opt | grep -E -q 'node|master';
do
    read opt;
    echo "+++ [ERROR] Wybrano niepoprawna opcje! Poprawne opcje to node lub master!"
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

swap_config_files slurm.conf 		/etc/slurm/slurm.conf
swap_config_files slurm-epilog.sh 	/etc/slurm/slurm-epilog.sh
swap_config_files slurm-resume.sh 	/etc/slurm/slurm-resume.sh
swap_config_files slurm-suspend.sh 	/etc/slurm/slurm-suspend.sh
swap_config_files slurmdbd.conf 	/etc/slurm/slurmdbd.conf
swap_config_files acct_gather.conf 	/etc/slurm/acct_gather.conf


if [ $opt == "master" ]; then
	swap_config_files ethers 			/etc/ethers;
 
 	swap_config_files sshd-master 			/etc/pam.d/sshd;
	swap_config_files common-account-master 	/etc/pam.d/common-account;
 
 	swap_config_files slurmctld.override.conf	/etc/systemd/system/slurmctld.service.d/override.conf;
  
        mv post_reservation_cleanup.sh 			/etc/slurm/post_reservation_cleanup.sh;
 else
 	swap_config_files sshd-node 			/etc/pam.d/sshd;
 	swap_config_files common-account-node 		/etc/pam.d/common-account;
  
  	swap_config_files slurmd.override.conf 		/etc/systemd/system/slurmd.service.d/override.conf;
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
chown -R slurm:slurm /var/lib/slurm

echo "+++ [INFO] Zmiana praw dostepu do plikow i katalogow uzywanych przez Slurma"
chown slurm:slurm /etc/slurm/slurm-suspend.sh
chown slurm:slurm /etc/slurm/slurm-epilog.sh
chown slurm:slurm /etc/slurm/slurm-resume.sh
chown slurm:slurm /etc/slurm/slurmdbd.conf
chown slurm:slurm /var/run/slurm
chown :slurm /var/log

chmod g+rx /etc/slurm/slurm-suspend.sh
chmod g+rx /etc/slurm/slurm-epilog.sh
chmod g+rx /etc/slurm/slurm-resume.sh
chmod 600 /etc/slurm/slurmdbd.conf
chmod g+rw /var/run/slurm
chmod g+rw /var/log

echo "+++ [INFO] Tworzenie plikow dla Slurma..."
touch /var/lib/slurm/state/job_state.old
touch /var/lib/slurm/state/job_state
touch /var/lib/slurm/state/resv_state
touch /var/lib/slurm/state/resv_state.old

echo "+++ [INFO] Przenoszenie klucza Munge..."
if test -f munge.key; then
  	mv munge.key /etc/munge/munge.key
   	chown munge:munge /etc/munge/munge.key
else
	echo "+++ [WARNING] NIE ODNALEZIONO PLIKU MUNGE.KEY!"
fi

echo "+++ [INFO] Aktywacja serwisow..."
systemctl daemon-reload

systemctl enable munge
systemctl restart munge

systemctl enable autofs
systemctl restart autofs

if [ $opt == "master" ]; then
	systemctl enable slurmctld;
 	systemctl restart slurmctld;
  
  	systemctl enable mariadb
	systemctl restart mariadb

	systemctl enable slurmdbd
	systemctl restart slurmdbd
else
	systemctl enable slurmd;
 	systemctl restart slurmd;
fi

if [ $opt == "master" ]; then 
	echo "+++ [INFO] Konfiguracja bazy accounting...";
 	sacctmgr add cluster dcc;

  	systemctl enable influxdb
	systemctl start influxdb

 	systemctl enable grafana-server
  	systemctl start grafana-server
fi
