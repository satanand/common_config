#!/bin/sh
PATCH=$1
BRANCH=$2
REPO=$3

if [ -z "$1" ]
then
	echo "first argument is patch"
	exit
fi

if [ -z "$2" ]
then
	echo "second argument is branch"
	exit
fi

if [ -z "$3" ]
then
	REPO="git://cagit1/liquidio/liquidio.git"	
fi


if [ ! -f "$1" ] 
then
	echo "$1 not found"
        exit
fi


rm -rf /tmp/tmpshowdiff
mkdir -p /tmp/tmpshowdiff
cd /tmp/tmpshowdiff && {
	git clone $REPO
	DIR=`ls`
	cd $DIR && {
		git checkout $BRANCH
		patch -p1 < $PATCH
		git difftool -D HEAD
	}
}
rm -rf /tmp/tmpshowdiff
