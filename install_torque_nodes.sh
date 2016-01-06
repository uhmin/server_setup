#!/bin/bash

# This script will install torque on CentOS calc nodes.
# Install epel before running this program.
# Open ports for pbs_mom, pbs_resmom, and pbs_sched

function main(){
  yum -y install torque* libtorque-devel.*
  setup_munge
  setup_torque
}

function setup_munge(){
  echo "Setting up munge"
  mkdir -p    /var/run/munge
  chown munge /var/run/munge

  chown munge /var/log/munge
  chgrp munge /var/log/munge
  chown root  /var/lib/munge

  cp munge.key   /etc/munge/munge.key
  chown munge -R /etc/munge
  chmod 0700     /etc/munge
  chgrp munge    /etc/munge/munge.key
  chmod 400      /etc/munge/munge.key

  munged --force

  service munge stop
  chown munge /var/log/munge/munged.log
  chgrp munge /var/log/munge/munged.log
  service munge start
  chkconfig munge on
}

function setup_torque(){
# setup torque pbs_mom
  echo "Setting up torque"
  cd $BASEDIR
  cp mom_config /etc/torque/mom/config
  service pbs_mom start
  chkconfig pbs_mom on
}

main
