#!/bin/bash
DATE_MAIL=`date --date="2 days ago" +%Y/%m/%d`
TMP=`date --date="2 days ago" +%d`
DATE=$(echo $TMP | sed 's/^0*//')
MON=`date --date="2 days ago" +%b`
YEAR=`date --date="2 days ago" +%Y`
YEARMONTH=`date --date="2 days ago" +%Y-%B`
EMAIL_ID="sburla@caviumnetworks.com"

#netdev
send_netdev_daily()
{
	wget http://lists.openwall.net/netdev/${DATE_MAIL} -O /tmp/x.html
	sed -i "/<head>/a <base href=\" http:\/\/lists.openwall.net\/netdev\/${DATE_MAIL}\/\">" /tmp/x.html
	mail -a "Content-type: text/html" -s "netdev-digest_${DATE_MAIL}" $EMAIL_ID < /tmp/x.html
	rm -f /tmp/x.html
}

#lkml
send_lkml_daily()
{
	wget https://lkml.org/lkml/${DATE_MAIL} -O /tmp/x.html
	sed -i "s#<head>#<head><base href=\" https://lkml.org/\">#" /tmp/x.html
	mail -a "Content-type: text/html" -s "lkml-digest_${DATE_MAIL}" $EMAIL_ID < /tmp/x.html
	rm -f /tmp/x.html
}




# Linux kernel changes.  
send_linux_kernel_release()
{
	CURRENT_MAJOR=`cat /home/satanand/.current_major_lkv`
	CURRENT_MINOR=`cat /home/satanand/.current_minor_lkv`
	NEXT_MAJOR=`expr $CURRENT_MAJOR + 1`
	NEXT_MINOR=`expr $CURRENT_MINOR + 1`

	echo "getting  Linux_${CURRENT_MAJOR}.${NEXT_MINOR}.0"
	wget https://kernelnewbies.org/Linux_${CURRENT_MAJOR}.${NEXT_MINOR} -O /tmp/x.html
	if [ ! -s /tmp/x.html ]; then
		echo "could not find next minor"
		# try next major
		echo "getting  Linux_${NEXT_MAJOR}.0"
		wget https://kernelnewbies.org/Linux_${NEXT_MAJOR}.0 -O /tmp/x.html
		if [ ! -s /tmp/x.html ]; then
			echo "new kernel not released"
			return
		else
			echo "got next major version"
			CURRENT_MAJOR=$NEXT_MAJOR
			CURRENT_MINOR=0
			echo $CURRENT_MAJOR > /home/satanand/.current_major_lkv
			echo $CURRENT_MINOR > /home/satanand/.current_minor_lkv
		fi
	else
		echo "got next minor version"
		CURRENT_MINOR=$NEXT_MINOR
		echo $CURRENT_MINOR > /home/satanand/.current_minor_lkv
	fi

	mail -a "Content-type: text/html" -s "Linux_Changes_${CURRENT_MAJOR}.${CURRENT_MINOR}" $EMAIL_ID < /tmp/x.html
	rm -f /tmp/x.html
}




binary_search()
{
	local -n array=$1
	local archive_local=$2
	TMP=${array[0]}
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
			mail -a "Content-type: text/html" -s "$2_$DATE_MAIL" $EMAIL_ID < /tmp/x.html
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

send_mail  $ARCHIVE6 $ARCHIVE6_NAME
send_mail  $ARCHIVE5 $ARCHIVE5_NAME
send_mail  $ARCHIVE3 $ARCHIVE3_NAME
send_mail  $ARCHIVE4 $ARCHIVE4_NAME
send_mail  $ARCHIVE1 $ARCHIVE1_NAME
send_mail  $ARCHIVE2 $ARCHIVE2_NAME
send_lkml_daily
send_netdev_daily
send_linux_kernel_release
