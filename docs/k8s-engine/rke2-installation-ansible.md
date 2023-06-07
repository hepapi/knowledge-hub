# RKE2 and Rancher Installation With Ansible
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

1.  ssh into jump machine

    ```bash
    ssh root@10.40.140.10
    ```

    Enter the ssh password when prompted

## Set up passwordless SSH

1. Generate ssh key

    ```bash
    ssh-keygen
    ```

    Simply press enter when prompted for default name and no password, this will create `~/.ssh/id_rsa`

2. Copy ssh keys to master and worker nodes

    ```bash
    ssh-copy-id -i ~/.ssh/id_rsa root@10.40.140.4
    ```

    Enter the ssh password when prompted and repeat for all master and worker nodes.

3. Add the ssh key to the ssh-agent

    ```bash
    ssh-agent bash
    ssh-add ~/.ssh/id_rsa
    ```

    If you get an error run the following and try again

    ```bash
    eval `ssh-agent`
    ```

## Install Ansible and RKE2 deployment role

1. Install ansible

    ```bash
    sudo apt update
    sudo apt install ansible -y
    ```

2. Install the lablabs/rke2 ansible role (https://galaxy.ansible.com/lablabs/rke2)

    ```bash
    ansible-galaxy install lablabs.rke2
    ```

    This will install the role under the `~/.ansible` directory

3. Navigate to the `~/.ansible` directory

    ```bash
    cd ~/.ansible
    ```

4. Create inventory file in `~/.ansible` (can be copied from local with scp)

    ```bash
    vi inventory
    ```

    Go into insert mode by pressing i

    Copy the following and paste with ctrl+shift+v

    ```yaml
    [masters]
    master-01 ansible_host=10.40.140.4 rke2_type=server
    master-02 ansible_host=10.40.140.5 rke2_type=server
    master-03 ansible_host=10.40.140.6 rke2_type=server

    [workers]
    worker-01 ansible_host=10.40.140.7 rke2_type=agent
    worker-02 ansible_host=10.40.140.8 rke2_type=agent
    worker-03 ansible_host=10.40.140.9 rke2_type=agent

    [k8s_cluster:children]
    masters
    workers
    ```

    Save and quit by pressing Esc, then :wq!

5. Create playbook.yaml file in `~/.ansible` (check previous step for help with vi)

    ```yaml
    - name: Deploy RKE2
      hosts: all
      become: yes
      vars:
        rke2_ha_mode: true
        rke2_api_ip : 10.40.140.4
        rke2_download_kubeconf: true
        rke2_ha_mode_keepalived: false
        rke2_server_node_taints:
          - 'CriticalAddonsOnly=true:NoExecute'
      roles:
        - role: lablabs.rke2
    ```

    `rke2_api_ip` should point to your load balancer for master nodes, this should be a TCP load balancer on port 6443. If you don't have one it can point to one of the master nodes.

    Alternatively you can use keepalived by removing the `rke2_ha_mode_keepalived` line, and pointing the `rke2_api_ip` to an unused static IP such as `10.40.140.100`

6. Confirm inventory is working

    ```bash
    ansible all -i inventory -m ping
    ```

    There should be no errors.

## Run the playbook and confirm RKE2 cluster is up

1. Run the ansible playbook

    ```bash
    ansible-playbook -i inventory playbook.yaml
    ```

    If you're ssh'ing to the other machines as a non-root user, run the following instead:

    ```bash
    ansible-playbook -i inventory playbook.yaml -K
    ```

    Provide the password for the user you're logging in as when prompted.

    If it hangs at 'Wait for remaining nodes to be ready', check if rke2 is installed on all machines, if not the `rke2.sh` script may not be running. To fix this, edit the `~/.ansible/roles/lablabs.rke2/tasks/rke2.yml` by removing the `Check RKE2 version` task and replacing it with:

    ```yaml
    - name: Check rke2 bin exists
      ansible.builtin.stat:
        path: "{{ rke2_bin_path }}"
      register: rke2_exists

    - name: Check RKE2 version
      ansible.builtin.shell: |
        set -o pipefail
        {{ rke2_bin_path }} --version | grep -E "rke2 version" | awk '{print $3}'
      args:
        executable: /bin/bash
      changed_when: false
      register: installed_rke2_version
      when: rke2_exists.stat.exists
    ```

2. Install kubectl

    ```bash
    sudo snap install kubectl --classic
    ```

3. Copy kubeconfig file to a better directory and export kubeconfig

    ```bash
    cp /tmp/rke2.yaml ~/rke2.yaml
    ```

    Now we can manage our cluster with `kubectl --kubeconfig ~/rke2.yaml`, or we can do the following to shorten our commands:

    ```bash
    export KUBECONFIG=~/rke2.yaml
    ```

4. Confirm our cluster is running and with correct internal IP addresses

    ```bash
    kubectl get nodes -o wide
    ```

5. Check the health of our pods

    ```bash
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

### Using Rancher-Generated TLS Cert

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

### Using your own Certs

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

### Jump

1. Ssh into the Jump machine

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

5. Remove Helm, Kubectl and Ansible

    ```bash
    snap remove helm
    snap remove kubectl
    sudo apt remove ansible
    ```

6. Remove remaining artifacts

    ```bash
    rm -rf /root/.ansible
    rm /root/.ssh/id_rsa /root/.ssh/id_rsa.pub
    rm ~/rke2.yaml
    rm -rf /root/.kube
    apt autoremove -y
    ```

    If you followed the installation guide as a non-root user the directories might be different.

### Master and Worker nodes

Repeat the following on all master and worker nodes

1. Ssh into the node

    ```bash
    ssh root@10.40.140.4
    ```

2. Run the RKE2 uninstall script

    ```bash
    sudo /usr/local/bin/rke2-uninstall.sh
    ```
