## Vault Installation - Using Helm and running on Kubernetes Clsuter

-  [�� Vault Helm Installation repo](https://artifacthub.io/packages/helm/hashicorp/vault)

### Add Helm Repository

```bash
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
```

### Create Namespace
- Create the argocd namespace if it doesn't exist:

```bash
kubectl create namespace vault
```

### Install (Using Helm)
- Install Vault with your custom ext-vault-values.yaml:

- Example `ext-vault-values.yaml` 

```bash
vi ext-vault-values.yaml
```

```yaml
global:
  enabled: true
  namespace: ""
injector:
  enabled: true
  replicas: 1
  port: 8080
  resources: {}
  # resources:
  #   requests:
  #     memory: 256Mi
  #     cpu: 250m
  #   limits:
  #     memory: 256Mi
  #     cpu: 250m
  nodeSelector: {}
server:
  ingress:
    enabled: false
    annotations: {}
    ingressClassName: ""
    pathType: Prefix
    activeService: true
    hosts:
      - host: chart-example.local
        paths: []
    tls: []
  dataStorage:
    enabled: true
    # Size of the PVC created
    size: 1Gi
    # Location where the PVC will be mounted.
    mountPath: "/vault/data"
    # Name of the storage class to use.  If null it will use the
    # configured default Storage Class.
    storageClass: 
    # Access Mode of the storage device being used for the PVC
    accessMode: ReadWriteOnce
    # Annotations to apply to the PVC
    annotations: {}
    # Labels to apply to the PVC
    labels: {}
  affinity: {}
  ha:
    enabled: true
    replicas: 3
    raft: 
      enabled: true
    config: |
      ui = true

      listener "tcp" {
        tls_disable = 1
        address = "[::]:8200"
        cluster_address = "[::]:8201"
      }
      storage "raft" {
          path = "/vault/data"

          retry_join {
            leader_api_addr = "http://vault-0.vault-internal:8200"
          }
          retry_join {
            leader_api_addr = "http://vault-1.vault-internal:8200"
          }
          retry_join {
            leader_api_addr = "http://vault-2.vault-internal:8200"
          }
        }

      service_registration "kubernetes" {}
ui:
  enabled: true
  publishNotReadyAddresses: true
  # The service should only contain selectors for active Vault pod
  activeVaultPodOnly: false
  serviceType: "ClusterIP"
  serviceNodePort: null
  externalPort: 8200
  targetPort: 8200
csi:
  enabled: false
  image:
    repository: "hashicorp/vault-csi-provider"
    tag: "1.5.0"
    pullPolicy: IfNotPresent
serverTelemetry:
  serviceMonitor:
    enabled: false
  prometheusRules:
    enabled: false
```

```bash
helm upgrade --install vault hashicorp/vault --version 0.30.0 -f ext-vault-values.yaml ## change or remove version if need
```

- Verify Installation


```bash
kubectl exec -it vault-0 -n vault -- vault status
kubectl exec -ti vault-0 -n vault -- vault operator init -key-shares=3 -key-threshold=2 ## default  -key-shares=5 -key-threshold=3

kubectl exec -it vault-0 -n vault -- /bin/bash 
## show output like this

Unseal Key 1: <unsealkey1>
Unseal Key 2: <unsealkey2>
Unseal Key 3: <unsealkey3>

Initial Root Token: hvs.xxxxxxxx

## for unseal vault 

vault operator unseal <unsealkey1>
vault operator unseal <unsealkey2>

## verify status vault and see "Sealed status is false"
vault status
Key                     Value
---                     -----
Seal Type               shamir
Initialized             true
Sealed                  false
Total Shares            3
Threshold               2
Version                 1.19.3
Build Date              2025-04-29T10:34:52Z
Storage Type            raft
Cluster Name            vault-cluster-ebfc0d3a
Cluster ID              7ec57d9a-8086-e22c-e1c3-79fcba04eee8
Removed From Cluster    false
HA Enabled              true
HA Cluster              n/a
HA Mode                 standby
Active Node Address     <none>
Raft Committed Index    32
Raft Applied Index      32
```

### Join vault-1 and vault-2 node to Vault cluster

```bash
kubectl exec -it vault-1 -- vault operator raft join http://vault-0.vault-internal:8200
kubectl exec -it vault-2 -- vault operator raft join http://vault-0.vault-internal:8200

## and unseal nodes
kubectl exec -it vault-1 -- vault operator unseal <unsealkey1>
kubectl exec -it vault-1 -- vault operator unseal <unsealkey2>

kubectl exec -it vault-2 -- vault operator unseal <unsealkey1>
kubectl exec -it vault-2 -- vault operator unseal <unsealkey2>
```

- check leader node
```bash
curl -s --header "X-Vault-Token: <root_token>" http://127.0.0.1:8200/v1/sys/leader | jq

# view leader_cluster_address: xxx
or you can check on vault ui raft storage section on left handside
```


## Vault Installation - install as systemd service

### Single-Node Deployment

- Using package manager

```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vault
```



```bash

Not: # binary path is /usr/bin/vault check that "which vault"

ls /usr/bin/vault
---
sudo tee /lib/systemd/system/vault.service <<EOF
[Unit]
Description="HashiCorp Vault"
Documentation="https://developer.hashicorp.com/vault/docs"
ConditionFileNotEmpty="/etc/vault.d/vault.hcl"

[Service]
User=vault
Group=vault
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=/usr/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill --signal HUP
KillMode=process
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target
EOF

```

```bash

## change <vault-vm-ip>
## auto-unseal is active on AWS KMS for detail check auto-unseal section. if dont need delete seal "awskms" lines

sudo tee /etc/vault.d/vault.hcl <<EOF
storage "raft" {
  path    = "/opt/vault/data"
  node_id = "vault-node"
}

listener "tcp" {
 address = "0.0.0.0:8200" 
 cluster_address = "0.0.0.0:8201"
 tls_disable = 1

api_addr = "http://<vault-vm-ip>:8200"
cluster_addr = "http://<vault-vm-ip>:8201"
ui = true
log_level = "INFO"

disable_mlock=true

seal "awskms" {
  region     = "eu-central-1"
  access_key = "xxx"
  secret_key = "xxx"
  kms_key_id = "xxx"
}
EOF
```

```bash
# Create required directories

sudo mkdir -p /opt/vault/data
sudo mkdir -p /var/log/vault


sudo chown -R vault:vault /opt/vault
sudo chown -R vault:vault /var/log/vault
sudo chown vault:vault /etc/vault.d/vault.hcl
sudo chmod 640 /etc/vault.d/vault.hcl
sudo chmod 750  /var/log/vault

#restart vault service

sudo systemctl daemon-reload
sudo systemctl stop vault
sudo systemctl start vault
sudo systemctl status vault
sudo systemctl enable vault 


export VAULT_ADDR=http://<vault-vm-ip>:8200 

## check status vault before initialize
vault status

vault operator init -key-shares=3 -key-threshold=2 # for 3 unseal key and 2 of them is required
vault status

## check vault cluster is healty
curl http://<vault-vm-ip>:8200/v1/sys/health
```

### High Availability Cluster


#### Run on NODE-1
- Using package manager

```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vault
```

```bash

Not: # binary path is /usr/bin/vault check that "which vault"

sudo tee /lib/systemd/system/vault.service <<EOF
[Unit]
Description="HashiCorp Vault - A tool for managing secrets"
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/vault.d/vault.hcl
StartLimitIntervalSec=60
StartLimitBurst=3

[Service]
User=vault
Group=vault
ProtectSystem=full
ProtectHome=read-only
PrivateTmp=yes
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=/usr/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill --signal HUP \$MAINPID
KillMode=process
KillSignal=SIGINT
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
LimitNOFILE=65536
LimitMEMLOCK=infinity

[Install]
WantedBy=multi-user.target
EOF

```


```bash
## change <node-x-ip>
## auto-unseal is active on AWS KMS for detail check auto-unseal section. if dont need delete seal "awskms" lines

sudo tee /etc/vault.d/vault.hcl <<EOF
storage "raft" {
  path    = "/opt/vault/data"
  node_id = "vault-node-1"

  retry_join {
    leader_api_addr = "http://<node-1-ip>:8200"
  }
  retry_join {
    leader_api_addr = "http://<node-2-ip>:8200"
  }
  retry_join {
    leader_api_addr = "http://<node-3-ip>:8200"
  }
}

listener "tcp" {
address = "<node-1-ip>:8200" 
cluster_address = "<node-1-ip>:8201"
tls_disable = 1
}

api_addr = "http://<node-1-ip>:8200"
cluster_addr = "http://<node-1-ip>:8201"
ui = true
log_level = "INFO"

disable_mlock=true

seal "awskms" {
  region     = "eu-central-1"
  access_key = "xxx"
  secret_key = "xxx"
  kms_key_id = "xxx"
}

audit "file" {
  path = "/var/log/vault/audit.log"
  log_requests = true
  log_responses = true
}
EOF
 
```

```bash
# Create required directories
sudo mkdir -p /opt/vault/data
sudo mkdir -p /var/log/vault

# Set ownership and permissions
sudo chown -R vault:vault /opt/vault
sudo chown -R vault:vault /var/log/vault
sudo chown vault:vault /etc/vault.d/vault.hcl
sudo chmod 640 /etc/vault.d/vault.hcl
sudo chmod 750  /var/log/vault

# Enable and start vault service
sudo systemctl daemon-reload
sudo systemctl stop vault
sudo systemctl start vault
sudo systemctl status vault
sudo systemctl enable vault 

export VAULT_ADDR=http://<node-1-ip>:8200
vault status
```
- initialize vault

```bash
vault operator init -key-shares=3 -key-threshold=2
not: aws kms için 5-3 olmalı 

vault status
```
- check raft peer list

```bash
vault login <root token>

vault operator raft list-peers

root@GLMGVSM01:~# vault operator raft list-peers
Node            Address             State       Voter
----            -------             -----       -----
vault-node-1    <node-ip>:8201    leader      true

```

#### Run on NODE-2

- Using package manager

```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vault
```

```bash

Not: # binary path is /usr/bin/vault check that "which vault"

sudo tee /lib/systemd/system/vault.service <<EOF
[Unit]
Description="HashiCorp Vault - A tool for managing secrets"
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/vault.d/vault.hcl
StartLimitIntervalSec=60
StartLimitBurst=3

[Service]
User=vault
Group=vault
ProtectSystem=full
ProtectHome=read-only
PrivateTmp=yes
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=/usr/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill --signal HUP \$MAINPID
KillMode=process
KillSignal=SIGINT
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
LimitNOFILE=65536
LimitMEMLOCK=infinity

[Install]
WantedBy=multi-user.target
EOF

```


```bash
## change <node-x-ip>
## auto-unseal is active on AWS KMS for detail check auto-unseal section. if dont need delete seal "awskms" lines

sudo tee /etc/vault.d/vault.hcl <<EOF
storage "raft" {
  path    = "/opt/vault/data"
  node_id = "vault-node-2"

  retry_join {
    leader_api_addr = "http://<node-1-ip>:8200"
  }
  retry_join {
    leader_api_addr = "http://<node-2-ip>:8200"
  }
  retry_join {
    leader_api_addr = "http://<node-3-ip>:8200"
  }
}

listener "tcp" {
address = "<node-2-ip>:8200" 
cluster_address = "<node-2-ip>:8201"
tls_disable = 1
}

api_addr = "http://<node-2-ip>:8200"
cluster_addr = "http://<node-2-ip>:8201"
ui = true
log_level = "INFO"

disable_mlock=true

seal "awskms" {
  region     = "eu-central-1"
  access_key = "xxx"
  secret_key = "xxx"
  kms_key_id = "xxx"
}

audit "file" {
  path = "/var/log/vault/audit.log"
  log_requests = true
  log_responses = true
}
EOF
 
```
- create data and log path 

```bash
# Create required directories
sudo mkdir -p /opt/vault/data
sudo mkdir -p /var/log/vault

# Set ownership and permissions
sudo chown -R vault:vault /opt/vault
sudo chown -R vault:vault /var/log/vault
sudo chown vault:vault /etc/vault.d/vault.hcl
sudo chmod 640 /etc/vault.d/vault.hcl
sudo chmod 750  /var/log/vault

# Enable and start vault service
sudo systemctl daemon-reload
sudo systemctl stop vault
sudo systemctl start vault
sudo systemctl status vault
sudo systemctl enable vault 

export VAULT_ADDR=http://<node-2-ip>:8200
vault status

# After service starts, node will automatically join cluster via retry_join
# Check cluster status and unseal if needed
vault operator unseal <unsealkey1>
vault operator unseal <unsealkey2>

```
#### Run on NODE-3

- Using package manager

```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vault
```

```bash

Not: # binary path is /usr/bin/vault check that "which vault"

sudo tee /lib/systemd/system/vault.service <<EOF
[Unit]
Description="HashiCorp Vault - A tool for managing secrets"
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/vault.d/vault.hcl
StartLimitIntervalSec=60
StartLimitBurst=3

[Service]
User=vault
Group=vault
ProtectSystem=full
ProtectHome=read-only
PrivateTmp=yes
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=/usr/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill --signal HUP \$MAINPID
KillMode=process
KillSignal=SIGINT
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
LimitNOFILE=65536
LimitMEMLOCK=infinity

[Install]
WantedBy=multi-user.target
EOF

```


```bash
## change <node-x-ip>
## auto-unseal is active on AWS KMS for detail check auto-unseal section. if dont need delete seal "awskms" lines

sudo tee /etc/vault.d/vault.hcl <<EOF
storage "raft" {
  path    = "/opt/vault/data"
  node_id = "vault-node-3"

  retry_join {
    leader_api_addr = "http://<node-1-ip>:8200"
  }
  retry_join {
    leader_api_addr = "http://<node-2-ip>:8200"
  }
  retry_join {
    leader_api_addr = "http://<node-3-ip>:8200"
  }
}

listener "tcp" {
address = "<node-3-ip>:8200" 
cluster_address = "<node-3-ip>:8201"
tls_disable = 1
}

api_addr = "http://<node-3-ip>:8200"
cluster_addr = "http://<node-3-ip>:8201"
ui = true
log_level = "INFO"

disable_mlock=true

seal "awskms" {
  region     = "eu-central-1"
  access_key = "xxx"
  secret_key = "xxx"
  kms_key_id = "xxx"
}

audit "file" {
  path = "/var/log/vault/audit.log"
  log_requests = true
  log_responses = true
}
EOF
 
```
- create data and log path 

```bash
# Create required directories
sudo mkdir -p /opt/vault/data
sudo mkdir -p /var/log/vault

# Set ownership and permissions
sudo chown -R vault:vault /opt/vault
sudo chown -R vault:vault /var/log/vault
sudo chown vault:vault /etc/vault.d/vault.hcl
sudo chmod 640 /etc/vault.d/vault.hcl
sudo chmod 750  /var/log/vault

# Enable and start vault service
sudo systemctl daemon-reload
sudo systemctl stop vault
sudo systemctl start vault
sudo systemctl status vault
sudo systemctl enable vault 

export VAULT_ADDR=http://<node-3-ip>:8200
vault status

# After service starts, node will automatically join cluster via retry_join
# Check cluster status and unseal if needed
vault operator unseal <unsealkey1>
vault operator unseal <unsealkey2>
```

- verify complete cluster setup (final step)

```bash
# Login with root token and verify all nodes joined the cluster
vault login <root token>

vault operator raft list-peers

# Expected output showing all 3 nodes:
# vault-node-1    <node-1-ip>:8201    leader      true
# vault-node-2    <node-2-ip>:8201    follower    true  
# vault-node-3    <node-3-ip>:8201    follower    true

# Verify cluster health
vault status

```

## auto-unseal 

### for k8s deploymnet
```bash
vi ext-vault-values.yaml 
and 
add helm values config section this lines

```

```yaml
  ha:
    enabled: true
    replicas: 3
    raft: 
      enabled: true
    config: |
      ui = true

      listener "tcp" {
        tls_disable = 1
        address = "[::]:8200"
        cluster_address = "[::]:8201"
      }
      storage "raft" {
          path = "/vault/data"

          retry_join {
            leader_api_addr = "http://vault-0.vault-internal:8200"
          }
          retry_join {
            leader_api_addr = "http://vault-1.vault-internal:8200"
          }
          retry_join {
            leader_api_addr = "http://vault-2.vault-internal:8200"
          }
        }

      service_registration "kubernetes" {}
      seal "awskms" {
        region     = "eu-central-1"
        access_key = "xxx"
        secret_key = "xxx"
        kms_key_id = "xxx"
      }

```
- helm upgrade 
```bash
helm upgrade --install vault hashicorp/vault --version 0.30.0 -f ext-vault-values.yaml
```

```bash

kubectl exec -it vault-0 -n vault -- sh

# for one more time for unseal 

vault operator unseal -migrate

enter <unsealkey1>
enter <unsealkey2>

systemctl restart vault.service 
vault status

# show sealed: false

Not: Need root token every time for Vault ui login
```
### for systemd service

Not: In the /etc/vault.d/vault.hcl document for the Systemd service installation mentioned above, it's mandatory to enter the relevant auto unseal area. Afterward, the following steps must be taken:

```bash
# for one more time for unseal 

vault operator unseal -migrate

enter <unsealkey1>
enter <unsealkey2>

systemctl restart vault.service 
vault status

# show sealed: false

Not: Need root token every time for Vault ui login

```

## use tls (for systemd service)

```bash
sudo nano /etc/vault.d/vault.hcl

# modified adress, listener, api_addr, cluster_addr section

listener "tcp" {
 address = "0.0.0.0:443" # port 443
 cluster_address = "0.0.0.0:8201"
 tls_cert_file = "/etc/vault.d/certs/vault.crt" # cert path 
 tls_key_file  = "/etc/vault.d/certs/vault.key" # key path
 tls_disable   = 0 # set 0 for tls enable
}
api_addr = "https://xxx.test.com:8200" # use new dns
cluster_addr = "https://xxx.test.com:8201" # use new dns

# permission for bind service and run on 443, if not use port 8200 like https://xxx.test.com:8200
sudo setcap 'cap_net_bind_service=+ep' /usr/local/bin/vault

sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/vault.d/certs/vault.key -out /etc/vault.d/certs/vault.crt -subj "/CN=xxx.test.com"

sudo nano  /lib/systemd/system/vault.service

# modified below lines
CapabilityBoundingSet=CAP_IPC_LOCK CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_IPC_LOCK CAP_NET_BIND_SERVICE


# restart vault service
sudo systemctl daemon-reload
sudo systemctl restart vault
sudo systemctl status vault

# verify tls connection

https://xxx.test.com

```

## LDAP integration (for systemd service)

The ldap auth method allows authentication using an existing LDAP server and user/password credentials. This allows Vault to be integrated into environments using LDAP without duplicating the user/pass configuration in multiple places.


```bash
vault auth enable ldap

vault write auth/ldap/config \
    url="ldap://ldap.server.address" \
    bind_dn="cn=admin,dc=example,dc=com" \
    bind_password="admin_password" \
    user_dn="ou=users,dc=example,dc=com" \
    group_dn="ou=groups,dc=example,dc=com" \
    user_attr="uid" \
    group_attr="cn" \
    group_filter="(objectClass=groupOfNames)" \
    group_base_dn="ou=groups,dc=example,dc=com" \
    insecure_tls=true
```

```text
url: The address of the LDAP server.
bind_dn: The user used to bind (authenticate) to the LDAP directory.
bind_password: The password for the LDAP user specified in bind_dn.
user_dn: The distinguished name (DN) where user entries are located in the LDAP directory.
group_dn: The distinguished name (DN) where group entries are located in the LDAP directory.
user_attr: The LDAP attribute used to identify the user (e.g., uid).
group_attr: The LDAP attribute used to identify the group name (e.g., cn).
group_filter: The filter to identify LDAP group objects (e.g., (objectClass=groupOfNames)).
group_base_dn: The base distinguished name for groups in the LDAP directory.
insecure_tls: If you are not using TLS, set this to true.

```
```bash
nano ldap-users-policy.hcl

--
path "auth/ldap/login/*" { 
  capabilities = ["read", "update"]
}
path "kv/*" {
  capabilities = ["read"]
}
path "kv/data/*" {
  capabilities = ["read"]
}
path "kv/metadata/*" {
  capabilities = ["read"]
}
path "sys/mounts/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
path "sys/mounts" {
  capabilities = ["read"]
}
--
vault policy write ldap-users-policy ldap-users-policy.hcl

vault write auth/ldap/groups/<ldap_groups> policies="default,ldap-users-policy"

#test ldap user login 
vault login -method=ldap username=ldap-username password=password
```


## auth-kubernetes enable

### Kubernetes side configuration

Prerequisites:
- External Secrets Operator (ESO) must be installed on Kubernetes cluster

#### Step 1: Create Service Account and RBAC

```yaml
# Define service account for ESO-Vault integration with proper RBAC permissions
# This service account allows ESO to authenticate with Vault and manage Kubernetes secrets

vi vault-sa.yaml

apiVersion: v1
kind: ServiceAccount
metadata:
  name: external-secrets-sa
  namespace: eso

---
# ClusterRoleBinding links the service account to the cluster role
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: external-secrets-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: external-secrets-sa
  namespace: eso
```

Apply the service account configuration:

```bash
kubectl apply -f vault-sa.yaml
```

#### Step 2: Create Service Account Token

```yaml
# For Kubernetes 1.24+, manual token creation is required
# This secret contains the JWT token for service account authentication

vi vault-sa-token.yaml

apiVersion: v1
kind: Secret
metadata:
  name: external-secrets-sa-token
  namespace: eso
  annotations:
    kubernetes.io/service-account.name: external-secrets-sa
type: kubernetes.io/service-account-token
```

Apply the token secret:

```bash
kubectl apply -f vault-sa-token.yaml

# Verify token creation
kubectl get secret external-secrets-sa-token -n eso
```

### Vault server side configuration (only using by single cluster)

**Note:** The following configuration is for **single cluster** setup only. If you need to connect multiple Kubernetes clusters to Vault, skip this section and go directly to [Multiple Clusters Configuration](#multiple-clusters-configuration).


#### Step 3: Enable Kubernetes Auth Method

```bash
# Enable Kubernetes authentication method in Vault
vault auth enable kubernetes
```

#### Step 4: Configure Kubernetes Auth

```bash
# Configure Vault with Kubernetes cluster information
# Replace placeholders with actual values from your environment

vault write auth/kubernetes/config \
    token_reviewer_jwt="$(kubectl get secret external-secrets-sa-token -n eso -o jsonpath='{.data.token}' | base64 -d)" \
    kubernetes_host="https://YOUR-K8S-API-SERVER:6443" \
    kubernetes_ca_cert="$(cat /tmp/k8s-ca.crt)" \
    disable_iss_validation=true

# Verify configuration
vault read auth/kubernetes/config
```

#### Step 5: Create Vault Policy

```bash
# Create policy file defining permissions for ESO
vi eso-policy.hcl

path "kv/data/*" {
  capabilities = ["read"]
}
path "kv/metadata/*" {
  capabilities = ["read"]
}

# Apply the policy to Vault
vault policy write eso-policy eso-policy.hcl

# Verify policy creation
vault read sys/policy/eso-policy
```

#### Step 6: Create Kubernetes Role

```bash
# Create role binding service account to Vault policy
# This role allows the specified service account to authenticate with Vault
vault write auth/kubernetes/role/eso-role \
    bound_service_account_names=external-secrets-sa \
    bound_service_account_namespaces=eso \
    policies=eso-policy \
    ttl=24h

# Verify role creation
vault read auth/kubernetes/role/eso-role
```

#### Step 7: Test Authentication

```bash
# Test authentication with the service account token
TOKEN=$(kubectl get secret external-secrets-sa-token -n eso -o jsonpath='{.data.token}' | base64 -d)

vault write auth/kubernetes/login role=eso-role jwt="$TOKEN"
```

### Multiple Clusters Configuration

When you need to connect multiple Kubernetes clusters to a single Vault instance, each cluster requires its own auth path, policy, and role configuration.

#### Cluster 1 Configuration

##### Step 1: Enable Kubernetes Auth for Cluster 1
```bash
# Enable Kubernetes authentication method for cluster 1
vault auth enable -path=kubernetes/cluster1 kubernetes
```

##### Step 2: Create Policy for Cluster 1
```bash
# Create policy file for cluster 1
vi cluster1-eso-policy.hcl
```

```hcl
# Policy for cluster1 - allows access to cluster1 specific secrets
path "cluster1/data/*" {
  capabilities = ["read"]
}
path "cluster1/metadata/*" {
  capabilities = ["read"]
}
```

```bash
# Apply the policy to Vault
vault policy write cluster1-eso-policy cluster1-eso-policy.hcl
```

##### Step 3: Configure Kubernetes Auth for Cluster 1
```bash
# Get cluster 1 credentials (from cluster 1 context)
kubectl config use-context cluster1-context
kubectl get secret external-secrets-sa-token -n eso -o jsonpath='{.data.token}' | base64 -d > /tmp/cluster1-token.jwt
kubectl get secret external-secrets-sa-token -n eso -o jsonpath='{.data.ca\.crt}' | base64 -d > /tmp/cluster1-ca.crt
CLUSTER1_HOST=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')

# Configure Vault with Cluster 1 information
vault write auth/kubernetes/cluster1/config \
    token_reviewer_jwt="$(cat /tmp/cluster1-token.jwt)" \
    kubernetes_host="$CLUSTER1_HOST" \
    kubernetes_ca_cert="$(cat /tmp/cluster1-ca.crt)" \
    disable_iss_validation=true
```

##### Step 4: Create Role for Cluster 1
```bash
# Create role for cluster 1
vault write auth/kubernetes/cluster1/role/cluster1-eso-role \
    bound_service_account_names=external-secrets-sa \
    bound_service_account_namespaces=eso \
    policies=cluster1-eso-policy \
    ttl=24h \
    audience=vault
```

##### Step 5: Test Authentication for Cluster 1
```bash
# Test authentication for cluster 1
vault write auth/kubernetes/cluster1/login \
    role=cluster1-eso-role \
    jwt="$(cat /tmp/cluster1-token.jwt)"
```

#### Cluster 2 Configuration

##### Step 1: Enable Kubernetes Auth for Cluster 2
```bash
# Enable Kubernetes authentication method for cluster 2
vault auth enable -path=kubernetes/cluster2 kubernetes
```

##### Step 2: Create Policy for Cluster 2
```bash
# Create policy file for cluster 2
vi cluster2-eso-policy.hcl
```

```hcl
# Policy for cluster2 - allows access to cluster2 specific secrets
path "cluster2/data/*" {
  capabilities = ["read"]
}
path "cluster2/metadata/*" {
  capabilities = ["read"]
}
```

```bash
# Apply the policy to Vault
vault policy write cluster2-eso-policy cluster2-eso-policy.hcl
```

##### Step 3: Configure Kubernetes Auth for Cluster 2
```bash
# Get cluster 2 credentials (from cluster 2 context)
kubectl config use-context cluster2-context
kubectl get secret external-secrets-sa-token -n eso -o jsonpath='{.data.token}' | base64 -d > /tmp/cluster2-token.jwt
kubectl get secret external-secrets-sa-token -n eso -o jsonpath='{.data.ca\.crt}' | base64 -d > /tmp/cluster2-ca.crt
CLUSTER2_HOST=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')

# Configure Vault with Cluster 2 information
vault write auth/kubernetes/cluster2/config \
    token_reviewer_jwt="$(cat /tmp/cluster2-token.jwt)" \
    kubernetes_host="$CLUSTER2_HOST" \
    kubernetes_ca_cert="$(cat /tmp/cluster2-ca.crt)" \
    disable_iss_validation=true
```

##### Step 4: Create Role for Cluster 2
```bash
# Create role for cluster 2
vault write auth/kubernetes/cluster2/role/cluster2-eso-role \
    bound_service_account_names=external-secrets-sa \
    bound_service_account_namespaces=eso \
    policies=cluster2-eso-policy \
    ttl=24h \
    audience=vault
```

##### Step 5: Test Authentication for Cluster 2
```bash
# Test authentication for cluster 2
vault write auth/kubernetes/cluster2/login \
    role=cluster2-eso-role \
    jwt="$(cat /tmp/cluster2-token.jwt)"
```

#### Verification Commands for Multiple Clusters

```bash
# List all authentication methods
vault auth list

# Check cluster 1 config
vault read auth/kubernetes/cluster1/config
vault read auth/kubernetes/cluster1/role/cluster1-eso-role

# Check cluster 2 config
vault read auth/kubernetes/cluster2/config
vault read auth/kubernetes/cluster2/role/cluster2-eso-role
```

#### ClusterSecretStore Configuration for Each Cluster

##### Cluster 1 ClusterSecretStore
```yaml
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: vault-cluster1-secretstore
spec:
  provider:
    vault:
      server: "http://vault-ip:8200"  # CHANGE ME: Replace with actual Vault server IP or FQDN
      path: "cluster1"
      version: v2
      auth:
        kubernetes:
          mountPath: "kubernetes/cluster1"
          role: "cluster1-eso-role"
          serviceAccountRef:
            name: external-secrets-sa
            namespace: eso
          secretRef:
            name: external-secrets-sa-token              # Token secret reference
            namespace: eso
            key: token
```

##### Cluster 2 ClusterSecretStore
```yaml
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: vault-cluster2-secretstore
spec:
  provider:
    vault:
      server: "http://vault-ip:8200"  # CHANGE ME: Replace with actual Vault server IP or FQDN
      path: "cluster2"
      version: v2
      auth:
        kubernetes:
          mountPath: "kubernetes/cluster2"
          role: "cluster2-eso-role"
          serviceAccountRef:
            name: external-secrets-sa
            namespace: eso
          secretRef:
            name: external-secrets-sa-token              # Token secret reference
            namespace: eso
            key: token
```

#### Secret Engines for Each Cluster

```bash
# Enable KV secret engines for each cluster
vault secrets enable -path=cluster1 kv-v2
vault secrets enable -path=cluster2 kv-v2

# Create sample secrets for testing
vault kv put cluster1/database username="cluster1-db-user" password="cluster1-db-pass"
vault kv put cluster2/database username="cluster2-db-user" password="cluster2-db-pass"
```

### Kubernetes side - Create ClusterSecretStore

#### Step 8: Create ClusterSecretStore

```yaml
# Define ClusterSecretStore for ESO-Vault integration
# ClusterSecretStore can be accessed from all namespaces (unlike SecretStore which is namespace-scoped)

vi clustersecretstore-sa.yaml

apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: vault-nonprod-serviceaccount
spec:
  provider:
    vault:
      server: http://your-vault-server.example.com # Vault server URL
      path: "kv"                                         # Vault secret engine path
      version: v2                                        # KV engine version
      auth:
        kubernetes:
          mountPath: "kubernetes"                        # Vault auth method path
          role: "eso-role"                              # Vault role name
          serviceAccountRef:
            name: external-secrets-sa                    # Kubernetes service account
            namespace: eso
          secretRef:
            name: external-secrets-sa-token              # Token secret reference
            namespace: eso
            key: token
```

Apply the ClusterSecretStore:

```bash
kubectl apply -f clustersecretstore-sa.yaml

# Verify ClusterSecretStore creation
kubectl get ClusterSecretStore

# Check status - should show "Valid"
kubectl describe ClusterSecretStore vault-nonprod-serviceaccount
```

### Testing the Integration

#### Step 9: Create Test Secret in Vault

```bash
# Create a test secret in Vault for validation
vault kv put kv/test vault-username="test-username-123"

# Verify secret creation
vault kv get kv/test
```

#### Step 10: Create ExternalSecret for Testing

```yaml
# ExternalSecret resource converts Vault secrets to Kubernetes secrets
vi externalsecret.yaml

apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: vault-example
  namespace: eso
spec:
  refreshInterval: "30s"                              # Secret refresh interval
  secretStoreRef:
    name: vault-nonprod-serviceaccount               # ClusterSecretStore reference
    kind: ClusterSecretStore
  target:
    name: devops-test                                # Kubernetes secret name to create
    creationPolicy: Owner                            # Secret ownership policy
  data:
  - secretKey: k8s-username                              # Key name in Kubernetes secret
    remoteRef:
      key: test                                      # Vault secret path (kv/test)
      property: vault-username                                # Vault secret field name
```

Apply the ExternalSecret:

```bash
kubectl apply -f externalsecret.yaml
```

#### Step 11: Verify Integration

```bash
# Check ExternalSecret status
kubectl get externalsecret vault-example -n eso

# View ExternalSecret details
kubectl describe externalsecret vault-example -n eso

# Verify Kubernetes secret creation
kubectl get secret devops-test -n eso -o yaml

# Decode and view secret content
kubectl get secret devops-test -n eso -o jsonpath='{.data.k8s-username}' | base64 -d
# Expected output: test-username-123

# Check ESO controller logs for troubleshooting
kubectl logs -n eso -l app.kubernetes.io/name=external-secrets --tail=50
```

### Troubleshooting

If you encounter issues:

1. **Check ClusterSecretStore status**: Must show "Valid"
2. **Verify Vault connectivity**: Ensure Vault server is accessible from Kubernetes
3. **Check ESO logs**: Look for authentication or permission errors
4. **Validate token**: Ensure service account token is not expired
5. **Test Vault authentication manually**: Use `vault write auth/kubernetes/login` command

Common issues:
- Token expiration (recreate token secret)
- Network connectivity between Kubernetes and Vault
- Incorrect Vault policy permissions
- Wrong service account or namespace bindings


## database secret engine

### running postgres pod
```bash
kubectl get secret --namespace default postgre-vault-test-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d
MQEvdzuWw6

kubectl exec -it postgre-vault-test-postgresql-0 -- bash


psql -U vault -d postgres
pass: vault

CREATE ROLE vault WITH LOGIN SUPERUSER PASSWORD 'vault';
```

### enable secret engine
vault secrets enable database

vault write database/config/postgres plugin_name=postgresql-database-plugin allowed_roles="sql-role" connection_url="postgresql://{{username}}:{{password}}@postgre-vault-test-postgresql.default.svc:5432/postgres?sslmode=disable" username="vault" password="vault"


vault write database/roles/sql-role db_name=postgres creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" default_ttl="1h" max_ttl="24h"

vault read database/creds/sql-role

### define policy for database role

kubectl -n vault-example exec -it vault-example-0 sh

cat <<EOF > /home/vault/postgres-app-policy.hcl
path "database/creds/sql-role" {
  capabilities = ["read"]
}
EOF

vault policy write postgres-app-policy /home/vault/postgres-app-policy.hcl


## regenerate new root-token

```bash
vault operator generate-root -init

# show the output and use nonce and OTP with code
A One-Time-Password has been generated for you and is shown in the OTP field.
You will need this value to decode the resulting root token, so keep it safe.
Nonce         ed835311-96a5-b34b-b0b5-dab778cad815
Started       true
Progress      0/3
Complete      false
OTP           HH8Yi0nYyKmIHV9c2J2v9LH7qFG4
OTP Length    28

vault operator generate-root -nonce=<nonce-number>
then enter unseal-1
vault operator generate-root -nonce=<nonce-number>
then enter unseal-2
...
last output get <Encoded-Token>


vault operator generate-root -decode=<Encoded-Token> -otp=<OTP-Token>


get new root-token

"hvs.xxx"


Not: not revoke first root token. use both

if you want to revoke other root token 

vault token revoke <old-root-token>
```

## Vault Policy, Group, and User Configuration
This document outlines the steps for creating policies, groups, and users in Vault, including how to assign policies to groups and users to groups, using both Vault CLI and Vault UI.

Vault Policy Creation
In Vault, policies are created to manage appropriate paths within secret engines. These policies define access permissions for specific paths. The following examples demonstrate how to create policies for different projects and environments using the kv secret engine.

Example Policy Structure
Policies can be created individually for each project and environment combination, or with a more general approach. Here, it's assumed you have different secret engines like parasut, zirve, mikro. If these are not separate secret engines but rather paths under the kv secret engine, they should be structured as path "secret/data/parasut/...".

- mikro-all-policy.hcl (Example: A more general policy for Mikro)

```bash
path "auth/ldap/login/*" { 
  capabilities = ["read", "update"]
}
path "zirve/metadata/*" {
  capabilities = ["read", "list"]
}
path "zirve/data/<project-name>/*" {
  capabilities = ["read", "update", "delete", "list"]
}
```

### Methods to Create Policies
Vault policies can be created using a few different methods:

1. Via HCL Files and Vault CLI (Recommended for Version Control)
This method involves defining policies in .hcl files and then uploading them to Vault using the CLI. This is generally recommended for version control and automation.

After creating each .hcl file, you can upload these policies to Vault using the Vault CLI:

```bash
# Upload project policy
vault policy write <project-policy-name> mikro-all-policy.hcl

```

2. Via Vault UI
For users who prefer a graphical interface, policies can also be created and managed directly through the Vault UI.

Access your Vault UI (http://your-vault-server.example.com/).

Navigate to Policies in the left-hand menu.

- Click on Create new policy.

Provide a Policy Name and paste the HCL policy definition into the Policy HCL text area.
```bash
path "auth/ldap/login/*" { 
  capabilities = ["read", "update"]
}
path "zirve/metadata/*" {
  capabilities = ["read", "list"]
}
path "zirve/data/<project-name>/*" {
  capabilities = ["read", "update", "delete", "list"]
}
```
- Click Create policy.


### Group Creation and Policy Assignment
Vault groups are used to manage collections of entities (users or machines) and assign policies to them. This simplifies permission management by allowing policies to be assigned to groups rather than individual entities.

- Methods for Group Creation and Policy Assignment

1. Via Vault CLI
First, ensure the identity secrets engine is enabled (it usually is by default). Then, create groups and assign policies to them.

## Create project-team group and assign policy
vault write auth/ldap/groups/<groupname> policies=<group-policy>


2. Via Vault UI
Groups can also be created and managed through the Vault UI.

Access your Vault UI.

Navigate to Access > LDAP in the left-hand menu.

Go to the Groups tab.

- Click Create Group.

Enter the Group Name (e.g., shopside-policy).

Select the Policies to attach to this group.

- Click Save Group.


### User Creation and Group Assignment
Users (referred to as "entities" in Vault's Identity system) can be created and then associated with authentication methods. These entities can then be assigned to groups to inherit policies. Here, we'll use the userpass auth method for demonstration.


- Methods for User Creation and Group Assignment

1. Via Vault CLI
First, create a user with LDAP auth method. Then, create an identity entity for this user and link it to the group.

```bash
# Create a user in the userpass auth method
vault write auth/ldap/users/<LDAP-Username> groups=<groupname>
```

2. Via Vault UI
You can create users and assign them to groups directly via the Vault UI.

Access your Vault UI.

Create User (via Auth Method):

Navigate to Access > LDAP in the left-hand menu.

Go to the Users tab.

- Click Create User.

Enter a Username (e.g., name.lastname)

Enter the Group Name (e.g., shopside-policy).

If need enter special Policies to attach to this user

- Click Save User


### Vault Secret Creation and Referencing in Deployments
This document describes how to create secrets within the Vault UI and how to reference these secrets in your application's deployment configuration, specifically within a values.yaml file for Kubernetes.

- Creating Secrets via Vault UI
A user with appropriate policy permissions can create secrets within the relevant secret engine paths. These secrets can be entered as key-value pairs or as a JSON object, containing environment variables or other sensitive application data.

Access your Vault UI.

Navigate to the Secrets section in the left-hand menu.

- Click on the specific secret engine you want to use (e.g., parasut/, zirve/).

Browse or create the desired path (e.g., parasut/project1/dev).

- Click Create secret.

Enter the Key and Value pairs directly, or toggle to JSON format to paste a JSON object containing multiple key-value pairs.

```bash
Example (Key-Value):

Key: DATABASE_URL

Value: jdbc:postgresql://db.example.com:5432/mydb

Example (JSON):

{
  "API_KEY": "your_api_key_here",
  "SERVICE_ACCOUNT_EMAIL": "service@example.com"
}
```

- Click Save.

#### Referencing Secrets in Deployment Configuration (values.yaml)
After creating the secret in Vault, you can reference it in your application's deployment repository, typically within the dev-test-staging directories' values.yaml files. This is done using the externalSecretVault configuration, which leverages an External Secrets Operator (ESO) in Kubernetes to fetch secrets from Vault.

Locate the values.yaml file for your specific deployment environment (e.g., deployments/dev/values.yaml) and add the following section:

```yaml
externalSecretVault:
  name: projectname-clustername-external-secret # Unique name for the ExternalSecret resource
  secretStoreRef:
    name: vault-nonprod-xxx # Reference to your ClusterSecretStore or SecretStore
  dataFrom:
    - key: secretengine/projeadı/deployment-environment # Path to your secret in Vault (e.g., kv/parasut/project1/dev)

##----------UYARI---------##
# Bu bölümdeki extraSecret ve extraConfigMap bölümleri artık kullanılmamaktadır.
# Bunun yerine externalSecretVault kullanılmaktadır.
# Ekleme yapmak için Devops ekibi ile iletişime geçiniz.
##-----------UYARI--------##
```


### Creating a ClusterSecretStore for a New Secret Engine

If you are creating a new secret engine in Vault and need to integrate it with Kubernetes via External Secrets Operator (ESO), you will need to create a corresponding `ClusterSecretStore` resource in your Kubernetes cluster. There are generally two methods to achieve this:

### Method 1: Cloning an Existing ClusterSecretStore

You can clone an existing `ClusterSecretStore` definition via the Rancher UI and modify its `name` and `path` fields to match your new secret engine. This is often the quickest way if you have a template and prefer a graphical interface.

1.  Navigate to the relevant cluster in the Rancher interface.
2.  In the left-hand sidebar, go to **More Resources** --> **external-secrets.io** and then enter the **ClusterSecretStore** section.
3.  On the right side of the `ClusterSecretStore` you wish to clone, click on the `...` (three dots) icon and select **Clone**.
4.  In the pop-up window, change the `name` and `path` fields to create the new one.

### Method 2: Applying a New ClusterSecretStore CRD

You can directly apply a new `ClusterSecretStore` Custom Resource Definition (CRD) to your Kubernetes cluster. This method gives you full control over the definition.

Create a YAML file (e.g., `vault-new-secretstore.yaml`) with the following content and apply it:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: vault-nonprod-xxx
spec:
  provider:
    vault:
      server: "http://your-vault-server.example.com/"
      path: "<parasut>"   # CHANGE ME. Path to the secrets in Vault
      # Version is the Vault KV secret engine version.
      # This can be either "v1" or "v2", defaults to "v2"
      version: "v2"
      auth:
        tokenSecretRef:
          name: "vault-nonprod-token" # Name of the Kubernetes secret containing the Vault token
          key: "token"   # Key in the Kubernetes secret that contains the Vault token
          namespace:  eso # Namespace where the secret is located


# Apply the CRD to your cluster:
kubectl apply -f vault-new-secretstore.yaml

# After applying, verify the status of your new ClusterSecretStore:

kubectl get ClusterSecretStore <your-new-store-name>

# Ensure the status indicates it's Valid.

```
