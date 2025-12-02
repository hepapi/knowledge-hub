Modern Kubernetes clusters running on Amazon EKS often require shared, ReadWriteMany (RWX)–capable storage for applications such as logging, CI/CD systems, caching layers, or shared configuration. While AWS provides multiple storage options, using an existing on-prem or cloud-hosted NFS server remains a simple and powerful solution when RWX support is required with minimum operational overhead.

In this guide, we walk through how to use an existing NFS server as the storage backend for dynamic provisioning in EKS by installing the NFS Subdir External Provisioner via Helm.
This documentation assumes that:

- You already have an accessible NFS server.
- One of its exported directories (e.g., `/pvcdata`) is mounted on a secondary disk.
- Your EKS worker nodes can reach the NFS server over the network.

We will therefore focus on validations, configuration, Helm installation, and real-world test scenarios rather than provisioning the underlying NFS server from scratch.

### Prerequisites & Key Considerations
Before configuring the StorageClass, ensure:

- You have a functional Amazon EKS cluster.
- Worker nodes have network reachability to the NFS server (routing, firewalls, SGs, NACLs, VPN, or Direct Connect).
- NFS server is exporting a shared directory (e.g., `/pvcdata`).
- Correct NFS permissions, export rules, and versions are configured.
- Worker nodes have nfs-utils installed.
  
## Step-by-Step Configuration

### Ensure that NFS Server is Running

Verify that the server is active and that port 2049 (NFS service port) is listening:

```bash
systemctl status nfs-server
sudo netstat -tulpn | grep 2049
```

If the service is down, start and enable it:

```bash
sudo systemctl enable --now nfs-server
```

### Validate NFS Version Configuration

Check the supported NFS protocol versions:

```bash
cat /etc/nfs.conf | grep vers
```
For EKS workloads, NFSv4+ is preferred. Expected configuration:

```bash
  # vers4=y
  # vers4.0=y
  # vers4.1=y
  # vers4.2=y
```

### Verify Available Disks and Mounted Paths

Confirm the mounted directory that will be used to store Kubernetes PV data:

```bash
lsblk -f
```
For this documentation, we assume the exported path is `/pvcdata`

### Validate NFS Exports

Check the export list:

```bash
showmount -e <NFS-SERVER-IP>
```
You should see:

```bash
Export list for <NFS-SERVER-IP>:
/pvcdata 172.28.120.0/24
```

Instead of defining each worker node’s IP address individually, it is more efficient to authorize the entire worker node subnet (CIDR range) in the export configuration.

### Review Export Settings for Subdirectory Creation

Ensure your export flags allow dynamic folder creation by the provisioner:

```bash
cat /etc/exports
```

The entry should look like:

```bash
/pvcdata 172.28.120.0/24 (rw,sync,no_subtree_check,no_root_squash)
```

If any required export options are missing (such as `no_root_squash`), add them to your `/etc/exports` file and reload the NFS export configuration:
  
```bash
sudo exportfs -rav
```

### Check Directory Ownership & Permissions

To ensure the NFS subdir-external-provisioner can write PVC folders correctly, verify the parent directory permissions:

```bash
ls -ld /pvcdata
```

You should see `drwxrwxrwx` or `drwxr-xr-x`. If the permissions are too restrictive, you can adjust them using:

```bash
sudo chmod 775 /pvcdata
sudo chown -R nobody:nogroup /pvcdata
```

In certain environments, especially when multiple clients or services need unrestricted write access, you may temporarily require 777 permissions, but use this only when necessary as it grants full access to everyone.

### Install NFS Utilities on Worker Nodes

Worker nodes must have NFS client dependencies installed:

```bash
rpm -qa | grep nfs-utils
sudo yum install -y nfs-utils
```

We assume the operating system is RHEL; if you're using a different distribution, adjust the package manager commands accordingly.

## Install NFS Subdir External Provisioner on EKS

We’ll now continue by installing the `nfs-subdir-external-provisioner` in our cluster using Helm.

### Add the Helm Repository

```bash
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm repo update
```

### Install the provisioner

Create a custom `nfs-values.yaml` file to define your NFS configuration, StorageClass behavior, and deployment strategy.

Below is an example configuration you can adapt:

```yaml
replicaCount: 1
strategyType: Recreate

nfs:
  server: <NFS-SERVER-IP>
  path: /pvcdata

storageClass:
  create: true
  defaultClass: true
  name: nfs-client
  reclaimPolicy: Retain
  provisionerName: cluster.local/nfs-subdir-external-provisioner
  allowVolumeExpansion: true
  accessModes: ReadWriteMany
  onDelete: retain
```

Important fields explained:

- `nfs.server` – The IP address of your NFS server.
- `nfs.path` – Base directory where PVC subdirectories will be created.
- `storageClass.name` – Name used when binding PVCs (storageClassName: nfs-client).
- `reclaimPolicy: Retain` – Keeps data even if the PVC is deleted.
- `accessModes: ReadWriteMany` – Enables multi-node read/write access, the main reason to use NFS.

