# System Upgrade Controller


[rancher/system-upgrade-controller](https://github.com/rancher/system-upgrade-controller)

[RKE2 Docs: Automatic Upgrades](https://docs.rke2.io/upgrade/automated_upgrade)



## Prerequisites

- Highly Available RKE2 Cluster
- Install the `system-upgrade-controller` on the cluster

Visit for the latest installation instructions: [RKE2 Docs: Install the system-upgrade-controller](https://docs.rke2.io/upgrade/automated_upgrade#install-the-system-upgrade-controller)

For now, the command is: (**the version might change, better to follow the docs**)
```bash
kubectl apply -f https://github.com/rancher/system-upgrade-controller/releases/download/v0.9.1/system-upgrade-controller.yaml
```

## Upgrading Master Nodes 1-by-1

**1)** **[ATTENTION]** Decide on which version of RKE2 to upgrade to.
```bash
# Kubernetes Label: remove '+' and replace with '-' or it doesnt work

# TODO: SET THIS TO A RELEASE NUMBER or `latest` or `stable` works as well
export RKE2_UPGRADE_VERSION="v1.21.14+rke2r1" 
export RKE2_UPGRADE_VERSION_SAFE_STRING=$(echo -n $RKE2_UPGRADE_VERSION | tr '+' '-')
# "v1.21.14+rke2r1" --becomes--> "v1.21.14-rke2r1"
```

**2)** **[ATTENTION]** Create Master Node Upgrade Plan yaml file.

This command will create a file named `rke2-master-upgrade-plan-$RKE2_UPGRADE_VERSION_SAFE_STRING.yaml`

This plan can only be applied to master nodes that have the labels:

- `rke2-upgrade`: `enabled`
- `rke2-upgrade-to`: $RKE2_UPGRADE_VERSION_SAFE_STRING

You can also add the label `rke2-upgrade: disabled` to a master node to prevent it from being upgraded.
```bash
# create the upgrade-plan for it 
cat << EOF > rke2-master-upgrade-plan-$RKE2_UPGRADE_VERSION_SAFE_STRING.yaml
apiVersion: upgrade.cattle.io/v1
kind: Plan
metadata:
  name: server-plan-for-$RKE2_UPGRADE_VERSION_SAFE_STRING
  namespace: system-upgrade
  labels:
    rke2-upgrade: server
spec:
  concurrency: 1
  nodeSelector:
    matchExpressions:
      - {key: node-role.kubernetes.io/control-plane, operator: In, values: ["true"]}
      - {key: rke2-upgrade, operator: Exists}
      - {key: rke2-upgrade, operator: NotIn, values: ["disabled", "false"]}
      - {key: rke2-upgrade-to, operator: In, values: ["$RKE2_UPGRADE_VERSION_SAFE_STRING"]}
  serviceAccountName: system-upgrade
  cordon: true
  drain:
    force: true
  upgrade:
    image: rancher/rke2-upgrade
  version: "$RKE2_UPGRADE_VERSION"
EOF

```

**3)** Apply the `Plan` to the cluster

This will not upgrade the nodes. That'll happen when we label the nodes correctly.


`Plan` will create `Job`s for each master node that has the labels:

  - `rke2-upgrade`: `enabled`
  - `rke2-upgrade-to`: $RKE2_UPGRADE_VERSION_SAFE_STRING

```bash
# apply the plan and check it
kubectl apply -f rke2-master-upgrade-plan-$RKE2_UPGRADE_VERSION_SAFE_K8S_LABEL.yaml

# check the plan and jobs
kubectl -n system-upgrade get plans,jobs
```
**4)** **[OPTIONAL]** Disable a node from upgrading
```bash
kubectl label nodes <node-name> rke2-upgrade=disabled --overwrite
```

**5)** **[ATTENTION]** Labeling & Upgrading the master nodes 1-by-1

This step should be done for each master node **one after other**.

Labeling the master nodes will trigger an automatic upgrade.

**Do this step for all master nodes one after other.**

```bash
echo "RKE2_UPGRADE_VERSION=$RKE2_UPGRADE_VERSION"
echo "RKE2_UPGRADE_VERSION_SAFE_K8S_LABEL=$RKE2_UPGRADE_VERSION_SAFE_K8S_LABEL"

# label the a master node to upgrade
kubectl label nodes <node-name> rke2-upgrade=enabled --overwrite
kubectl label nodes <node-name> rke2-upgrade-to=$RKE2_UPGRADE_VERSION_SAFE_STRING --overwrite

# check if a job is created for the upgrade of the node
kubectl -n system-upgrade get jobs,plans

# watch as the node is upgraded
kubectl get nodes --watch
```