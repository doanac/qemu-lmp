#!/bin/sh -e

if [ $# -ne 1 ] ; then
	echo "Usage: $0 <img.wic>"
	exit 0
fi

qemu-system-x86_64 \
	-device virtio-scsi-pci,id=scsi \
	-device scsi-hd,drive=hd0 \
	-vga vmware \
	-device virtio-rng-pci \
	-drive if=pflash,format=raw,readonly,file=/usr/share/OVMF/OVMF_CODE.fd \
	-vga std \
	-nographic \
	-m 512 \
	-cpu kvm64 -enable-kvm \
	-serial mon:stdio \
	-serial null \
	-drive if=none,id=hd0,file=${1},format=raw