Once your `nfs-values.yaml` file is ready, install the provisioner using Helm:

```bash
helm upgrade -i nfs-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
  -n nfs-storage \
  -f nfs-values.yaml \
  --create-namespace
```
This will deploy the provisioner, create the StorageClass, and enable dynamic PVC provisioning backed by your NFS server.

### Validate the Deployment

```bash
kubectl get pods -n nfs-storage
kubectl get storageclass
```

You should now see:
  - Pods in `Running` state
  - A StorageClass named `nfs-client` (as default)

## Testing NFS in the Cluster

After installing the NFS Subdir External Provisioner, you can validate that dynamic provisioning and RWX access work correctly by deploying a simple test workload.

This test will:

- Create a PVC using the nfs-client StorageClass
- Mount it on every node via a DaemonSet
- Write periodic timestamps into node-specific subdirectories
- Confirm that all nodes can read/write to the same NFS share

### Create the Test Workload

Apply the following manifest:

```yaml
# test-nfs.yaml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs-test
  namespace: nfs-storage
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 100Gi
  storageClassName: nfs-client
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nfs-test-ds
  namespace: nfs-storage
spec:
  selector:
    matchLabels:
      app: nfs-test
  template:
    metadata:
      labels:
        app: nfs-test
    spec:
      containers:
      - name: tester
        image: registry.k8s.io/nginx:latest
        env:
        - name: NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        command:
          [
            "sh",
            "-c",
            "mkdir -p /data/${NODE_NAME}; \
             while true; do echo $(date) >> /data/${NODE_NAME}/test.txt; sleep 60; done"
          ]
        volumeMounts:
        - name: nfs-data
          mountPath: /data
      volumes:
      - name: nfs-data
        persistentVolumeClaim:
          claimName: nfs-test

```
Important fields explained:

- `persistentVolumeClaim` → storageClassName -- Ensures the PVC uses the NFS StorageClass (nfs-client).
- `DaemonSet` -- Creates one pod per node so you can test multi-node NFS RWX behavior.
- `env.NODE_NAME` -- Injects the node name into each pod to create node-specific directories.
- `command` -- Creates a folder per node and writes timestamps every 60 seconds.
- `volumeMounts / volumes` -- Mounts the PVC at /data inside each tester pod.


Then apply it:

```bash
kubectl apply -f test-nfs.yaml
kubectl get pvc -n nfs-storage
kubectl get pods -n nfs-storage
```

### Check Logs on Any Pod

Pick any pod and check the logs:

```bash
kubectl exec -it <pod-name> -n nfs-storage -- tail -f /data/<NODE-IP>test.txt
```

Each node should write its own timestamps into its own subdirectory on the NFS server.
The structure created on NFS should look like:

```bash
    /data/node1-name/test.txt
    /data/node2-name/test.txt
    /data/node3-name/test.txt
    ...
```

and the content:

```bash
    Mon Dec 1 12:54:17 UTC 2025
    Mon Dec 1 12:55:17 UTC 2025
    Mon Dec 1 12:56:17 UTC 2025
    ...
```
Each folder contains a test.txt file with timestamps written by the corresponding node.

This verifies that:

- The PVC was dynamically provisioned
- The DaemonSet successfully mounted NFS
- All nodes can write simultaneously via RWX
- The provisioner creates correct subdirectory structures


## Validate on the NFS Server

From the NFS host:

```bash
ls /pvcdata
cat /pvcdata/nfs-storage-nfs-test-pvc-*/test.txt
```

Example output:

```bash
[root@NFS-SERVER ~]# ls /pvcdata
nfs-storage-nfs-test-pvc-34f97028-6953-46ee-b6f4-3129f06023c9
nfs-storage-nfs-test-pvc-98e5a1f7-c1c3-4172-a326-d0e248a715f0
nfs-storage-nfs-test-pvc-a4b380b8-30b2-470e-8349-138d00b21c84
...
[root@NFS-SERVER ~]# cat /pvcdata/nfs-storage-nfs-test-pvc-*/test.txt
Mon Dec 1 12:41:25 UTC 2025
Mon Dec 1 12:41:25 UTC 2025
Mon Dec 1 12:41:30 UTC 2025
Mon Dec 1 12:42:25 UTC 2025
Mon Dec 1 12:42:25 UTC 2025
Mon Dec 1 12:42:30 UTC 2025
Mon Dec 1 12:43:25 UTC 2025
Mon Dec 1 12:43:25 UTC 2025
Mon Dec 1 12:43:30 UTC 2025
...
```

This confirms:

- Subdirectories are created dynamically
- Data is written by each node
- NFS StorageClass is operational cluster-wide
