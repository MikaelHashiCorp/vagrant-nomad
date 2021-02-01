Vagrant.configure("2") do |config|
  server_count = 1
  client_count = 1
  # server(s)
  1.upto(server_count) do |n|
    ip = "10.199.0.%d" % [10 * n]
    name = "nomad-server-%02d" % n

    config.vm.define name, autostart: true do |output|
      output.vm.box = "packer_vagrant"
      output.vm.box_url = "file://package.box"
      output.vm.network :private_network, ip: ip
      output.vm.provision "shell",
        name: "consul",
        path: "scripts/consul.sh",
        env: {
          BOOTSTRAP_EXPECT: server_count,
          BIND_ADDR_CIDR: "%s/24" % ip
        }

      output.vm.provision "shell",
        name: "nomad",
        path: "scripts/nomad.sh",
        env: {
          BOOTSTRAP_EXPECT: server_count,
          ADVERTISE_ADDR: ip
        }
    end
  end

  # clients
  1.upto(client_count) do |n|
    ip = "10.199.1.%d" % [10 * n]
    name = "nomad-client-%02d" % n

    config.vm.define name, autostart: true do |output|
      output.vm.box = "packer_vagrant"
      output.vm.box_url = "file://package.box"
      output.vm.network :private_network, ip: ip
      output.vm.provision "shell", name: "consul config", inline: <<EOF
# write Consul config
mkdir -p /opt/consul/{config,data}
chown consul:consul /opt/consul/{config,data}
cat <<FOE > /opt/consul/config/server.hcl
datacenter = "vagrant"
data_dir = "/opt/consul/data"
log_level = "INFO"
client_addr = "0.0.0.0"
bind_addr = "{{ GetPrivateInterfaces | include \\"network\\" \\"10.199.1.0/24\\" | attr \\"address\\" }}"
retry_join = ["10.199.0.10"]
node_name = "client01"
FOE

# write Consul systemd config
cat <<FOE > /etc/systemd/system/consul.service
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target

[Service]
Type=simple
User=consul
Group=consul
ExecStart=/opt/consul/bin/consul agent -config-dir /opt/consul/config
ExecReload=/opt/consul/bin/consul reload
KillMode=process
Restart=on-failure
TimeoutSec=300s
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
FOE
EOF
      output.vm.provision "shell", name: "nomad config", inline: <<EOF
# write nomad config
mkdir -p /opt/nomad/config
chown nomad:nomad /opt/nomad/config
cat <<FOE > /opt/nomad/config/client.hcl
name = "client01"
advertise {
  http = "10.199.1.10"
  rpc  = "10.199.1.10"
  serf = "10.199.1.10"
}
client {
  enabled = true
  server_join {
    retry_join = ["10.199.0.10:4647"]
    retry_max = 15
    retry_interval = "15s"
  }
}
FOE

# write systemd config
cat <<FOE > /etc/systemd/system/nomad.service
[Unit]
Description="HashiCorp Nomad"
Documentation=https://www.nomadproject.io/
After=consul.service docker.service network-online.target
ConditionFileNotEmpty=/opt/nomad/config/client.hcl

[Service]
Type=simple
User=nomad
Group=nomad
ExecStart=/opt/nomad/bin/nomad agent -config /opt/nomad/config/client.hcl -data-dir /opt/nomad/data
ExecReload=/bin/kill -HUP \$MAINPID
KillMode=process
KillSignal=SIGINT
Restart=on-failure
RestartSec=2
StartLimitBurst=3
TimeoutSec=300s
LimitNOFILE=infinity
LimitNPROC=infinity
TasksMax=infinity
OOMScoreAdjust=-1000

[Install]
WantedBy=multi-user.target
FOE
EOF

      output.vm.provision "shell", name: "(re)start services", inline: <<EOF
sudo usermod -G docker -a nomad
systemctl enable nomad consul docker
systemctl daemon-reload
systemctl start docker
systemctl restart consul
systemctl restart nomad
EOF
    end
  end

  config.vm.synced_folder ".", "/vagrant", disabled: true
end