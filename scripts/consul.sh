#!/usr/bin/env bash
set -euo pipefail

mkdir -p /opt/consul/data
chown consul:consul /opt/consul/data

# write config
cat <<EOF > /opt/consul/config.hcl
datacenter       = "vagrant"
data_dir         = "/opt/consul/data"
log_level        = "INFO"
client_addr      = "0.0.0.0"
ui               = true
bind_addr        = "{{ GetPrivateInterfaces | include \\"network\\" \\"$BIND_ADDR_CIDR\\" | attr \\"address\\" }}"
EOF

: ${SERVER:=''}

if [ -n "$SERVER" ]; then
  cat <<EOF >> /opt/consul/config.hcl
server           = $SERVER
bootstrap_expect = $BOOTSTRAP_EXPECT
EOF
else
  cat <<EOF >> /opt/consul/config.hcl
retry_join       = $RETRY_JOIN
node_name        = "$NODE_NAME"
EOF
fi

# write systemd config
cat <<EOF > /etc/systemd/system/consul.service
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target

[Service]
Type=simple
User=consul
Group=consul
ExecStart=/opt/consul/bin/consul agent -config-dir /opt/consul
ExecReload=/opt/consul/bin/consul reload
KillMode=process
Restart=on-failure
TimeoutSec=300s
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# reload and restart
systemctl daemon-reload
systemctl restart consul
