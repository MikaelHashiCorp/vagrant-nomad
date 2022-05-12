set -euo pipefail

yum -y update
yum -y install \
    epel-release \
    zip \
    unzip \
    which \
    vim \
    ca-certificates \
    curl \
    gnupg \
    redhat-lsb-core
