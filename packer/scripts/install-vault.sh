#!/usr/bin/env bash
set -euo pipefail

# create user
if ! id vault >/dev/null 2>&1; then
  useradd vault
fi

# create dirs
mkdir -p /opt/vault/bin

version="1.10.2"

# install from releases.hashicorp.com
curl -sSL -O \
  "https://releases.hashicorp.com/vault/${version}/vault_${version}_SHA256SUMS"

curl -sSL -O \
  "https://releases.hashicorp.com/vault/${version}/vault_${version}_linux_amd64.zip"

# if [[! sha256sum --check "vault_${version}_SHA256SUMS" 2>/dev/null | grep OK$ == *"OK"*]] ; then
#   echo "failed to verify vault SHA256SUMS"
#   exit 1
# fi

unzip -d /opt/vault/bin "vault_${version}_linux_amd64.zip"

# set ownership
chown -R vault:vault /opt/vault
