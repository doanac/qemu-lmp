#!/bin/sh -ex

if [ $# -ne 3 ] ; then
	echo "Usage: $0 <wicfile> <forwarding> <url of img.wic.gz>"
	exit 0
fi

wic=$1
export FORWARD="$2"
url=$3
if [ ! -f $wic ] ; then
	wget $url -O - | gunzip > $wic
fi
echo "Running ..."
run.sh $wic
