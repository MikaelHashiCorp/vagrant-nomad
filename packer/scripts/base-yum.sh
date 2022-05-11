set -euo pipefail

yum update
yum install -y \
    epel-release \
    zip \
    unzip \
    which \
    vim \
    ca-certificates \
    curl \
    gnupg \
    redhat-lsb-core