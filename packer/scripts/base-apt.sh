#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update

apt-get install -f -y --no-install-recommends \
  curl \
  unzip \
  ca-certificates

apt-get -f -y dist-upgrade
