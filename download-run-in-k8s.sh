#!/bin/sh -ex

[ -c /dev/kvm ] || (echo "No /dev/kvm"; exit 1)

if [ $# -ne 3 ] ; then
	echo "Usage: $0 <wicfile> <forwarding> <url of img.wic.gz>"
	exit 0
fi

wic=$1
qcow=${wic}.qcow2
export FORWARD="$2"
url=$3
if [ ! -f $qcow ] ; then
	wget $url -O - | gunzip > $wic
	qemu-img create -f qcow2 -F raw -b ${wic} ${qcow}
	qemu-img resize -f qcow2 ${qcow} +2G
fi

mkdir /tmp/host-info
echo ${HOSTNAME}-${CONTAINER_IDX} > /tmp/host-info/host_inf
mkisofs -o /tmp/host-info.iso /tmp/host-info/

qemu-system-x86_64 \
	-device virtio-scsi-pci,id=scsi \
	-device scsi-hd,drive=hd0 \
	-vga vmware \
	-device virtio-rng-pci \
	-drive if=pflash,format=raw,readonly,file=/usr/share/OVMF/OVMF_CODE.fd \
	-vga std \
	-nographic \
	-m 1024 \
	-cpu kvm64 -enable-kvm \
	-serial mon:stdio \
	-serial null \
	-device e1000,netdev=net0 \
	${FORWARD} \
	--drive file=/tmp/host-info.iso,format=raw \
	-drive if=none,id=hd0,file=${qcow},format=qcow2
