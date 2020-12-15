#!/bin/sh -e

if [ $# -ne 1 ] ; then
	echo "Usage: $0 <url of img.wic.gz>"
	exit 0
fi

wget $1 -O - | gunzip > /tmp/img.wic
echo "Running ..."
run.sh /tmp/img.wic
