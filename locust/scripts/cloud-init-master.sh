#!/bin/bash
# -------

# install docker & kubeadm - ubuntu
# ---------------------------------

KUBEADM_TOKEN='8f07c4.2fa8f9e48b6d4036'
KUBE_VERSION='1.17.3-00' # specify version of kubeadm, kubelet and kubectl
KUBE_CA_VERSION='v1.17.1' # specify version of kubernetes cluster-autoscaler

# setup params given to sh script
CLIENT_ID=$1
CLIENT_SECRET=$2
RESOURCE_GROUP=$3
SUB=$4
TENANT=$5
MASTER_IP=$6
TARGET_URL=$7

installDeps() {
    # update and upgrade packages
    apt-get update && apt-get upgrade -y

    # install docker
    apt-get install -y docker.io dnsmasq python-pip htop

    # install kubeadm
    apt-get install -y apt-transport-https

    pip install locustio==v0.13.4
}


setupLoadTest(){
cat > /home/ubuntu/load.py <<EOF
from locust import HttpLocust, TaskSet


class UserBehavior(TaskSet):
    tasks = {}


class WebsiteUser(HttpLocust):
    task_set = UserBehavior

EOF
chown ubuntu:ubuntu /home/ubuntu/load.py
chmod 000644 /home/ubuntu/load.py
}

setupLocustMaster() {
mkdir -p /etc/systemd/system
cat >/etc/systemd/system/locust-master.service <<EOL
[Unit]
Description=Locust Master

[Service]
TimeoutStartSec=2
TimeoutStopSec=2
RestartSec=60
User=root
Restart=always

ExecStart=/usr/local/bin/locust \
    -f /home/ubuntu/load.py \
    --host='$TARGET_URL' \
    --master \
    --port=80

[Install]
WantedBy=multi-user.target
EOL

chgrp root /etc/systemd/system/locust-master.service
chmod 000644 /etc/systemd/system/locust-master.service
chown root /etc/systemd/system/locust-master.service

systemctl daemon-reload
systemctl enable locust-master.service
}


#install flow
installDeps
setupLoadTest
setupLocustMaster

systemctl start locust-master.service

