#!/bin/sh
FILE=$1
DIR=$2

if [ -z "$1" ]
then
	echo "first argument is patch file name second argument is project dir name"
	exit
fi

if [ -z "$2" ]
then
	echo "first argument is patch file name second argument is project dir name"
	exit
fi

if [ ! -f "$1" ] 
then
	echo "$1 not found"
        exit
fi

if [ ! -d $2 ]
then
	echo "$2 not a directory"
        exit
fi

rm -rf /tmp/tmpshowdiff
mkdir -p /tmp/tmpshowdiff
cp -ra $2/* /tmp/tmpshowdiff/
cd /tmp/tmpshowdiff; patch -p1 < $1
cd -
meld $2 /tmp/tmpshowdiff
rm -rf /tmp/tmpshowdiff
