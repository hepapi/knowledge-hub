# RKE2 Setup

##### RKE2 Requirements :


| Resources      | Limits                                                       |
| -----------    | ------------------------------------                         |
| `4GB`          | :fontawesome-solid-memory: MEMORY (we recommend at least 8GB)|
| `2`            | :octicons-cpu-16: CPU (we recommend at least 4CPU)           |
| `60GB`         | :material-database:     STORAGE                              |



We turn off the firewall to avoid problems in the future. We update the packages and clean up any files left over from previous installations.


**Ubuntu**:

!!! note ""

    ```bash
    # Ubuntu instructions 
    # stop the software firewall
    systemctl disable --now ufw

    # get updates, install nfs, and apply
    apt update
    apt install nfs-common -y  
    apt upgrade -y

    # clean up
    apt autoremove -y
    ```

Now that we have all the nodes up to date, let's focus on `rancher1`. While this might seem controversial, `curl | bash` does work nicely. The install script will use the tarball install for **Ubuntu** and the RPM install for **Rocky/Centos**. Please be patient, the start command can take a minute. Here are the [rke2 docs](https://docs.rke2.io/install/methods/) and [install options](https://docs.rke2.io/install/install_options/install_options/) for reference.

###RKE2 Server Install

!!! note ""

    ```bash
    #rancher1

    url -sfL https://get.rke2.io | sh -

    mkdir -p /etc/rancher/rke2/
    cat << EOF > /etc/rancher/rke2/config.yaml
    kube-apiserver-arg: "kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname"
    EOF

    # enable and start
    systemctl enable --now rke2-server.service
    ```

!!! quote

    If you want to install a specific version use the following command ;

    ```
    curl -sfL https://get.rke2.io | INSTALL_RKE2_CHANNEL=v1.24 INSTALL_RKE2_TYPE=server sh -
    ```


Perfect! Now we can start talking Kubernetes. We need to symlink the `kubectl` cli on `rancher1` that gets installed from RKE2.


!!! note ""

    ```bash
    # add kubectl conf
    echo 'export PATH=$PATH:/var/lib/rancher/rke2/bin KUBECONFIG=/etc/rancher/rke2/rke2.yaml' >> ~/.bashrc

    # check node status
    kubectl get node
    ```

We will also need to get the token from `rancher1`.

!!! note ""

    ```bash
    # save this for rancher2 and rancher3
    cat /var/lib/rancher/rke2/server/node-token
    ```

### RKE2 Agent Install

The agent install is VERY similar to the server install. Except that we need an agent config file before starting. We will start with `rancher2`. We need to install the agent and setup the configuration file.

!!! note ""

    ```bash

    # we add INSTALL_RKE2_TYPE=agent
    curl -sfL https://get.rke2.io 

    # create config file
    mkdir -p /etc/rancher/rke2/ 

    # change the ip to reflect your rancher1 ip
    echo "server: https://$RANCHER1_IP:9345" > /etc/rancher/rke2/config.yaml

    # change the Token to the one from rancher1 /var/lib/rancher/rke2/server/node-token 
    echo "token: $TOKEN" >> /etc/rancher/rke2/config.yaml

    # enable and start
    systemctl enable --now rke2-agent.service
    ```

!!! info "If you want to add your Node as control plane, etcd replace here with below code"


!!! example

    === "Orjinal Code"

        ```
        systemctl enable --now rke2-agent.service
        ```
    === "Change Code"

        ```
        systemctl enable --now rke2-server.service
        ```
 
  Rinse and repeat. Run the same install commands on `rancher2`, `rancher3`. Next we can validate all the nodes are playing nice by running kubectl get node -o wide on rancher1. 

#### Run this code !

!!! note ""

    ```
    kubectl get node
    ```

---


!!! warning annanote  "Important Installations Notes"

 If you are having problems with installations, make sure there are no problems with instances' accessing each other `(For Example --Ssh connection--: Permission Denied)`

!!! failure "Check These Steps"

    - Check below steps if RKE2-Server or RKE2-Agent is not working 
    - Rancher1 instances Node Token is correct ? 
    - Instances IP address is Correct ? 
    - Instance Ports is open (9345, 6443) ?





