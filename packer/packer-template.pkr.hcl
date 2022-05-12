packer {
  required_plugins {
    vagrant = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}

source "vagrant" "centos-7" {
  add_force    = true
  box_name     = "nomad-centos-7"
  communicator = "ssh"
  provider     = "virtualbox"
  source_path  = "bento/centos-7.9"
}

build {
  sources   = ["source.vagrant.centos-7"]

  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    scripts         = [ "scripts/base-yum.sh", 
                        "scripts/install-cni-plugins.sh", 
                        "scripts/install-docker.sh", 
                        "scripts/install-java.sh", 
                        "scripts/install-qemu.sh", 
                        "scripts/install-nomad.sh", 
                        "scripts/install-consul.sh", 
                        "scripts/install-vault.sh", 
                        "scripts/install-glibc.sh", 
                        "scripts/cleanup.sh"]
  }

  post-processor "vagrant" {
    # keep_input_artifact = true
    # provider_override   = "virtualbox"
  }
}
