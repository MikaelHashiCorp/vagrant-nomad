#!/usr/bin/env bash
set -euo pipefail

systemctl enable docker
systemctl start docker
