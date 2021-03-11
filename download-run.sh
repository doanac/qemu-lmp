#!/bin/sh -e

if [ $# -ne 2 ] ; then
	echo "Usage: $0 <wicfile> <url of img.wic.gz>"
	exit 0
fi

wic=$1
url=$2
if [ ! -f $wic ] ; then
	wget $url -O - | gunzip > $wic
fi
echo "Running ..."
run.sh $wic
