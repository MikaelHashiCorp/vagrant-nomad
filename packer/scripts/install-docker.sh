#!/usr/bin/env bash
set -euo pipefail

# taken from https://docs.docker.com/engine/install/ubuntu/

export DEBIAN_FRONTEND=noninteractive

apt-get update

apt-get install -f -y --no-install-recommends \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg-agent \
  software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

if ! apt-key fingerprint 0EBFCD88 | grep "9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88" >/dev/null; then
  echo "failed to add Docker GPG key"
  exit 1
fi

add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

apt-get update
apt-get install -f -y docker-ce docker-ce-cli containerd.io
