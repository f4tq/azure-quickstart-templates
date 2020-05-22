#!/bin/bash
# -------

# install docker & kubeadm - ubuntu
# ---------------------------------


# setup params given to sh script
CLIENT_ID=$1
CLIENT_SECRET=$2
RESOURCE_GROUP=$3
SUB=$4
TENANT=$5
RG_LOCATION=$6
TARGET_URL=$7
VNET_NAME=$8
MASTER_IP=$9

installDeps() {
    # update and upgrade packages
    apt-get update && apt-get upgrade -y

    # install docker
    apt-get install -y docker.io dnsmasq python-pip htop

    # install kubeadm
    apt-get install -y apt-transport-https

    pip install locustio==v0.13.4
}

createConfigFiles() {
    # Write a sample provider JSON (This won't work but values are needed in the fields)
mkdir -p /etc/systemd/system
cat >/etc/systemd/system/locust-agent1.service <<EOL
[Unit]
Description=Locust Agent

[Service]
Type=exec
LimitNOFILE=1048576
TimeoutStartSec=30
TimeoutStopSec=10
RestartSec=30
Restart=always
ExecStartPre=/usr/bin/docker pull docker.io/f4tq/low-boom:latest
ExecStart=/bin/bash -c "exec docker run --net=host -e CORES=1 -e CORE_START=0 -e LOCUST_MASTER=tcp://$MASTER_IP:5557    -e TARGET_URL='$TARGET_URL' \
 -e LOCAL_HOSTNAME=$(hostname) docker.io/f4tq/low-boom:latest --disable-keepalive --timeout 60s --ping-weight 75 --delay-weight 72 --upload-weight 1 --download-weight 2 --max-conns-per-host 15000 "

[Install]
WantedBy=multi-user.target
EOL

chgrp root /etc/systemd/system/locust-agent1.service
chmod 000644 /etc/systemd/system/locust-agent1.service
chown root /etc/systemd/system/locust-agent1.service

systemctl daemon-reload
systemctl enable locust-agent1.service

}


installDeps
createConfigFiles

systemctl start locust-agent1.service
