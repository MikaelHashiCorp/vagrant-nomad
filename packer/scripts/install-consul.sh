#!/usr/bin/env bash
set -euo pipefail

# create user
if ! id consul >/dev/null 2>&1; then
  useradd consul
fi

# create dirs
mkdir -p /opt/consul/bin

version="1.9.2"

# install from releases.hashicorp.com
curl -sSL -O \
  "https://releases.hashicorp.com/consul/${version}/consul_${version}_SHA256SUMS"

curl -sSL -O \
  "https://releases.hashicorp.com/consul/${version}/consul_${version}_linux_amd64.zip"

if ! sha256sum --check --ignore-missing "consul_${version}_SHA256SUMS"; then
  echo "failed to verify consul SHA256SUMS"
  exit 1
fi

unzip -d /opt/consul/bin "consul_${version}_linux_amd64.zip"

# set ownership
chown -R consul:consul /opt/consul
