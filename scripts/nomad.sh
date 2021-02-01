#!/usr/bin/env bash
set -euo pipefail

# add nomad to docker group
usermod -G docker -a nomad

# write nomad config
cat <<EOF > /opt/nomad/config.hcl
name = "$NAME"

advertise {
  http = "$ADVERTISE_ADDR"
  rpc  = "$ADVERTISE_ADDR"
  serf = "$ADVERTISE_ADDR"
}

EOF

: ${SERVER:=''}

if [ -n "$SERVER" ]; then
  cat <<EOF >> /opt/nomad/config.hcl
server {
  enabled = true
  bootstrap_expect = $BOOTSTRAP_EXPECT
}
EOF
else
  cat <<EOF >> /opt/nomad/config.hcl
client {
  enabled = true
  server_join {
    retry_join = $RETRY_JOIN
    retry_max = 15
    retry_interval = "15s"
  }
}
EOF
fi

# write systemd config
cat <<EOF > /etc/systemd/system/nomad.service
[Unit]
Description="HashiCorp Nomad"
Documentation=https://www.nomadproject.io/
After=consul.service docker.service network-online.target

[Service]
Type=simple
User=nomad
Group=nomad
ExecStart=/opt/nomad/bin/nomad agent -config /opt/nomad/config.hcl -data-dir /opt/nomad/data
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
EOF


systemctl daemon-reload
systemctl restart nomad
