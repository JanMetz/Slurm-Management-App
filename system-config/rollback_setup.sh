#!/bin/bash

echo +++ [INFO] Uruchomiono skrypt rollback...
mv /etc/nsswitch.conf.old        /etc/nsswitch.conf
mv /etc/ldap.conf.old            /etc/ldap.conf
mv /etc/openldap/ldap.conf.old   /etc/openldap/ldap.conf
mv /etc/auto.master.old          /etc/auto.master
mv /etc/auto.home.old            /etc/auto.home
mv /etc/auto.a.old               /etc/auto.a
mv /etc/sysconfig/autofs.old     /etc/sysconfig/autofs

mv /etc/pam.d/sshd.old                /etc/pam.d/sshd
mv /etc/pam.d/common-account-pc.old   /etc/pam.d/common-account-pc
mv /etc/pam.d/common-auth-pc.old      /etc/pam.d/common-auth-pc
mv /etc/pam.d/common-session-pc.old   /etc/pam.d/common-session-pc
mv /etc/pam.d/common-password-pc.old  /etc/pam.d/common-password-pc

mv /etc/security/access.conf.old     /etc/security/access.conf
mv /etc/ssh/sshd_config.old          /etc/ssh/sshd_config

mv /etc/my.cnf.old  /etc/my.cnf

mv /etc/slurm/slurm.conf.old        /etc/slurm/slurm.conf
mv /etc/slurm/slurm-epilog.sh.old   /etc/slurm/slurm-epilog.sh
mv /etc/slurm/slurm-resume.sh.old   /etc/slurm/slurm-resume.sh
mv /etc/slurm/slurm-suspend.sh.old  /etc/slurm/slurm-suspend.sh
mv /etc/slurm/slurmdbd.conf.old     /etc/slurm/slurmdbd.conf
mv /etc/slurm/acct_gather.conf.old  /etc/slurm/acct_gather.conf

mv /etc/ethers.old                  /etc/ethers

mv /etc/systemd/system/slurmd.service.d/override.conf.old     /etc/systemd/system/slurmd.service.d/override.conf
mv /etc/systemd/system/slurmctld.service.d/override.conf.old  /etc/systemd/system/slurmctld.service.d/override.conf

echo +++ [INFO] Wykonano skrypt rollback!
