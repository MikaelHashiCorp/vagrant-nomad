#!/usr/bin/env bash
set -euo pipefail

# add nomad to docker group
usermod -G docker -a nomad

function stop_nomad() {
  if systemctl list-units | grep nomad >/dev/null; then
    if systemctl status nomad >/dev/null; then
      systemctl stop nomad
    fi
  fi
}

# replace Nomad binary when one given
if [ -f /tmp/nomad ]; then
  # stop running binary so we can replace it
  stop_nomad

  # move the new one over
  mv /tmp/nomad /opt/nomad/bin/nomad
fi

# write nomad config
cat <<EOF > /opt/nomad/config.hcl
name = "$NAME"

advertise {
  http = "$ADVERTISE_ADDR"
  rpc  = "$ADVERTISE_ADDR"
  serf = "$ADVERTISE_ADDR"
}

server_join {
  retry_join = $RETRY_JOIN
  retry_max = 15
  retry_interval = "3s"
}

leave_on_interrupt = true
leave_on_terminate = true

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

# daemon-reload didn't work here; systemd fails to start a replaced Nomad
# binary with 217/USER unless we use daemon-reexec. :shrug:
systemctl daemon-reexec

# (re)start nomad
systemctl restart nomad
