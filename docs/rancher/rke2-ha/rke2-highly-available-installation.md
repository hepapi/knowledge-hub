# Deploy RKE2 Highly Available Cluster

## Prerequisites

| a             | b   | c                                                                      |
| ------------- | --- | ---------------------------------------------------------------------- |
| 3 Linux Hosts |     | [RKE2 System Requirements](https://docs.rke2.io/install/requirements/) |

## Prepare the hosts

**[ATTENTION]: Do this on all of the master nodes**

**1)** Become root

```bash
sudo su
```

**2)** Install the OS dependencies

```bash
apt update -y && apt upgrade -y

systemctl disable --now ufw
apt install nfs-common jq libselinux1 curl apparmor-profiles -y
apt autoremove -y

apparmor_status # check if apparmor is running
```

## MASTER NODES

### MASTER NODE 1

**Notes**

**[ATTENTION]** Run this steps on the **first master node**.

**Steps**

**1)** **[ATTENTION]** Set the Installation Parameters. Select your version of RKE2 and the type of installation.

```bash
# set the RKE2 environment variables
export DEBUG=1 # enable debug messages for rke2 scripts
export INSTALL_RKE2_VERSION="v1.21.7+rke2r2" # `latest` or `stable` works as well
export INSTALL_RKE2_TYPE="server"  # server for master nodes
```

**2)** Create RKE2 Configuration File: `/etc/rancher/rke2/config.yaml`

```bash
mkdir -p /etc/rancher/rke2/ # create the directory if not exists

# create the rke2 configuration file
cat << EOF >> /etc/rancher/rke2/config.yaml
kube-apiserver-arg: "kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname"


# ---------------- OPTIONAL CONFIGURATION BELOW ----------------
# ---- Uncomment & Change the lines below to enable the configuration ----

# ------ OPTION: Node Labels ------
#node-label:
#- other=what
#- foo=three

# ------ OPTION: ETCD Automatic Backups Cronjob ------
# This configuration will take snapshots every 5 mins.
# and keep the last 40 snapshots. For help: https://crontab.guru/
etcd-snapshot-schedule-cron: '*/5 * * * *'
etcd-snapshot-retention: 40


# ------ OPTION: ETCD Automatic Backups Upload to S3 Storage ------
# Note: Doing S3 Upload configuration only on the first master node is enough

#etcd-s3: true
#etcd-s3-endpoint: "s3.amazonaws.com"
#etcd-s3-access-key: "AKIAAAAAAAAAAAAAAAA"
#etcd-s3-secret-key: "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"
#etcd-s3-region: "eu-central-1"
#etcd-s3-bucket: "---my-s3-bucket-where-i-store-etcd-backups"
#etcd-s3-folder: "---myclustername-etcd-backups-folder/"


# ------ OPTION: Control Plane Resource Requests and Limits ------
#https://docs.rke2.io/advanced#control-plane-component-resource-requestslimits
#control-plane-resource-requests:
#- kube-apiserver-cpu=500m
#- kube-apiserver-memory=512M
#- kube-scheduler-cpu=250m
#- kube-scheduler-memory=512M
#- etcd-cpu=1000m
EOF

# ATTENTION: check if the configuration file is valid
cat /etc/rancher/rke2/config.yaml
```

**3)** Install RKE2

```bash
# run the install script and save the output to a log file
./rke2_install_script.sh
# IMPORTANT: copy the output to a log file


# persist path and kubeconfig configuration
echo 'export PATH=$PATH:/var/lib/rancher/rke2/bin KUBECONFIG=/etc/rancher/rke2/rke2.yaml' >> ~/.bashrc
source ~/.bashrc
```

**4)** Start the `rke2-server`

```bash
systemctl enable rke2-server.service
systemctl start rke2-server.service
```

**5)** Wait for `rke2-server` to become available

```bash
# check the status of the service
systemctl status rke2-server.service

# check the logs
journalctl -u rke2-server -f # follow logs
```

