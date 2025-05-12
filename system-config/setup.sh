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

echo +++ [INFO] Zmiana nazwy starych i przenoszenie nowych plikow konfiguracyjnych... 
swap_config_files nsswitch.conf /etc/nsswitch.conf
swap_config_files ldap.conf /etc/ldap.conf
swap_config_files openldap.conf /etc/openldap/ldap.conf
swap_config_files comon-account /etc/pam.d/common-account
swap_config_files common-account-pc /etc/pam.d/common-account-pc
swap_config_files common-auth /etc/pam.d/common-auth
swap_config_files common-session /etc/pam.d/common-session
swap_config_files common-session-pc /etc/pam.d/common-session-pc
swap_config_files access.conf /etc/security/access.conf
swap_config_files auto.master /etc/auto.master
swap_config_files auto.home /etc/auto.home
swap_config_files slurm.conf /etc/slurm/slurm.conf
swap_config_files slurm-epilog.sh /etc/slurm/slurm-epilog.sh
swap_config_files slurm-resume.sh /etc/slurm/slurm-resume.sh
swap_config_files slurm-suspend.sh /etc/slurm/slurm-suspend.sh
swap_config_files sshd /etc/pam.d/sshd
swap_config_files sshd_config /etc/ssh/sshd_config

echo +++ [WARNING] ZMIENIONO KONFIGURACJE PAM. SPRAWDZ, CZY MOZESZ SIE ZALOGOWAC ODPALAJAC SESJE SSH Z INNEGO TERMINALA!
echo +++ [INFO] W przypadku problemow uruchom skrypt rollback.sh

echo +++ [INFO] Tworzenie folderow dla Slurma...
mkdir -p /var/lib/slurm/{spool,state}
chown -R slurm:slurm /var/lib/slurm

echo +++ [INFO] Tworzenie plikow dla Slurma...
touch /var/lib/slurm/state/job_state.old
touch /var/lib/slurm/state/job_state
touch /var/lib/slurm/state/resv_state
touch /var/lib/slurm/state/resv_state.old

echo +++ [INFO] Tworzenie grupy i uzytkownika dla Slurma i Munge...
groupadd -r -g 149 munge
useradd -r -u 149 -g munge -d /run/munge -s /bin/false -c "MUNGE authentication service" munge
 
groupadd -r -g 148 slurm
useradd -r -u 148 -g slurm -d /run/slurm -s /usr/bin/bash -c "SLURM workload manager" slurm

echo +++ [INFO] Przenoszenie klucza Munge...
if test -f munge.key; then
  	mv munge.key /etc/munge/munge.key
   	chown munge:munge /etc/munge/munge.key
else
	echo +++ [WARNING] NIE ODNALEZIONO PLIKU MUNGE.KEY!
fi

echo +++ [INFO] Zmiana wlasiciela plikow /etc/slurm/slurm-*.sh
chown slurm:slurm /etc/slurm/slurm-suspend.sh
chown slurm:slurm /etc/slurm/slurm-epilog.sh
chown slurm:slurm /etc/slurm/slurm-resume.sh
chmod g+rx /etc/slurm/slurm-suspend.sh
chmod g+rx /etc/slurm/slurm-epilog.sh
chmod g+rx /etc/slurm/slurm-resume.sh

echo +++ [INFO] Aktywacja serwisow Slurm i Munge...
systemctl enable munge
systemctl enable slurmd
