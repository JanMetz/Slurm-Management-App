#!/bin/bash

echo Zmiana nazwy starych plikow konfiguracyjnych... 
mv /etc/nsswitch.conf /etc/nsswitch.conf.old
mv /etc/ldap.conf /etc/ldap.conf.old
mv /etc/openldap/ldap.conf /etc/openldap/ldap.conf.old
mv /etc/pam.d/common-account /etc/pam.d/commont-account.old
mv /etc/pam.d/common-account-pc /etc/pam.d/common-account-pc.old
mv /etc/pam.d/common-auth /etc/pam.d/common-auth.old
mv /etc/security/access.conf /etc/security/access.conf.old
mv /etc/auto.master /etc/auto.master.old
mv /etc/auto.home /etc/auto.home.old
mv /etc/slurm/slurm.conf /etc/slurm/slurm.conf.old
mv /etc/slurm/slurm-epilog.sh /etc/slurm/slurm-epilog.sh.old
mv /etc/slurm/slurm-resume.sh /etc/slurm/slurm-resume.sh.old
mv /etc/slurm/slurm-suspend.sh /etc/slurm/slurm-suspend.sh.old

echo Przenoszenie nowych plikow konfiguracyjnych...
mv nsswitch.conf /etc/nsswitch.conf
mv ldap.conf /etc/ldap.conf
mv openldap.conf /etc/openldap/ldap.conf
mv common-account /etc/pam.d/commont-account
mv common-account-pc /etc/pam.d/common-account-pc
mv common-auth /etc/pam.d/common-auth
mv access.conf /etc/security/access.conf
mv auto.master /etc/auto.master
mv auto.home /etc/auto.home
mv slurm.conf /etc/slurm/slurm.conf
mv slurm-epilog.sh /etc/slurm/slurm-epilog.sh
mv slurm-resume.sh /etc/slurm/slurm-resume.sh
mv slurm-suspend.sh /etc/slurm/slurm-suspend.sh

echo Tworzenie folderow dla Slurma...
mkdir -p /var/lib/slurm/{spool,state}
chown -R slurm:slurm /var/lib/slurm

echo Tworzenie plikow dla Slurma...
touch /var/lib/slurm/state/job_state.old
touch /var/lib/slurm/state/job_state
touch /var/lib/slurm/state/resv_state
touch /var/lib/slurm/state/resv_state.old

echo Przenoszenie klucza Munge...
if test -f munge.key; then
  	mv munge.key /etc/munge/munge.key
   	chown 149:149 /etc/munge/munge.key
else
	echo OSTRZEZENIE: NIE ODNALEZIONO PLIKU MUNGE.KEY!
fi

echo Tworzenie grupy i uzytkownika dla Slurma i Munge...
groupadd -r -g 149 munge
useradd -r -u 149 -g munge -d /run/munge -s /bin/false -c "MUNGE authentication service" munge
 
groupadd -r -g 148 slurm
useradd -r -u 148 -g slurm -d /run/slurm -s /usr/bin/bash -c "SLURM workload manager" slurm

echo +++ Zmiana wlasiciela plikow slurm-*.sh
chown 148:148 /etc/slurm/slurm-suspend.sh
chown 148:148 /etc/slurm/slurm-epilog.sh
chown 148:148 /etc/slurm/slurm-resume.sh

echo Aktywacja serwisow Slurm i Munge...
systemctl enable munge
systemctl enable slurmd
