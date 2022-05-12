#!/usr/bin/env bash
set -euo pipefail

# create user
if ! id consul >/dev/null 2>&1; then
  useradd consul
fi

# create dirs
mkdir -p /opt/consul/bin

version="1.12.0"

# install from releases.hashicorp.com
curl -sSL -O \
  "https://releases.hashicorp.com/consul/${version}/consul_${version}_SHA256SUMS"

curl -sSL -O \
  "https://releases.hashicorp.com/consul/${version}/consul_${version}_linux_amd64.zip"

# if [[! sha256sum --check "consul_${version}_SHA256SUMS" 2>/dev/null | grep OK$ == *"OK"*]] ; then
#   echo "failed to verify consul SHA256SUMS"
#   exit 1
# fi

unzip -o -d /opt/consul/bin "consul_${version}_linux_amd64.zip"

# set ownership
chown -R consul:consul /opt/consul
