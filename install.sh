#!/bin/sh -e

if [ $# -ne 2 ] ; then
	echo "Usage: $0 <installer.wic> <data.wic>"
	exit 0
fi

qemu-img create -f raw $2 8G

qemu-system-x86_64 \
	-device virtio-scsi-pci,id=scsi \
	-device scsi-hd,drive=hd0 \
	-device scsi-hd,drive=hd1 \
	-vga vmware \
	-device virtio-rng-pci \
	-drive if=pflash,format=raw,readonly,file=/usr/share/OVMF/OVMF_CODE.fd \
	-vga std \
	-nographic \
	-m 512 \
	-cpu kvm64 -enable-kvm \
	-serial mon:stdio \
	-serial null \
	-drive if=none,id=hd0,file=${1},format=raw \
	-drive if=none,id=hd1,file=${2},format=raw
