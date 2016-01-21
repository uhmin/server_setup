#!/bin/bash

# This script will install torque on CentOS 6.7 main node
# Install epel before installing running this script
# If torque does not work please check the following
# 1) Check the firewall. Be sure to open ports for pbs_*, and munge.
#  Port numbers can be checked in /etc/services
#  (probably, 3950 (munge), and 1501-1504 (pbs))

function main(){
    yum -y install torque-*
    setup_munge
    setup_torque
    cat <<EOF
Be sure that all the torque user should be able to 
access to calc node mutually without password
(such as by setting publickey without password).
EOF
}

function setup_munge(){
    killall munged
    mkdir -p /var/run/munge
    yes | /usr/sbin/create-munge-key

    chown -R munge:munge /etc/munge
    chmod 0700 /etc/munge/
    chown munge:munge /var/lib/munge/
    chmod 0711 /var/lib/munge/
    chown -R munge:munge /var/log/munge/
    chmod 0700 /var/log/munge/
    chown munge:munge /var/run/munge
    chmod 0755 /var/run/munge/

    service munge start
# If you fail to start munge, read /etc/hosts and
# check if the host name is correct the same as
# the result of `/bin/hostname`
}

function setup_torque(){
    processorNum=`egrep "^processor\s:\s[0-9]+$" /proc/cpuinfo | wc -l`
    hostname=`hostname`
    shorthost=`echo $hostname | sed "s/\..*//"`
    target=`locate torque | grep "torque$" | egrep "^/var|^/etc|^/opt/" | egrep -v "log|lib
"`
    mkdir -p $target/server_priv $target/mom_priv
    echo "$hostname np=$processorNum" >> $target/server_priv/nodes

    hostname=`/bin/hostname --long`
    echo $hostname > $target/server_name
    mv $target/mom/config $target/mom/config.b
    sed "s/^\$pbsserver.*/\$pbsserver $hostname/" $target/mom/config.b \
        > $target/mom/config

    killall pbs_server
    killall pbs_sched
    killall pbs_mom
    yes | pbs_server -t create&
    pbs_sched
    if [ "@$shorthost" != "@localhost" ]
    then
        echo "create node $shortnode np=$processorNum" | qmgr
    fi

    make_server_conf

    qmgr < $target/myconf/server.conf

    echo "\$logevent 0x1fff" > $target/mom_priv/config
    echo "\$max_load $processorNum" >> $target/mom_priv/config
    echo "\$ideal_load $processorNum" >> $target/mom_priv/config
    echo "\$pbsserver $hostname" >> $target/mom_priv/config
    echo "\$restricted $hostname" >> $target/mom_priv/config
    pbs_mom
}

function make_server_conf(){
    target=`locate torque | grep "torque$" | egrep "^/var|^/etc|^/opt/" | egrep -v "log|lib"`
    hostname=`hostname`
    shorthost=`echo $hostname | sed "s/\..*//"`
    processorNum=`egrep "^processor\s:\s[0-9]+$" /proc/cpuinfo | wc -l`
    mkdir -p $target/myconf
    if [ "@$shorthost" = "@localhost" ]
    then
        shorthost=""
    fi
    cat <<EOF > $target/myconf/server.conf
create node $shorthost np=$processorNum
#
# Create and define queue default
#
create queue default@$shorthost
set queue default@$shorthost queue_type = Execution
set queue default@$shorthost enabled = True
set queue default@$shorthost started = True
set server default_queue=default
#
# Create and define queue three_hours
#
create queue three_hours@$shorthost
set queue three_hours@$shorthost queue_type = Execution
set queue three_hours@$shorthost resources_max.cput = 03:00:00
set queue three_hours@$shorthost resources_default.ncpus = 10
set queue three_hours@$shorthost resources_default.nodes = 1
set queue three_hours@$shorthost enabled = True
set queue three_hours@$shorthost started = True

#
# Set server attributes
#
set server @$shorthost scheduling = True

EOF

}

