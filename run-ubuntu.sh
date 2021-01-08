#!/bin/sh -e
# can run an ubuntu cloud image

if [ $# -ne 1 ] ; then
	echo "Usage: $0 <img.wic>"
	exit 0
fi

cat >/config.txt <<EOF
#cloud-config
users:
  - name: ubuntu
    plain_text_password: ubuntu
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    groups: sudo
    shell: /bin/bash
    ssh-authorized-keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5/7YZKEQxuPeRUBL6pKgdUWyORAkCcv0UoKfgoR5V54Xln2YMdn3G4+Nv+njNbKMJ4dbjyaq5VG/+LvaI5vMf/KRd0e+1m8ROgysFXYGbbGxoAZZmEPGLxCSpZGl4bHEjGu+VhnMueYmtFvCn7re9/TUso9EfLA9DS66/BbxjX2MpgFBF6jh/hg92ANQdZmzH1Bb0zQ0q0XM0+100EAGpCXzFTvM19/6iX4cI3P+4zi7yCcxRV6UrRcw35MGCJR+uYVymx1WaK5P1l4Ea0XTn3WDdEvWzInLNFzz6XYxiBvauMW9bf9s1erVZ53HhupADw+ieEweVJlflOTDxs0dP
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIF9CuMLzAvZaEn3P3Ikn2bB2eV0D2VVoKz1k79tuXhX
EOF

cloud-localds --disk-format qcow2 /cloud.img /config.txt

qemu-system-x86_64 \
	-device virtio-scsi-pci,id=scsi \
	-device scsi-hd,drive=image \
	-device scsi-hd,drive=cloud \
	-vga vmware \
	-device virtio-rng-pci \
	-drive if=pflash,format=raw,readonly,file=/usr/share/OVMF/OVMF_CODE.fd \
	-vga std \
	-nographic \
	-m 512 \
	-cpu kvm64 -enable-kvm \
	-serial mon:stdio \
	-serial null \
	-device e1000,netdev=net0 \
	-netdev user,id=net0,hostfwd=tcp::22-:22,hostfwd=::8888-:8888 \
	-drive if=none,id=cloud,file=/cloud.img \
	-drive if=none,id=image,file=${1}
