# Rancher Installation
This is a follow up to "RKE2 Ansible Installation" and assumes you're working on an RKE2 cluster similar to the one set up in that document.

Example commands and configs are for 3 masters, 3 workers and an
additional jump node all running Ubuntu.

Example topology:  

| Name      | IP           |
|-----------|--------------|
| Master-01 | 10.40.140.4  | 
| Master-02 | 10.40.140.5  | 
| Master-03 | 10.40.140.6  | 
| Worker-01 | 10.40.140.7  | 
| Worker-02 | 10.40.140.8  | 
| Worker-03 | 10.40.140.9  | 
| Jump      | 10.40.140.10 |

1.  ssh into the jump machine

    ```bash
    ssh root@10.40.140.10
    ```

    Enter the ssh password when prompted

1. Install kubectl if it's not already installed

    ```bash
    sudo snap install kubectl --classic
    ```

1. Make sure we're using the correct kubeconfig

    ```bash
    export KUBECONFIG=~/rke2.yaml
    ```

1. Confirm that our nodes and pods are correct and health

    ```bash
    kubectl get nodes -o wide
    kubectl get pods -A
    ```

## Install Rancher on the RKE2 cluster

1. Install Helm

    ```bash
    sudo snap install helm --classic
    ```

2. Add Helm chart repository (used latest here, can be latest, stable or alpha)

    ```bash
    helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
    ```

3. Create a namespace for Rancher

    ```bash
    kubectl create namespace cattle-system
    ```

## Using Rancher-Generated TLS Cert

1. Install cert-manager (needed if using Rancher-generated TLS cert or Let’s Encrypt)

    ```bash
    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.crds.yaml

    helm repo add jetstack https://charts.jetstack.io
    helm repo update
    helm install cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --version v1.11.0
    ```

2. Verify that cert-manager is deployed correctly

    ```bash
    kubectl get pods --namespace cert-manager
    ```

3. Install Rancher with Helm

    ```bash
    helm install rancher rancher-latest/rancher \
      --namespace cattle-system \
      --set hostname=10.40.140.8.nip.io \
      --set bootstrapPassword=admin \
      --set global.cattle.psp.enabled=false
    ```

    * hostname should be the DNS name you pointed at your load balancer for the worker nodes, .nip.io can be added to the ip if there’s no DNS name

    * `global.cattle.psp.enabled` is set to `false` due to the rancher helm chart requiring the deprecated `podsecuritypolicy`

    Save the `--set` options used here, you will need to use the same options when you upgrade Rancher to new versions with Helm.

4. Wait for Rancher to be rolled out

    ```bash
    watch kubectl -n cattle-system get pods
    ```

5. In a web browser navigate to the DNS name that points to your load balancer (ex: `10.40.140.8:nip.io`), you should see the login page

## Using your own Certs
--------
### Formatting Certs

It can cause complications while editing files on a machine running some form of Windows and uploading them to a Linux server. Windows-based text editors put special characters at the end of lines to denote a line return or newline. There is a simple way to correct this problem.

* Install `dos2unix` and execute the command to convert line endings from DOS to Unix

    ```bash
    sudo apt install -y dos2unix

    dos2unix /path/to/file/<file-name>
    ```

* Windows servers use .pfx files which contain the public and private key. However, this can also be converted to .pem files to be used on Linux server

    ```bash
    openssl pkcs12 -in cert.pfx -nocerts -out tls.key -nodes
    openssl pkcs12 -in cert.pfx -nokeys -out tls.crt
    ```

------------

### Validating Certs

Before you set up your certificates, it's a good idea to test them to ensure that they are correct and will work together.

1. Check to see if the private key and main certificate are in PEM format. `openssl` must be installed
   
    ```bash
    sudo apt install openssl -y

    openssl rsa -inform PEM -in /path/to/key/tls.key
    openssl x509 -inform PEM -in /path/to/cert/tls.crt
    ```

2. Verify that the private key and main certificate match

    ```bash
    openssl x509 -noout -modulus -in tls.crt | openssl md5
    openssl rsa -noout -modulus -in tls.key | openssl md5

    ## The output of these two commands should be the same.
    ```

3. Verify that the public keys contained in the private key file and the main certificate are the same

    ```bash
    openssl x509 -in tls.crt -noout -pubkey
    openssl rsa -in tls.key -pubout

    ## The output of these two commands should be the same.
    ```

4. Check the validty of certificate chain

    ```bash
    openssl verify -CAfile cacerts.pem tls.crt

    # Response must be OK.
    ```

5. Check if `Subject Alternative Names` contains `Common Name`

Subject Alternative Name <b>must contains the same value of the CN.</b> If it does not, the certificate is not valid because the industry moves away from CN

```bash
openssl x509 -noout -subject -in tls.crt
# subject= /CN=<example.domain.com>
openssl x509 -noout -in tls.crt -text | grep DNS
# DNS:<example.domain.com>
```

------------

### Create Secrets and Install

1. Create tls-ca secret with your private CA's root certificate

    ```bash
    kubectl -n cattle-system create secret generic tls-ca \
        --from-file=cacerts.pem=./cacerts.pem
    ```

2. Create cert and key secrets

    ```bash
    kubectl -n cattle-system create secret tls tls-rancher-ingress \
        --cert=tls.crt \
        --key=tls.key
    ```

3. Install Rancher with Helm

    ```bash
    helm install rancher rancher-latest/rancher \
        --namespace cattle-system \
        --set hostname=10.40.140.8.nip.io \
        --set bootstrapPassword=admin \
        --set global.cattle.psp.enabled=false \
        --set ingress.tls.source=secret \
        --set privateCA=true
    ```

    * hostname should be the DNS name you pointed at your load balancer for the worker nodes, .nip.io can be added to the ip if there’s no DNS name

    * `global.cattle.psp.enabled` is set to `false` due to the rancher helm chart requiring the deprecated `podsecuritypolicy`

    Save the `--set` options used here, you will need to use the same options when you upgrade Rancher to new versions with Helm.

## Cleanup

1. ssh into the Jump machine

    ```bash
    ssh root@10.40.140.10
    ```

2. Make sure we're using the correct kubeconfig

    ```bash
    export KUBECONFIG=~/rke2.yaml
    ```

3. Remove Rancher using helm

    ```bash
    helm uninstall rancher -n cattle-system
    ```

4. Remove Helm repositories

    ```bash
    helm repo remove jetstack
    helm repo remove rancher-latest
    ```

    Change `rancher-latest` with the version you used while installing (ex: `stable`, `alpha`)

5. Remove Helm

    ```bash
    sudo snap remove helm
    ```
