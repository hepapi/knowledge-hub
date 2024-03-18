# Restoring RKE2 Clusters

During this process, the cluster will be unavailable.

- ETCD should be restored on the **first master node that was created** in the cluster.
- ETCD restoration process starts by disabling all rke2 services on all nodes.
- Don't forget to remove the `etcd database directory` on secondary master nodes before starting the `rke2-server`.
- ETCD restoration process starts with limitin etcd to single node. 


## Restoring RKE2 Cluster ETCD on Existing Nodes
 
This process will restore the ETCD on the existing nodes. 

If you're adding new nodes to the cluster, you should follow the [Restoring RKE2 Cluster ETCD on New Nodes](#restoring-rke2-cluster-etcd-on-new-nodes) section.


**1)** **On ALL nodes**, disable the `rke2-server` service:
```bash
systemctl disable rke2-server -now
``` 

**2)** **On ALL nodes**, kill all remaining processes:
```bash
rke2-killall.sh
``` 
**3** **On FIRST NODE**, restore etcd:
```bash
rke2 server --cluster-reset \
    --cluster-reset-restore-path=$PATH_TO_SNAPSHOT_FILE
``` 
**4)** **On FIRST NODE**, start the rke2:
```bash
systemctl enable rke2-server -now
systemctl start rke2-server -now
``` 

**5)** **On SECONDARY MASTER NODES**, delete the etcd data directory:
```bash
# delete the old etcd data directory
# make sure the directory is correct for your installation
rm -rf /var/lib/rancher/rke2/server/db
``` 
**6)** **On SECONDARY MASTER NODES**, start the rke2 server:
```bash
systemctl enable rke2-server -now
systemctl start rke2-server -now
``` 

## Restoring RKE2 Cluster ETCD on New Nodes

TODO: add docs