#!/bin/bash
# sometime back most of the open source mailing lists have stopped sending daily digests. 
# And even those that do send daily digests send 3 or 4 per day with not just the subject but the whole body of the mails
# not exactly helpful if you are not interested in the subject
# this script can be used in those cases, to get the gist of conversations o on some opensource mailing lists 
# and send a mail to yourself on a daily basis. 
# currently it gets you mails from 2 days back to cover for all kinds of timezones. if today is 9th you will get the
# digest of 7th if you run this now
# It helps you in not signing up for those lists but you can still monitor whats going on a daily basis. 
# Also there is another check that goes through kernelnewbies.org and sends you info about new linux kernel releases.
# needs bash > 4.3 
# needs bsd-mailx not heirloom-mailx 
# use postfix/ssmtp/msmtp with gmail or some other free smtp server
# do not send without smtp server or it will be bounced
# TODO starting and ending dates are displayed incorrectly 
# TODO number of messages are displayed incorrectly
# TODO it only supports daily digests, the binary search algorithm has to be modified to make it work with arbitary number of days
set -x

DATE_MAIL=`date --date="2 days ago" +%Y/%m/%d`
TMP=`date --date="2 days ago" +%d`
DATE=$(echo $TMP | sed 's/^0*//')
MON=`date --date="2 days ago" +%b`
YEAR=`date --date="2 days ago" +%Y`
YEARMONTH=`date --date="2 days ago" +%Y-%B`
EMAIL_ID="sburla@marvell.com"

#netdev
send_netdev_daily()
{
	wget http://lists.openwall.net/netdev/${DATE_MAIL} -O /tmp/x.html
	sed -i "/<head>/a <base href=\" https:\/\/lists.openwall.net\/netdev\/${DATE_MAIL}\/\">" /tmp/x.html
	#mail -a "Content-type: text/html" -s "netdev-digest_${DATE_MAIL}" $EMAIL_ID < /tmp/x.html
	mutt -e "set content_type=text/html" -s "netdev-digest_${DATE_MAIL}" $EMAIL_ID < /tmp/x.html
	rm -f /tmp/x.html
}

#lkml
send_lkml_daily()
{
	wget https://lkml.org/lkml/${DATE_MAIL} -O /tmp/x.html
	sed -i "s#<head>#<head><base href=\" https://lkml.org/\">#" /tmp/x.html
	#mail -a "Content-type: text/html" -s "${DATE_MAIL}" $EMAIL_ID < /tmp/x.html
	mutt -e "set content_type=text/html" -s "lkml-digest_${DATE_MAIL}" $EMAIL_ID < /tmp/x.html
	rm -f /tmp/x.html
}




