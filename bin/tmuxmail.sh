#!/bin/bash
# Set maildirs
declare -a maildirs=("/home/satanand/Maildir/INBOX/new/" "/home/satanand/Maildir/lio_nic_driver/new/" "/home/satanand/Maildir/netdev/new/" "/home/satanand/Maildir/bugzilla/new/")
#weather ksjc > /tmp/weather.txt
#temperature=`cat /tmp/weather.txt  | grep Temp | awk '{ print $2 }'`
#sky=`cat /tmp/weather.txt  | grep Sky | awk '{ $1=$2=""; print $0 }'`
count=0
for i in "${maildirs[@]}"
do
	let count=$count+`find $i -type f | wc -l`
done
#printf "%sF %s Mail:%d" "$temperature" "$sky" "$count"
printf " Mail:%d" "$count"
