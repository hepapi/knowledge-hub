# NFS Setup Requirements
- 1 Master Node
- 1 Worker Node (NFS)
---
First of all, we save the ip address of our NFS server in the `/etc/hosts` file on all our nodes.(`master - nfs`)

```yaml
/etc/hosts

172.31.18.194 master
172.31.20.138 k8s-ankara-nfs01
```

Then we install the necessary applications for our NFS structure.(`nfs`)

```yaml
sudo apt-get update
sudo apt-get install -y nfs-kernel-server
```

Let's create a directory on our server to store files.(`nfs`)
```yaml
sudo mkdir /k8s-data && sudo mkdir /k8s-data/ankara-data
sudo chmod 1777 /k8s-data/ankara-data
touch /k8s-data/ankara-data/ankara-cluster.txt
```
We need to edit the NFS server file for the directory we just created. At this stage, we will share the directory with all our nodes.(`nfs`)
```yaml
sudo nano /etc/exports
```

After opening, add the following values at the end.(`nfs`)
```yaml
# /etc/exports: the access control list for filesystems which may be exported
#               to NFS clients.  See exports(5).
#
# Example for NFSv2 and NFSv3:
# /srv/homes       hostname1(rw,sync,no_subtree_check) hostname2(ro,sync,no_subtree_check)
#
# Example for NFSv4:
# /srv/nfs4        gss/krb5i(rw,sync,fsid=0,crossmnt,no_subtree_check)
# /srv/nfs4/homes  gss/krb5i(rw,sync,no_subtree_check)
#

/k8s-data/ankara-data *(rw,sync,no_root_squash,subtree_check)
```


Then run the following command to re-read exportfs and confirm the changes.(`nfs`)
```yaml
sudo exportfs -ra
```


Now we will do the following operations on all our Kubernetes nodes.(`master - nfs`)
```yaml
sudo apt-get -y install nfs-common
```


After the installation is finished, we check whether there is an access problem by running the following command on all our nodes.(`master`)
```yaml
showmount -e k8s-ankara-nfs01
```


There does not seem to be any problem. Now we can mount the folder we opened on our NFS server to our nodes.(`master`)
```yaml
sudo mount k8s-ankara-nfs01:/k8s-data/ankara-data /mnt
ls -l /mnt
```

We have made all the setup and adjustments for NFS. We can store the data of our pods without any problems.

---

To make our NFS available to pods, the sample Persistent Volume, Persistent Volume Claim and Pod yaml file should be as follows.
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ankara-cluster-test-pv
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  nfs:
    path: /k8s-data/ankara-data
    server: k8s-ankara-nfs01
    readOnly: false
```
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ankara-pv-claim
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: ""
  resources:
    requests:
      storage: 5Gi
```
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: data-generator-pod
spec:
  containers:
  - name: data-generator-container
    image: alpine
    command: ["/bin/sh", "-c"]
    args:
    - |
      while true; do
        echo "$(date) - Data content: $(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 10)" > /data/data-$(date +%s).txt
        sleep 1
      done
    volumeMounts:
    - name: data-volume
      mountPath: /data
  volumes:
  - name: data-volume
    persistentVolumeClaim:
      claimName: ankara-pv-claim
```
