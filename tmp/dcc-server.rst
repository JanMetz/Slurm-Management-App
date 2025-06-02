Software
--------

#. Install openSUSE 15.4 (server installation) plus::

     autofs
     nss_ldap
     openldap2-client
     pam_ldap
     slurm
     slurm-munge
     slurm-pam_slurm
     sssd
     ipmitool

…

Tests
----

LDAP:    
     $ getent passwd voytek

     $ ldapsearch -LLL -ZZ -x '(uid=voytek)' dn

MUNGE:
     $ munge -n

     $ munge -n | unmunge

     $ munge -n | ssh dcc-2 unmunge

     $ ssh dcc-2 munge -n | unmunge

SLURM:
     dcc-0# slurmctld -D -c -vv

     dcc-n# slurmd -D -c -vv

     (reset)      $ rm -rf /var/lib/slurm/spool/*


Config
----

#. Edit ``/etc/nsswitch.conf``::

     passwd: files ldap
     group:  files ldap
     shadow: files ldap

#. Edit ``/etc/ldap.conf``::

     ldap_version    3
     scope   sub
     bind_timelimit  7
     bind_policy     soft
     pam_password    md5
     uri   ldap://sirius.cs.put.poznan.pl
     base  o=put
     pam_filter      objectclass=shadowAccount
     # pam_groupdn	cn=something,ou=groups,o=put
     pam_member_attribute member
     nss_base_passwd ou=people,o=put
     nss_base_shadow ou=people,o=put
     nss_base_group  ou=groups,o=put
     nss_base_netgroup       ou=netgroups,o=put
     nss_map_attribute       uniqueMember member
     nss_schema rfc2307bis
     nss_initgroups_ignoreusers      root,ldap
     ssl     start_tls
     tls_checkpeer   yes
     tls_cacertfile /etc/pki/trust/anchors/cs.local.pem

#. Edit ``/etc/openldap/ldap.conf``::

     URI ldap://sirius.cs.put.poznan.pl
     BASE o=put
     TLS_REQCERT   demand
     TLS_CACERT    /etc/ssl/cacert.pem

#. Edit ``/etc/pam.d/common-account``::

     account required    pam_access.so
     account required    pam_unix.so
     #account sufficient  pam_localuser.so
     #account required    pam_listfile.so item=user sense=allow file=/etc/user.allow onerr=fail

#. Edit ``/etc/pam.d/common-auth``::

     auth    required    pam_env.so
     auth    sufficient  pam_unix.so     try_first_pass
     auth    required    pam_ldap.so     use_first_pass

#. Edit ``/etc/security/access.conf``::

     + : root sobaniec : ALL
     - : ALL : ALL


Automount
---------

#. Edit ``/etc/auto.master``::

     /home /etc/auto.home

#. Edit ``/etc/auto.home``::

     *       -fstype=nfs,nosuid,nodev,soft       150.254.30.35:/home/&


…


SLURM
-----

#. Add users::

     $ groupadd -r -g 149 munge
     $ useradd -r -u 149 -g munge -d /run/munge -s /bin/false -c "MUNGE authentication service" munge
     
     $ groupadd -r -g 148 slurm
     $ useradd -r -u 148 -g slurm -d /run/slurm -s /usr/bin/bash -c "SLURM workload manager" slurm

#. Munge: generate key for *munge*::

     $ dd if=/dev/random bs=1 count=1024 > /etc/munge/munge.key

   Copy it to other hosts and run::

     $ systemctl start munge

#. Create directories::

     $ mkdir -p /var/lib/slurm/{spool,state}
     $ chown -R slurm:slurm /var/lib/slurm

#. Edit ``/etc/slurm/slurm.conf``::

     ClusterName=dcc
     ControlMachine=dcc
          #SlurmUser=slurm ?
     AuthType=auth/munge
     StateSaveLocation=/var/lib/slurm/state
     SlurmdSpoolDir=/var/lib/slurm/spool
     ReturnToService=2
     Epilog=/etc/slurm/slurm-epilog.sh
     MpiParams=ports=12000-12999

     # Power saving: http://slurm.schedmd.com/power_save.html
     SlurmdTimeout=90
     SuspendTime=1800
     SuspendRate=60
     SuspendTimeout=120
     SuspendProgram=/etc/slurm/slurm-suspend.sh
     ResumeTimeout=180
     ResumeRate=60
     ResumeProgram=/etc/slurm/slurm-resume.sh
     #SuspendExcNodes=

     NodeName=dcc-[1-16] Sockets=1 CoresPerSocket=4 State=UNKNOWN

     PartitionName=dcc Nodes=dcc-[1-16] Default=YES

#. Edit ``/etc/pam.d/common-account-pc`` on nodes *dcc-n*::

     account requisite       pam_unix.so
     account sufficient      pam_localuser.so
     account required        pam_ldap.so     use_first_pass
     account required        pam_access.so
     account requisite       pam_slurm.so
     account required        pam_sss.so     use_first_pass

#. Create ``/etc/slurm/slurm-epilog.sh``::

     #!/bin/bash

     H=$(hostname)
     if [ "${H%-*}" != "dcc" ]
     then
         exit 0
     fi
     if [ -n "$SLURM_JOB_USER" -a "$SLURM_JOB_USER" != "root" ]
     then
         pkill -u $SLURM_JOB_USER
         sleep 2
         pkill -9 -u $SLURM_JOB_USER
     fi
     exit 0

#. Create ``/etc/slurm/slurm-suspend.sh``::

     #!/bin/bash

     logger -t SLURM "suspending $@"
     for HOST in $(scontrol show hostnames "$1")
     do
       HNO=${HOST##*-}
       ipmitool -f /etc/ipmi.secret -I lan -H 10.10.0.$((150+$HNO)) -U root \
                power soft
     done

     exit 0

   and ``/etc/slurm/slurm-resume.sh``::

     #!/bin/bash

     logger -t SLURM "resuming $@"
     for HOST in $(scontrol show hostnames "$1")
     do
         HNO=${HOST##*-}
         ipmitool -f /etc/ipmi.secret -I lan -H 10.10.0.$((150+$HNO)) -U root \
                  power on
     done

     exit 0

#. Activate the services::

     $ systemctl enable munge
     $ systemctl enable slurmd

     na hoście:
     $ systemctl enable slurmctld

#. Control (http://slurm.schedmd.com/quickstart.html)::

     $ sinfo
     $ srun -N2 -l hostname
     $ srun -n8 -l hostname
     $ srun -N2 -x dcc-2 hostname
     $ srun -N2 --mincpus=8 hostname
     $ srun -N2 -o out hostname
     $ srun -N2 --prolog=start.sh --epilog=end.sh hostname
     $ srun -N2 --task-prolog=start.sh hostname
     $ srun -w 'dcc-[5-8]' hostname
     $ srun -N 4 -w 'dcc-11,dcc-12' hostname
     $ srun -N 4 -x dcc-3 hostname
     $ srun -p dcc -N 4 hostname

     $ sbatch -N2 go.sh
     $ squeue
     $ scancel <job-id>

     $ salloc -N2 bash

     $ scontrol show partition
     $ scontrol show config
     $ scontrol scontrol job
     $ scontrol show node dcc-2
     $ scontrol reconfig                # after config update
     $ scontrol show config

     $ scontrol update nodename=dcc-2 state=IDLE
     $ scontrol update "nodename=dcc-[1-16]" state=down reason="..."

     $ scontrol update "nodename=dcc-[1-16]" state=POWER_DOWN
     $ scontrol update "nodename=dcc-[1-16]" state=resume
     $ scontrol update "nodename=dcc-[1-16]" state=POWER_UP

SLURM documentation: https://documentation.suse.com/sle-hpc/15-SP3/html/hpc-guide/cha-slurm.html
