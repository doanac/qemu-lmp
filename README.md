x86 container for running x86 images

## Run the x86 LmP installer
```
#!/bin/sh -e

if [ $# -ne 2 ] ; then
	echo "Usage: $0 <installer.wic> <img.wic>"
	exit 0
fi

installer=$(readlink -f $1)
installerdir=$(dirname $installer)
image=$(readlink -f $2)
imagedir=$(dirname $image)

docker run --rm -it \
    --device=/dev/kvm:/dev/kvm \
    --device=/dev/net/tun:/dev/net/tun \
    --cap-add NET_ADMIN \
    -v $installerdir:$installerdir \
    -v $imagedir:$imagedir\
    --entrypoint /usr/local/bin/install.sh \
    qemu-lmp $installer $image
```

## Run the x86 LmP image produced from above step
```
#!/bin/sh -e

if [ $# -ne 1 ] ; then
	echo "Usage: $0 <file.wic>"
	exit 0
fi

docker run --rm -it \
    --device=/dev/kvm:/dev/kvm \
    --device=/dev/net/tun:/dev/net/tun \
    --cap-add NET_ADMIN \
    -p 2222:22 -p 8888:8888 \
    -v $(readlink -f $1):/image.wic \
    --entrypoint /usr/local/bin/run.sh \
    qemu-lmp /image.wic
```

## Run a vanilla Ubuntu cloud image
```
#!/bin/sh -e

if [ $# -ne 1 ] ; then
	echo "Usage: $0 <file.wic>"
	exit 0
fi

docker run --rm -it \
    --device=/dev/kvm:/dev/kvm \
    --device=/dev/net/tun:/dev/net/tun \
    --cap-add NET_ADMIN \
    -p 2222:22 -p 8888:8888 \
    -v $(readlink -f $1):/image.wic \
    --entrypoint /usr/local/bin/run-ubuntu.sh \
    qemu-lmp /image.wic
```
