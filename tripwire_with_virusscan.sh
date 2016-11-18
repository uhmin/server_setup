#!/bin/sh
# To use this script clamAV should be installed

HOST_NAME=`uname -n`

# Set passphrase
LOCALPASS=localpass # set the local pass
SITEPASS=sitepass   # set the  site pass

# Exec checking
echo
echo "Executing tripwire"
/usr/sbin/tripwire --check | tee /var/log/tripwire.log | \
    mail -s "Tripwire Check Report in $HOST_NAME" root

cd /etc/tripwire

# Virus check for modified files
# clamd update
echo
echo "Updating clamd"
yum -y update clamd > /dev/null 2>&1

# update virus database
echo
echo "Updating virus database"
/usr/bin/freshclam

# exec virusscan
echo
echo "Executing virusscan"
/etc/tripwire/makeModifiedFileList.pl > modifiedFileList.txt
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
perl twpolmake.pl twpol.txt > twpol.txt.new
twadmin -m P -c tw.cfg -p tw.pol -S site.key -Q $SITEPASS twpol.txt.new > /dev/null
rm -f twpol.txt* *.bak

# Update DB
echo
echo "Updating tripwire database"
/usr/sbin/tripwire --init -P $LOCALPASS > /dev/null 2>&1
