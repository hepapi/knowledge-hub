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

- Using package manager

```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vault
```



```bash

Not: # binary path is /usr/bin/vault

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
sudo chown vault:vault /etc/vault.d/vault.hcl && sudo chmod 640 /etc/vault.d/vault.hcl

export VAULT_ADDR=http://<vault-vm-ip>:8200 

## check status vault before initialize
vault status

vault operator init -key-shares=3 -key-threshold=2 # for 3 unseal key and 2 of them is required
vault status

## check vault cluster is healty
curl http://<vault-vm-ip>:8200/v1/sys/health

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

- Kubernetes side must done

prerequisites:
 install external secret operator on k8s

```yaml
#define service account for eso-vault integration 

vi vault-sa.yaml

apiVersion: v1
kind: ServiceAccount
metadata:
  name: external-secrets-sa
  namespace: eso
```
- Create service account

```bash
kubectl apply -f vault-sa.yaml
```




```yaml
#define  ClusterSecretStore for eso-vault integration 

vi vault-clusterSecretStore.yaml

apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: vault-backend
spec:
  provider:
    vault:
      server: "http://vault.default.svc.cluster.local:8200"
      path: "kv"
      version: "v2"
      auth:
        kubernetes:
          mountPath: "kubernetes"
          role: "eso-role"
          serviceAccountRef:
            name: external-secrets-sa
            namespace: eso
```

- Create ClusterSecretStore

```bash
kubectl apply -f vault-clusterSecretStore.yaml

# verify ClusterSecretStore

kubectl get ClusterSecretStore

# check status is valid
```


- Vault VM side must done
 
```bash
#enable auth method
vault auth enable kubernetes


vault write auth/kubernetes/config \
    token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    kubernetes_host="https://10.15.11.30:6443" \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt


vi vault-policy.hcl
--
path "kv/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
--

vault policy write eso-policy vault-policy.hcl


# define role Not: use serviceaccount-name and namespace

vault write auth/kubernetes/role/eso-role \
    bound_service_account_names=external-secrets-sa \ 
    bound_service_account_namespaces=eso \
    policies=eso-policy \
    ttl=24h
```


### for test create externalsecret

```bash
#first define a credential on vault server

vault kv put kv/data/test/db password=1234
```

```yaml
vi externalsecret.yaml


apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: example-secret
  namespace: eso
spec:
  refreshInterval: "1h"
  secretStoreRef:
    name: vault-backend
    kind: ClusterSecretStore
  target:
    name: my-secret
    creationPolicy: Owner
  data:
    - secretKey: password
      remoteRef:
        key: "kv/data/test/db"
        property: "password"
```

- verify get secret from vault

```bash

kubectl get secret my-secret -n <namespace> -o yaml
```


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
```bash
vault secrets enable database

vault write database/config/postgres plugin_name=postgresql-database-plugin allowed_roles="sql-role" connection_url="postgresql://{{username}}:{{password}}@postgre-vault-test-postgresql.default.svc:5432/postgres?sslmode=disable" username="vault" password="vault"


vault write database/roles/sql-role db_name=postgres creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" default_ttl="1h" max_ttl="24h"

vault read database/creds/sql-role
```

### define policy for database role
```bash

kubectl -n vault-example exec -it vault-example-0 sh

cat <<EOF > /home/vault/postgres-app-policy.hcl
path "database/creds/sql-role" {
  capabilities = ["read"]
}
EOF

vault policy write postgres-app-policy /home/vault/postgres-app-policy.hcl
```

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
