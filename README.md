# Vagrant-Nomad

## About
### This is the CentOS 7.9 version

This repo can be used to bring up a Nomad cluster playground. This is an
alternative to running `nomad agent -dev`, which creates a unified
server/client that runs fully in-memory. The Vagrantfile in this repo creates
VMs that are configured as solely servers or clients, making them more realistic.

By default, one each of server and client VMs will be created, each running a Nomad and
Consul agent appropriate for the VM that was created. The number of servers and
clients can be changed via the `server_count` and `client_count` variables in
the Vagrantfile. For servers, only 1, 3, or 5 is appropriate.

The Nomad cluster is fully-featured, supporting all of the default task
drivers, including:
* docker
* exec
* java
* qemu
* raw_exec

The servers are all created in the 10.199.0.0/24 CIDR, and the clients within 10.199.1.0/24.

All Nomad and Consul configuration is generated in `scripts/nomad.sh` and
`scripts/consul.sh`, respectively.

## Usage

1. Clone this repo
1. With this repo as your current working directory:
    ```
    vagrant up
    ```
1. Access the Nomad web UI:
    ```
    export NOMAD_ADDR=http://10.199.0.10:4646
    nomad ui
    ```

## Using a custom Nomad binary

If you wish to use a custom Nomad binary, place it in the root directory prior
to running `vagrant up`. If you have already brought up the environment, run
`vagrant up --provision` to update running instances. **Note: This hasn't been
well-tested yet, so you may have to recreate the VMs. Also, downgrades
_definitely_ haven't been tested, and should be avoided.**

## Features
- [x] Consul
- [x] Consul ACLs (`./add-consul-acl.sh`)
- [ ] Vault
- [ ] AWS target
- [ ] CSI
- [ ] Podman task driver
