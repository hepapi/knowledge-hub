# RKE2 Cluster Installation With Ansible
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

## Set up passwordless SSH

1. Generate ssh key

    ```bash
    ssh-keygen
    ```

    Simply press enter when prompted for default name and no password, this will create `~/.ssh/id_rsa`

1. Copy ssh keys to master and worker nodes

    ```bash
    ssh-copy-id -i ~/.ssh/id_rsa root@10.40.140.4
    ```

    Enter the ssh password when prompted and repeat for all master and worker nodes.

1. Add the ssh key to the ssh-agent

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

1. Install the lablabs/rke2 ansible role (https://galaxy.ansible.com/lablabs/rke2)

    ```bash
    ansible-galaxy install lablabs.rke2
    ```

    This will install the role under the `~/.ansible` directory

1. Navigate to the `~/.ansible` directory

    ```bash
    cd ~/.ansible
    ```

1. Create inventory file in `~/.ansible` (can be copied from local with scp)

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

1. Create playbook.yaml file in `~/.ansible` (check previous step for help with vi)

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

1. Confirm inventory is working

    ```bash
    ansible all -i inventory -m ping
    ```

    There should be no errors.

## Run the playbook and confirm the RKE2 cluster is up

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

1. Install kubectl

    ```bash
    sudo snap install kubectl --classic
    ```

1. Copy kubeconfig file to a better directory and export kubeconfig

    ```bash
    cp /tmp/rke2.yaml ~/rke2.yaml
    ```

    Now we can manage our cluster with `kubectl --kubeconfig ~/rke2.yaml`, or we can do the following to shorten our commands:

    ```bash
    export KUBECONFIG=~/rke2.yaml
    ```

1. Confirm our cluster is running and with correct internal IP addresses

    ```bash
    kubectl get nodes -o wide
    ```

1. Check the health of our pods

    ```bash
    kubectl get pods -A
    ```

## Cleanup

### Jump

1. ssh into the Jump machine

    ```bash
    ssh root@10.40.140.10
    ```

1. Make sure we're using the correct kubeconfig

    ```bash
    export KUBECONFIG=~/rke2.yaml
    ```

1. Remove Kubectl and Ansible

    ```bash
    sudo snap remove kubectl
    sudo apt remove ansible
    ```

1. Remove remaining artifacts

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

1. ssh into the node

    ```bash
    ssh root@10.40.140.4
    ```

1. Run the RKE2 uninstall script

    ```bash
    sudo /usr/local/bin/rke2-uninstall.sh
    ```
