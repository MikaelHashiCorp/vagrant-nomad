#!/usr/bin/env bash
set -euo pipefail

yum -y install \
  bridge-utils \
  qemu-kvm \
  qemu-img \
  virt-manager \
  virt-viewer \
  virt-install \
  libvirt \
  libvirt-client \
  libvirt-python \
  libguestfs-tools \
  irt-install 
