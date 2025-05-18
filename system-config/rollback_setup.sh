#!/bin/bash

echo +++ [INFO] Uruchomiono skrypt rollback...
mv /etc/nsswitch.conf.old /etc/nsswitch.conf
mv /etc/ldap.conf.old /etc/ldap.conf
mv /etc/openldap/ldap.conf.old /etc/openldap/ldap.conf
mv /etc/pam.d/common-account.old /etc/pam.d/common-account
mv /etc/pam.d/common-account-pc.old /etc/pam.d/common-account-pc
mv /etc/pam.d/common-auth.old /etc/pam.d/common-auth
mv /etc/pam.d/common-session.old /etc/pam.d/common-session
mv /etc/pam.d/common-session-pc.old /etc/pam.d/common-session-pc
mv /etc/security/access.conf.old /etc/security/access.conf
mv /etc/auto.master.old /etc/auto.master
mv /etc/auto.home.old /etc/auto.home
mv /etc/slurm/slurm.conf.old /etc/slurm/slurm.conf
mv /etc/slurm/slurm-epilog.sh.old /etc/slurm/slurm-epilog.sh
mv /etc/slurm/slurm-resume.sh.old /etc/slurm/slurm-resume.sh
mv /etc/slurm/slurm-suspend.sh.old /etc/slurm/slurm-suspend.sh
mv /etc/pam.d/sshd.old /etc/pam.d/sshd
mv /etc/ssh/sshd_config.old /etc/ssh/sshd_config
mv /etc/systemd/system/slurmd.service.d/override.conf.old /etc/systemd/system/slurmd.service.d/override.conf
