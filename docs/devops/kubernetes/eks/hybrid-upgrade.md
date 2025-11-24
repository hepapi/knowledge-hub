# Upgrading an EKS Hybrid Cluster Using nodeadm

Recommend Way - `Cutover Migration`:
- Create new hybrid nodes on your target Kubernetes version
- Gracefully migrate your existing applications to the hybrid nodes on the new Kubernetes version
- Remove the hybrid nodes on the old Kubernetes version from your cluster

If you do not have spare capacity to create new hybrid nodes:
- In-place upgrade - `nodeadm upgrade`

### Prerequisites:
- If you are following a cutover migration upgrade strategy, the new hybrid nodes you are installing on your target Kubernetes version must meet the [Prerequisite setup for hybrid nodes requirements](https://docs.aws.amazon.com/eks/latest/userguide/hybrid-nodes-networking.html#hybrid-nodes-networking-on-prem)
- The version of your CNI must support the Kubernetes version you are upgrading to. 
 
  ✔ Cilium versions `v1.17.x` and `v1.18.x` are supported for EKS Hybrid Nodes for every Kubernetes version supported in Amazon EKS.

  **Check the installed Cilium version (via Helm):**
  ```bash
  helm list -n kube-system -o json | jq -r '.[] | select(.name=="cilium")
  ```

### In-place Upgrade:

The in-place upgrade process refers to [using nodeadm upgrade to upgrade the Kubernetes version for hybrid nodes](https://github.com/aws/eks-hybrid) without using new physical or virtual hosts and a cutover migration strategy. The nodeadm upgrade process shuts down the existing older Kubernetes components running on the hybrid node, uninstalls the existing older Kubernetes components, installs the new target Kubernetes components, and starts the new target Kubernetes components. It is strongly recommend to upgrade one node at a time to minimize impact to applications running on the hybrid nodes. The duration of this process depends on your network bandwidth and latency.

### Steps:

#### 1- Cordon and drain the node
```bash
export NODE_NAME=<NODE_NAME>
kubectl drain $NODE_NAME --ignore-daemonsets --delete-emptydir-data --force
```
This safely evicts running workloads and prevents new pods from being scheduled on the node.
#### 2- Validate the nodeConfig and verify SSM connectivity
```bash
nodeadm debug -c file://nodeConfig.yaml
```
Make sure the node can successfully communicate via the SSM Agent and that the configuration is valid.
#### 3- Upgrade the node Kubernetes version using nodeadm
```bash
nodeadm upgrade <K8S_VERSION> -c file://nodeConfig.yaml
```
#### 4- Uncordon the node
```bash
kubectl uncordon $NODE_NAME
kubectl get nodes -o wide -w
```
#### 5- Check the status
```bash
kubectl get node $NODE_NAME -o wide
kubectl describe node $NODE_NAME
kubectl get pods -A -o wide --field-selector spec.nodeName=$NODE_NAME
```

- ✔ Node is in Ready state
- ✔ Correct Kubernetes version
- ✔ No unusual taints or warnings

#### 6- Repeat for remaining nodes (one at a time)
Always upgrade one node only at a time to avoid capacity issues or service disruption.