# Linux kernel changes.  
send_linux_kernel_release()
{
	if [ ! -e ~/.current_major_lkv ]; then
		wget https://www.kernel.org -O /tmp/x.html
		CURRENT_MAJOR=`w3m /tmp/x.html  | grep Latest -A 1 | grep Download | awk '{ print $2 }' | cut -f1 -d.`
		CURRENT_MINOR=`w3m /tmp/x.html  | grep Latest -A 1 | grep Download | awk '{ print $2 }' | cut -f2 -d.`
		echo $CURRENT_MAJOR > ~/.current_major_lkv
		echo $CURRENT_MINOR > ~/.current_minor_lkv
		rm -f /tmp/x.html
	fi
	CURRENT_MAJOR=`cat ~/.current_major_lkv`
	CURRENT_MINOR=`cat ~/.current_minor_lkv`
	NEXT_MAJOR=`expr $CURRENT_MAJOR + 1`
	NEXT_MINOR=`expr $CURRENT_MINOR + 1`

	echo "getting  Linux_${CURRENT_MAJOR}.${NEXT_MINOR}.0"
	wget https://kernelnewbies.org/Linux_${CURRENT_MAJOR}.${NEXT_MINOR} -O /tmp/x.html
	if [ ! -s /tmp/x.html ]; then
		echo "could not find next minor"
		# try next major and 0 minor
		echo "getting  Linux_${NEXT_MAJOR}.0"
		wget https://kernelnewbies.org/Linux_${NEXT_MAJOR}.0 -O /tmp/x.html
		if [ ! -s /tmp/x.html ]; then
			echo "new kernel not released"
			return
		else
			echo "got next major version"
			CURRENT_MAJOR=$NEXT_MAJOR
			CURRENT_MINOR=0
			echo $CURRENT_MAJOR > ~/.current_major_lkv
			echo $CURRENT_MINOR > ~/.current_minor_lkv
		fi
	else
		echo "got next minor version"
		CURRENT_MINOR=$NEXT_MINOR
		echo $CURRENT_MINOR > ~/.current_minor_lkv
	fi

	#mail -a "Content-type: text/html" -s "Linux_Changes_${CURRENT_MAJOR}.${CURRENT_MINOR}" $EMAIL_ID < /tmp/x.html
	mutt -e "set content_type=text/html" -s "Linux_Changes_${CURRENT_MAJOR}.${CURRENT_MINOR}" $EMAIL_ID < /tmp/x.html
	rm -f /tmp/x.html
}




binary_search()
{
	local  -n array=$1
	local archive_local=$2
	TMP=${array[0]}
	echo $TMP
	local LIST_START=$(echo $TMP | sed 's/^0*//')
	TMP=${array[-1]}
	local LIST_END=$(echo $TMP | sed 's/^0*//')
	LIST_DATE_START=0
	LIST_DATE_END=0

	first=$LIST_START
	last=$LIST_END
	while true
	do
		if [ $first -gt $last ]; then
			break
		fi
		middle=$(( $first + ( $last - $first )/2 ))
		middle6=$(printf %06d $middle)
		wget $archive_local$YEARMONTH/$middle6.html -O /tmp/y.html
		date=`cat /tmp/y.html | grep  "<I>" | grep "</I>" | grep $MON | grep $YEAR | grep -wvi on  | awk '{ print $3 }'`
		if [ $date -gt $DATE ]; then
			last=$(( $middle - 1 ))
		else
			first=$(( $middle + 1 ))
		fi
	done
	#verify that we have what we want
	if [ $last -le $LIST_END ]; then
		if [ $last -ge $LIST_START ]; then
			last6=$(printf %06d $last)
			wget $archive_local$YEARMONTH/$last6.html -O /tmp/y.html
			date=`cat /tmp/y.html | grep  "<I>" | grep "</I>" | grep $MON | grep $YEAR | grep -wvi on  | awk '{ print $3 }'`
			if [ "$date" -eq "$DATE" ]; then
				LIST_DATE_END=$last
			fi
		fi
	fi



	first=$LIST_START
	last=$LIST_END
	while true
	do
		if [ $first -gt $last ]; then
			break
		fi
		middle=$(( $first + ( $last - $first )/2 ))
		middle6=$(printf %06d $middle)
		wget $archive_local$YEARMONTH/$middle6.html -O /tmp/y.html
		date=`cat /tmp/y.html | grep  "<I>" | grep "</I>" | grep $MON | grep $YEAR | grep -wvi on  | awk '{ print $3 }'`
		if [ $date -lt $DATE ]; then
			first=$(( $middle + 1 ))
		else
			last=$(( $middle - 1 ))
		fi
	done
	#verify that we have what we want
	if [ $first -le $LIST_END ]; then
		if [ $first -ge $LIST_START ]; then
			first6=$(printf %06d $first)
			wget $archive_local$YEARMONTH/$first6.html -O /tmp/y.html
			date=`cat /tmp/y.html | grep  "<I>" | grep "</I>" | grep $MON | grep $YEAR | grep -wvi on  | awk '{ print $3 }'`
			if [ "$date" -eq "$DATE" ]; then
				LIST_DATE_START=$first
			fi
		fi
	fi
}

