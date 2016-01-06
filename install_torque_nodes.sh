#!/bin/bash

# This script will install torque on CentOS calc nodes.
# Install epel before running this program.
# Open ports for pbs_mom, pbs_resmom, and pbs_sched

:<<EOF
# sample of /etc/sysconfig/iptables
# Firewall configuration written by system-config-firewall
# Manual customization of this file is not recommended.
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 111 -j ACCEPT
-A INPUT -m state --state NEW -m udp -p udp --dport 111 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 15001 -j ACCEPT
-A INPUT -m state --state NEW -m udp -p udp --dport 15001 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 15002 -j ACCEPT
-A INPUT -m state --state NEW -m udp -p udp --dport 15002 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 15003 -j ACCEPT
-A INPUT -m state --state NEW -m udp -p udp --dport 15003 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 15004 -j ACCEPT
-A INPUT -m state --state NEW -m udp -p udp --dport 15004 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 15005 -j ACCEPT
-A INPUT -m state --state NEW -m udp -p udp --dport 15005 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 3950 -j ACCEPT
-A INPUT -m state --state NEW -m udp -p udp --dport 3950 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 834 -j ACCEPT
-A INPUT -m state --state NEW -m udp -p udp --dport 834 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 835 -j ACCEPT
-A INPUT -m state --state NEW -m udp -p udp --dport 835 -j ACCEPT

# postgres
-A INPUT -m state --state NEW -m tcp -p tcp --dport 5432 -j ACCEPT

# mysql
-A INPUT -p tcp --dport 3306 -j ACCEPT
-A INPUT -p tcp --sport 3306 -j ACCEPT

-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT
EOF

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
