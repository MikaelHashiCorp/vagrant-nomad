#!/usr/bin/env bash
set -euo pipefail

# taken from https://docs.docker.com/engine/install/centos/

sudo yum update

sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

sudo yum -y install docker-ce docker-ce-cli containerd.io

# add auto completion for docker
sudo curl -fsSL https://raw.githubusercontent.com/docker/compose/1.29.2/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose

# docker post installation
usermod -aG docker vagrant