send_mail ()
{
	local archive_local=$1
	local archive_name=$2
	wget $archive_local$YEARMONTH/date.html -O /tmp/x.html
	cat /tmp/x.html | grep "<LI>" |   cut -d "\"" -f 2 | cut -d "." -f 1  > /tmp/out
	readarray -t arr < /tmp/out
	TMP=${arr[0]}
	LIST_START=$(echo $TMP | sed 's/^0*//')
	TMP=${arr[-1]}
	LIST_END=$(echo $TMP | sed 's/^0*//')
	binary_search arr $archive_local
	LIST_DATE_END1=$(( $LIST_DATE_END + 1 ))


	#printf "first $LIST_DATE_START\n"
	#printf "last $LIST_DATE_END\n"
	if [ "$LIST_DATE_START" -ne 0 ]; then
		if [ "$LIST_DATE_END" -ne 0 ]; then
			for (( ii = $LIST_START; ii < $LIST_DATE_START; ii++ ))
			do
				ii6=$(printf %06d $ii)
				sed -i -e "/${ii6}.html/,+4d" /tmp/x.html
			done
			for (( ii = $LIST_DATE_END1; ii <= $LIST_END; ii++ ))
			do
				ii6=$(printf %06d $ii)
				sed -i -e "/${ii6}.html/,+4d" /tmp/x.html
			done
			sed -i "/<HEAD>/a <base href="$archive_local$YEARMONTH\/">" /tmp/x.html
			#mail -a "Content-type: text/html" -s "$2_$DATE_MAIL" $EMAIL_ID < /tmp/x.html
			mutt -e "set content_type=text/html" -s "$2_$DATE_MAIL" $EMAIL_ID < /tmp/x.html
		else
			echo "not sending mail"
		fi
	else
		echo "not sending mail"
	fi
	rm -f /tmp/y.html
	rm -f /tmp/x.html
	rm -f /tmp/out
}

ARCHIVE1="http://lists.infradead.org/pipermail/linux-arm-kernel/"
ARCHIVE1_NAME="linux-arm-kernel"

ARCHIVE2="https://mail.openvswitch.org/pipermail/ovs-dev/"
ARCHIVE2_NAME="ovs-dev"

ARCHIVE3="https://lists.01.org/pipermail/dpdk-ovs/"
ARCHIVE3_NAME="dpdk-ovs"

ARCHIVE4="http://dpdk.org/ml/archives/dev/"
ARCHIVE4_NAME="dpdk"

ARCHIVE5="https://lists.linaro.org/pipermail/lng-odp/"
ARCHIVE5_NAME="odp"

ARCHIVE6="https://lists.iovisor.org/pipermail/iovisor-dev/"
ARCHIVE6_NAME="iovisor-dev"

ARCHIVE7="https://lists.fd.io/pipermail/vpp-dev/"
ARCHIVE7_NAME="vpp-dev"

ARCHIVE8="https://lists.01.org/pipermail/spdk/"
ARCHIVE8_NAME="spdk"

#send_mail  $ARCHIVE7 $ARCHIVE7_NAME
#send_mail  $ARCHIVE6 $ARCHIVE6_NAME
#send_mail  $ARCHIVE5 $ARCHIVE5_NAME
#send_mail  $ARCHIVE3 $ARCHIVE3_NAME
send_mail  $ARCHIVE4 $ARCHIVE4_NAME
#send_mail  $ARCHIVE1 $ARCHIVE1_NAME
#send_mail  $ARCHIVE2 $ARCHIVE2_NAME
#send_mail  $ARCHIVE8 $ARCHIVE8_NAME
# linux kernel mailing list
# send_lkml_daily
# netdev mailing list
# send_netdev_daily
# new kernel releases
# send_linux_kernel_release
