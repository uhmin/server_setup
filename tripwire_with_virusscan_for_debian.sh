#!/bin/sh -e
# clamAV should be installed
# Put makeModifiedFileList.pl in  /usr/local/bin/ before run this script.
tripwire=/usr/sbin/tripwire
logdir=/var/lib/tripwire
makeModifiedFileList=/usr/local/bin/makeModifiedFileList.pl

HOST_NAME=`uname -n`

# Set passphrase
LOCALPASS=localpass # set the local pass
SITEPASS=sitepass   # set the  site pass

# Exec checking
echo
echo "Executing tripwire"
umask 027
$tripwire --check --quiet --email-report
#$tripwire --check | tee /var/log/tripwire.log | \
#    mail -s "Tripwire Check Report in $HOST_NAME" root

cd $logdir

# exec virusscan
echo
echo "Executing virusscan"
$makeModifiedFileList > modifiedFileList.txt
scanResult=`clamscan --file-list modifiedFileList.txt | egrep "FOUND|Infected files:" | \
    grep -v "Infected files: 0" `
if [ "$scanResult" != "" ]
then
    hostname=`hostname`
    echo $scanResult
    echo $scanResult | mail -s "Virus found on $HOST_NAME" root
fi
rm modifiedFileList.txt

# Update policy file
echo
echo "Updating policy file"
twadmin -m p -c tw.cfg -p tw.pol -S site.key > twpol.txt
twpolmake.pl twpol.txt > twpol.txt.new
twadmin -m P -c tw.cfg -p tw.pol -S site.key -Q $SITEPASS twpol.txt.new > /dev/null
rm -f twpol.txt* *.bak

# Update DB
echo
echo "Updating tripwire database"
$tripwire --init -P $LOCALPASS > /dev/null 2>&1
