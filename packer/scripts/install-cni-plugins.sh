#!/usr/bin/env bash
set -euo pipefail

if [ -d /opt/cni/bin ]; then
  return
fi

version="0.8.1"
url="https://github.com/containernetworking/plugins/releases/download/v${version}/cni-plugins-linux-amd64-v${version}.tgz"

mkdir -p /opt/cni/bin

curl -sSL "$url" | tar -C /opt/cni/bin -xzf -
