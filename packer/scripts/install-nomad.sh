#!/usr/bin/env bash
set -euo pipefail

# create user
if ! id nomad >/dev/null 2>&1; then
  useradd nomad
fi

# create dirs
mkdir -p /opt/nomad/bin

version="1.2.6"

# install from releases.hashicorp.com
curl -sSL -O \
  "https://releases.hashicorp.com/nomad/${version}/nomad_${version}_SHA256SUMS"

curl -sSL -O \
  "https://releases.hashicorp.com/nomad/${version}/nomad_${version}_linux_amd64.zip"

# if [[! sha256sum --check "nomad_${version}_SHA256SUMS" 2>/dev/null | grep OK$ == *"OK"*]] ; then
#   echo "failed to verify nomad SHA256SUMS"
#   exit 1
# fi

unzip -o -d /opt/nomad/bin "nomad_${version}_linux_amd64.zip"

# set ownership
chown -R nomad:nomad /opt/nomad

# Add nomad to docker
usermod -aG docker nomad 
