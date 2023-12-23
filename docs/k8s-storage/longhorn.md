Hello everybody! 🫡

Today I'm going to tell you about Longhorn Block Storage.
First of all, what is Longhorn? What is it for? Why is it used? Let's find out... 💪

Longhorn is a lightweight, reliable, and easy-to-use distributed block storage system for Kubernetes.

Longhorn is free, open-source software. Originally developed by Rancher Labs, it is now being developed as an incubating project of the Cloud Native Computing Foundation.

With Longhorn, you can:

-    Use Longhorn volumes as persistent storage for the distributed stateful applications in your Kubernetes cluster
-    Partition your block storage into Longhorn volumes so that you can use Kubernetes volumes with or without a cloud provider
-    Replicate block storage across multiple nodes and data centers to increase availability
-    Store backup data in external storage such as NFS or AWS S3
-    Create cross-cluster disaster recovery volumes so that data from a primary Kubernetes cluster can be quickly recovered from backup in a second Kubernetes cluster
-    Schedule recurring snapshots of a volume, and schedule recurring backups to NFS or S3-compatible secondary storage
-    Restore volumes from backup
-    Upgrade Longhorn without disrupting persistent volumes


So what have we learned about Longhorn so far? Now let's see how we install K8s on it.

📌 First of all, we need to set up the `helm` in our cluster.

Okay, let's go on now.

Now let's add ``Longhorn`` to the helm repository and update our repom.
```yaml
helm repo add longhorn https://charts.longhorn.io 
Helm repo update
```

If we get here smoothly, we can go on.

Next, we have to set up the Longhorn. Let's create a new namespace and install Longhorn. 👇

```yaml
kubectl create namespace longhorn-system helm install longhorn longhorn/longhorn --namespace longhorn-system
```

Installation finished ✅

How easy it was, wasn't it? It would be nice to see Longhorn as the UI at once,is it? Let's do that.

```yaml
kubectl get service -n longhorn-system
```

Let's list ``longhorn-frontend`` with the command above. And with the command below, let's get this service ``port-forward``.

```yaml
kubectl port-forward -n longhorn-system service/longhorn-frontend 8080:80
```

We need to test the last ``Longhorn`` that we set up, right?

```yaml
helm install my-release oci://registry-1.docker.io/bitnamicharts/mysql
```

Let's use the following command to display bitnamicharts/mysql ``PersistentVolume, PersistentVolumeClaim`` and the `Longhorn StorageClass` that we have installed.

```yaml
kubectl get pv,pvc -n default
kubectl get storageclass -n default
```

Now visit `localhost:8080` and enjoy ``longhorn``.

In fact, the ``Longhorn`` installation is so simple. See you on the next blog. 🎈