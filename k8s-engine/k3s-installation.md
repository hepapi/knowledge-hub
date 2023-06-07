# K3S Setup :fire:

##### :information_source: K3S Requirements :


| Resources      | Limits                                                       |
| -----------    | ------------------------------------                         |
| `512MB`          | :fontawesome-solid-memory: MEMORY (we recommend at least 1GB)|
| `1CPU`            | :octicons-cpu-16: CPU (we recommend at least 2CPU)           |
| `20GB`         | :material-database:     STORAGE                              |


#CPU and Memory
The following are the minimum CPU and memory requirements for nodes in a high-availability K3S server

| Deployment Size      | Nodes   | VCPUS | RAM
| -----------    | -------------- | ------ | ------
| Small          | Up to 10 | 2 | 4 GB
| Medium           | Up to 100 | 4| 8 GB
| Large         |  Up to 250   | 8| 16 GB
| X-Large      |  Up to 500   | 16| 32 GB
| XX-Large        |  500+   | 32| 64 GB

### Disks
:warning: The cluster performance depends on database performance. To ensure optimal speed, we recommend always using SSD disks to back your K3S cluster. On cloud providers, you will also want to use the minimum size that allows the maximum IOPS.

#Database
K3S supports different databases including MySQL, PostgreSQL, MariaDB, and etcd, the following is a sizing guide for the database resources you need to run large clusters:

|Deployment Size      | Nodes   | VCPUS | RAM
| -----------    | -------------- | ------ | ------
| Small          | Up to 10 | 1 | 2 GB
| Medium           | Up to 100 | 2| 8 GB
| Large         |  Up to 250   | 4| 16 GB
| X-Large      |  Up to 500   | 8| 32 GB
| XX-Large        |  500+   | 16| 64 GB

# Single Master Node K3S Install

A single-node server installation is a fully-functional Kubernetes cluster, including all the datastore, control-plane, kubelet, and container runtime components necessary to host workload pods. It is not necessary to add additional server or agents nodes, but you may want to do so to add additional capacity or redundancy to your cluster.

`Run this command :`
```bash
curl -sfL https://get.k3s.io | sh -
```



# High Available K3S Install
To run K3S in this mode, you must have an odd number of server nodes. We recommend starting with three nodes.

To get started, first launch a server node with the `cluster-init` flag to enable clustering and a token that will be used as a shared secret to join additional servers to the cluster.

```bash
curl -sfL https://get.k3s.io | K3S_TOKEN=SECRET sh -s - server --cluster-init
```
!!! success

    Let's validate everything worked as expected. Run a `systemctl status k3s.service` and make sure it is `active`.
    ```bash
    ● k3s.service - Lightweight Kubernetes
     Loaded: loaded (/etc/systemd/system/k3s.service; enabled; vendor preset: enabled)
     Active: {++active++} (running) since Tue 2023-06-06 13:54:17 UTC; 37min ago
       Docs: https://k3s.io
    ```

After launching the first server, join the second and third servers to the cluster using the shared secret:
```bash
curl -sfL https://get.k3s.io | K3S_TOKEN=SECRET sh -s - server --server https://<ip or hostname of server1>:6443
```

####Cluster Access
The kubeconfig file stored at `/etc/rancher/k3s/k3s.yaml` is used to configure access to the Kubernetes cluster. If you have installed upstream Kubernetes command line tools such as kubectl or helm you will need to configure them with the correct kubeconfig path.This can be done by either exporting the `KUBECONFIG` environment variable or by invoking the `--kubeconfig` command line flag. Refer to the examples below for details.

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

Check to see that the second and third servers are now part of the cluster:
```
$ kubectl get nodes

NAME        STATUS   ROLES                       AGE   VERSION
server1     Ready    control-plane,etcd,master   28m   vX.Y.Z
server2     Ready    control-plane,etcd,master   13m   vX.Y.Z
server3     Ready    control-plane,etcd,master   10m   vX.Y.Z
```

#K3S Agent Install

To install additional agent nodes and add them to the cluster, run the installation script with the `K3S_URL` and `K3S_TOKEN` environment variables. Here is an example showing how to join an agent:
```bash
curl -sfL https://get.k3s.io | K3S_URL=https://myserver:6443 K3S_TOKEN=mynodetoken sh -
```
!!! success

    Let's validate everything worked as expected. Run a `systemctl status k3s-agent` and make sure it is `active`.
    ```bash
    ● k3s-agent.service - Lightweight Kubernetes
     Loaded: loaded (/etc/systemd/system/k3s-agent.service; enabled; vendor preset: enabled)
     Active: {++active++} (running) since Tue 2023-06-06 14:24:53 UTC; 7min ago
       Docs: https://k3s.io
    ```


Setting the `K3S_URL` parameter causes the installer to configure K3S as an agent, instead of a server. The K3S agent will register with the K3S server listening at the supplied URL. if you have not set a stable token the value to use for `K3S_TOKEN` is stored at `/var/lib/rancher/k3s/server/node-token` on your server node.

!!! example

    === "Leverage the KUBECONFIG environment variable:"

        ```bash
        export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
        kubectl get pods --all-namespaces
        helm ls --all-namespaces
        ```
    === "Or specify the location of the kubeconfig file in the command:"

        ```bash
        kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml get pods --all-namespaces
        helm --kubeconfig /etc/rancher/k3s/k3s.yaml ls --all-namespaces
        ```

#Uninstalling K3S

!!! example

    === "Uninstalling Servers:"

        ```bash
        /usr/local/bin/k3s-uninstall.sh
        ```
    === "Uninstalling Agents:"

        ```bash
        /usr/local/bin/k3s-agent-uninstall.sh
        ```

!!! danger annanote  "[Make sure all required port numbers are open](https://docs.k3s.io/installation/requirements#inbound-rules-for-k3s-server-nodes)"

[For More Details](https://docs.k3s.io/)