**6)** **[ATTENTION]** Copy `node-token` to a safe place for joining other master nodes later on

```bash
cat /var/lib/rancher/rke2/server/node-token
# output should look like this:
# K10b2896e9397d199b72da45ddc91c2449b27caa4155d36cd8f5dfe679c7b0f0b25::server:ddb937957cd932c74e496059dd1e0f03
```

### MASTER NODE 2 & 3

**Prerequisites**

| Required | Name                   | Description                                          |
| :------: | ---------------------- | ---------------------------------------------------- |
|    ✅    | `MASTER_IP`            | Static endpoint for the first master node            |
|    ✅    | `MASTER_NODE_TOKEN`    | Should get this from first master node installation  |
|    ✅    | `INSTALL_RKE2_VERSION` | The RKE2 release version that you want to upgrade to |

**Notes**

**[ATTENTION]** Run this steps on the **second and third master node**.

**Steps**

**1)** **[ATTENTION]** Set the Prerequisites.
```bash
export MASTER_IP="172.31.15.113" # TODO: change this to your master-1 IP
export MASTER_NODE_TOKEN="K10b2896e9397d199b72da45ddc91c2449b27caa4155d36cd8f5dfe679c7b0f0b25::server:ddb937957cd932c74e496059dd1e0f03"
```
**2)** **[ATTENTION]** Set the Installation Parameters. Select your version of RKE2 and the type of installation.
```bash
# set the RKE2 environment variables
export DEBUG=1 # enable debug messages for rke2 scripts
export INSTALL_RKE2_VERSION="v1.21.7+rke2r2" # `latest` or `stable` works as well
export INSTALL_RKE2_TYPE="server"  # server for master nodes
```
**3)** Create RKE2 Configuration File: `/etc/rancher/rke2/config.yaml`

```bash
mkdir -p /etc/rancher/rke2/ # create the directory if not exists

# create the rke2 configuration file
# IMPORTANT
cat << EOF >> /etc/rancher/rke2/config.yaml
server: https://$MASTER_IP:9345
token: $MASTER_NODE_TOKEN

# ---------------- OPTIONAL CONFIGURATION BELOW ----------------
# ---- Uncomment & Change the lines below to enable the configuration ----

# ------ OPTION: Node Labels ------
#node-label:
#- other=what
#- foo=three

# ------ OPTION: ETCD Automatic Backups Cronjob ------
# This configuration will take snapshots every 5 mins.
# and keep the last 40 snapshots. For help: https://crontab.guru/
etcd-snapshot-schedule-cron: '*/5 * * * *'
etcd-snapshot-retention: 40


# ------ OPTION: ETCD Automatic Backups Upload to S3 Storage ------
# Note: Doing S3 Upload configuration only on the first master node is enough


# ------ OPTION: Control Plane Resource Requests and Limits ------
#https://docs.rke2.io/advanced#control-plane-component-resource-requestslimits
#control-plane-resource-requests:
#- kube-apiserver-cpu=500m
#- kube-apiserver-memory=512M
#- kube-scheduler-cpu=250m
#- kube-scheduler-memory=512M
#- etcd-cpu=1000m
EOF


# ATTENTION: check if the configuration file is valid
cat /etc/rancher/rke2/config.yaml
```

**4)** Install RKE2

```bash
# run the install script and save the output to a log file
./rke2_install_script.sh
# IMPORTANT: copy the output to a log file


# persist path and kubeconfig configuration
echo 'export PATH=$PATH:/var/lib/rancher/rke2/bin KUBECONFIG=/etc/rancher/rke2/rke2.yaml' >> ~/.bashrc
source ~/.bashrc
```

**5)** Start the `rke2-server`
```bash
systemctl enable rke2-server.service
systemctl start rke2-server.service
```
**6)** Wait for `rke2-server` to become available

```bash
# check the status of the service
systemctl status rke2-server.service

# check the logs
journalctl -u rke2-server -f # follow logs
```

## Adding Worker Nodes

TODO: add docs
