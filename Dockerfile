FROM ubuntu:20.04

RUN apt update && apt install -y qemu-system-x86 ovmf wget cloud-image-utils openssh-client

COPY ./install.sh /usr/local/bin
COPY ./run.sh /usr/local/bin
COPY ./run-ubuntu.sh /usr/local/bin
COPY ./download-run.sh /usr/local/bin
COPY ./download-run-in-k8s.sh /usr/local/bin

ENTRYPOINT /usr/local/bin/run.sh
