#!/bin/bash

restore_config_files(){ #$1=path-to-file 
  if test -f $1; 
  then
    mv $1  .
    
    if test -f $1.old;
    then
      mv $1.old $1;
    fi;
  fi;
}

echo +++ [INFO] Uruchomiono skrypt rollback...
restore_config_files  /etc/nsswitch.conf

restore_config_files  /etc/openldap/ldap.conf  
mv ldap.conf openldap.conf

restore_config_files  /etc/ldap.conf
restore_config_files  /etc/auto.master
restore_config_files  /etc/auto.home
restore_config_files  /etc/auto.a
restore_config_files  /etc/sysconfig/autofs

restore_config_files  /etc/pam.d/sshd
restore_config_files  /etc/pam.d/common-account-pc
  
restore_config_files  /etc/pam.d/common-auth-pc
restore_config_files  /etc/pam.d/common-session-pc
restore_config_files  /etc/pam.d/common-password-pc

restore_config_files  /etc/security/access.conf
restore_config_files  /etc/ssh/sshd_config

restore_config_files  /etc/my.cnf

restore_config_files  /etc/slurm/slurm.conf
restore_config_files  /etc/slurm/slurm-epilog.sh
restore_config_files  /etc/slurm/slurm-resume.sh
restore_config_files  /etc/slurm/slurm-suspend.sh
restore_config_files  /etc/slurm/slurmdbd.conf
restore_config_files  /etc/slurm/acct_gather.conf

restore_config_files  /etc/ethers

restore_config_files  /etc/systemd/system/slurmd.service.d/override.conf
mv override.conf slurmd.override.conf

restore_config_files  /etc/systemd/system/slurmctld.service.d/override.conf
mv override.conf slurmctld.override.conf

restore_config_files /etc/munge/munge.key

if test -f ./sshd-master;
then 
  mv sshd sshd-node;
  mv common-account-pc common-account-node;
else
  mv sshd sshd-master;
  mv common-account-pc common-account-master;
fi;

mv common-auth-pc common-auth
mv common-session-pc common-session
mv common-password-pc common-password

echo +++ [INFO] Wykonano skrypt rollback!
