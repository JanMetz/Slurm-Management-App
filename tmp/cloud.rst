…


SLURM
-----

#. Install packages::

     munge
     slurm
     slurm-munge
     slurm-pam_slurm

#. Munge: generate key for *munge*::

     # dd if=/dev/random bs=1 count=1024 > /etc/munge/munge.key

   Copy it to other hosts and run::

     # systemctl start munge

   Tests::

     # munge -n
     # munge -n | unmunge
     # munge -n | ssh hpc-2 unmunge

#. Add users::

     # groupadd -r -g 466 slurm
     # useradd -r -u 466 -g slurm slurm

#. Edit ``/etc/slurm/slurm.conf``::

     ClusterName=hpc
     ControlMachine=hpc
     SlurmUser=slurm
     AuthType=auth/munge
     StateSaveLocation=/var/lib/slurm
     SlurmdSpoolDir=/var/lib/slurm
     ReturnToService=2
     Epilog=/etc/slurm/slurm.epilog.clean
     MpiParams=ports=12000-12999

     # Power saving: http://slurm.schedmd.com/power_save.html
     SlurmdTimeout=90
     SuspendTime=1800
     SuspendTimeout=120
     SuspendProgram=/etc/slurm/slurm-suspend.sh
     ResumeTimeout=210
     ResumeProgram=/etc/slurm/slurm-resume.sh
     #SuspendExcNodes=

     NodeName=hpc-[1-16] Sockets=1 CoresPerSocket=4 State=UNKNOWN

     PartitionName=hpc Nodes=hpc-[1-16] Default=YES

#. Edit ``/etc/pam.d/common-account-pc`` on nodes *hpc-n*::

     account required        pam_access.so
     account requisite       pam_slurm.so
     account requisite       pam_unix.so
     account sufficient      pam_localuser.so
     account required        pam_sss.so     use_first_pass

#. Run the daemons in test mode::

     hpc-0# slurmctld -D -c -vv
     hpc-n# slurmd -D -c -vv

#. SLURM reset::

     # rm -rf /var/lib/slurm/spool/*

#. Create ``/etc/slurm/slurm-epilog.sh``::

     #!/bin/bash

     H=$(hostname)
     if [ "${H%-*}" != "hpc" ]
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

     hpc-X# systemctl enable munge.service
     hpc-X# systemctl enable slurmd.service

   and at the controller::

     hpc# systemctl enable munge.service
     hpc# systemctl enable slurmctld.service

#. Control (http://slurm.schedmd.com/quickstart.html)::

     # sinfo
     # srun -N2 -l hostname
     # srun -n8 -l hostname
     # srun -N2 -x hpc-2 hostname
     # srun -N2 --mincpus=8 hostname
     # srun -N2 -o out hostname
     # srun -N2 --prolog=start.sh --epilog=end.sh hostname
     # srun -N2 --task-prolog=start.sh hostname
     # srun -w 'hpc-[5-8]' hostname
     # srun -N 4 -w 'hpc-11,hpc-12' hostname
     # srun -N 4 -x hpc-3 hostname

     # sbatch -N2 go.sh
     # squeue
     # scancel <job-id>

     # salloc -N2 bash

     # scontrol show partition
     # scontrol show config
     # scontrol scontrol job
     # scontrol show node hpc-2
     # scontrol reconfig                # after config update
     # scontrol show config

     # scontrol update nodename=hpc-2 state=IDLE
     # scontrol update "nodename=hpc-[1-16]" state=POWER_DOWN

