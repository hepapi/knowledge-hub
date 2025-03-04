# KEDA (Kubernetes Event-driven Autoscaling) WITH CRON

[![CNCF Status](https://img.shields.io/badge/cncf%20status-sandbox-blue.svg)](https://www.cncf.io/projects)
[![License](https://img.shields.io/github/license/kedacore/keda.svg)](https://github.com/kedacore/keda/blob/main/LICENSE)
[![Releases](https://img.shields.io/github/release/kedacore/keda/all.svg)](https://github.com/kedacore/keda/releases)

## What is KEDA ?

KEDA (Kubernetes Event-driven Autoscaling) is an open-source project that provides event-driven autoscaling capabilities in your Kubernetes environment. KEDA extends Kubernetes' HPA (Horizontal Pod Autoscaler) system, allowing you to scale your applications based on metrics beyond CPU and memory.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
  - [Installation with Helm](#installation-with-helm)
  - [Installation with YAML](#installation-with-yaml)
- [Scaling with Cron](#scaling-with-cron)
  - [Creating a ScaledObject](#creating-a-scaledobject)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)


## Prerequisites

- Kubernetes cluster (v1.16+)
- `kubectl` CLI
- (Optional) Helm 3
- Cluster admin privileges

## Installation

### Installation with Helm


```bash
# Add Helm repository
helm repo add kedacore https://kedacore.github.io/charts
helm repo update

# Create KEDA namespace
kubectl create namespace keda

# Install KEDA
helm install keda kedacore/keda --namespace keda
```

### Installation with YAML

```bash
# Install the latest version
kubectl apply -f https://github.com/kedacore/keda/releases/download/v2.11.0/keda-2.11.0.yaml
```

Verify the installation:

```bash
kubectl get pods -n keda
```

Expected output:
```
NAME                                      READY   STATUS    RESTARTS   AGE
keda-operator-7c8d65d96d-bzmqp            1/1     Running   0          30s
keda-operator-metrics-apiserver-7d9fd868b5-kvppj   1/1     Running   0          30s
```



## Scaling with Cron


### Creating a ScaledObject

ScaledObject is the core component KEDA uses to scale Kubernetes deployments.

1. Create a sample deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cron-app
  namespace: test
  labels:
    app: cron-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cron-app
  template:
    metadata:
      labels:
        app: cron-app
    spec:
      containers:
      - name: cron-app
        image: nginx
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: cron-app-service
  namespace: test
spec:
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: cron-app
```
Apply the deployment:

```bash
kubectl apply -f deployment.yaml
```
Verify the deployment:

```bash
kubectl get pods -n test
```

Expected output:
```
NAME                       READY   STATUS    RESTARTS   AGE

cron-app-5df76bc88b-67krr   1/1     Running   0         33s
```

2. Define a ScaledObject:

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: cron-app-scaledobject
  namespace: test
spec:
  scaleTargetRef:
    name: cron-app
  minReplicaCount: 1
  maxReplicaCount: 20
  triggers:
  - type: cron
    metadata:
      # Timezone
      timezone: "Europe/Amsterdam"
      # Scaling start time (e.g., starts every day at 08:45)
      start: "45 8 * * *"
      # Scaling end time (e.g., ends every day at 08:50)
      end: "50 8 * * *"
      # Desired number of pods during this time range
      desiredReplicas: "20"
```
```
Apply the ScaledObject:

```bash
kubectl apply -f scaleObject.yaml
```
Verify the ScaledObject:

```bash
kubectl get so -n test
```

Expected output:
```
NAME                    SCALETARGETKIND      SCALETARGETNAME   MIN   MAX   READY   ACTIVE    FALLBACK   PAUSED    TRIGGERS   AUTHENTICATIONS   AGE
cron-app-scaledobject   apps/v1.Deployment   cron-app          1     20    True    Unknown   False      Unknown                                18s
```

When the clock hits 08:45, the ScaledObject will activate and begin scaling the related service during the specified time range.

Expected output when the ScaledObject is triggered:
```bash
NAME                        READY   STATUS            RESTARTS    AGE
cron-app-5df76bc88b-67krr   1/1     Running             0          7m8s
cron-app-5df76bc88b-fqffn   0/1     Pending             0          0s
cron-app-5df76bc88b-fqffn   0/1     Pending             0          0s
cron-app-5df76bc88b-8llrz   0/1     Pending             0          0s
cron-app-5df76bc88b-qk8qw   0/1     Pending             0          0s
cron-app-5df76bc88b-8llrz   0/1     Pending             0          0s
cron-app-5df76bc88b-qk8qw   0/1     Pending             0          0s
cron-app-5df76bc88b-fqffn   0/1     ContainerCreating   0          0s
cron-app-5df76bc88b-qk8qw   0/1     ContainerCreating   0          0s
cron-app-5df76bc88b-8llrz   0/1     ContainerCreating   0          0s
cron-app-5df76bc88b-8llrz   1/1     Running             0          2s
cron-app-5df76bc88b-fqffn   1/1     Running             0          3s
cron-app-5df76bc88b-qk8qw   1/1     Running             0          5s
cron-app-5df76bc88b-6ltbp   0/1     Pending             0          0s
cron-app-5df76bc88b-6ltbp   0/1     Pending             0          0s
cron-app-5df76bc88b-smfnl   0/1     Pending             0          0s
cron-app-5df76bc88b-dbkzx   0/1     Pending             0          0s
cron-app-5df76bc88b-29854   0/1     Pending             0          0s
cron-app-5df76bc88b-smfnl   0/1     Pending             0          0s
cron-app-5df76bc88b-dbkzx   0/1     Pending             0          0s
cron-app-5df76bc88b-6ltbp   0/1     ContainerCreating   0          0s
cron-app-5df76bc88b-29854   0/1     Pending             0          0s
cron-app-5df76bc88b-dbkzx   0/1     ContainerCreating   0          0s
cron-app-5df76bc88b-smfnl   0/1     ContainerCreating   0          0s
cron-app-5df76bc88b-29854   0/1     ContainerCreating   0          0s
cron-app-5df76bc88b-smfnl   1/1     Running             0          2s
cron-app-5df76bc88b-6ltbp   1/1     Running             0          3s
cron-app-5df76bc88b-dbkzx   1/1     Running             0          4s
cron-app-5df76bc88b-29854   1/1     Running             0          7s
cron-app-5df76bc88b-hvrc8   0/1     Pending             0          0s
cron-app-5df76bc88b-mrws9   0/1     Pending             0          0s
cron-app-5df76bc88b-hvrc8   0/1     Pending             0          0s
cron-app-5df76bc88b-jnpm6   0/1     Pending             0          0s
cron-app-5df76bc88b-mrws9   0/1     Pending             0          0s
cron-app-5df76bc88b-jnpm6   0/1     Pending             0          0s
cron-app-5df76bc88b-rgkcz   0/1     Pending             0          0s
cron-app-5df76bc88b-xjl9c   0/1     Pending             0          0s
cron-app-5df76bc88b-c9lrj   0/1     Pending             0          0s
cron-app-5df76bc88b-9mxl8   0/1     Pending             0          0s
cron-app-5df76bc88b-rgkcz   0/1     Pending             0          0s
cron-app-5df76bc88b-xjl9c   0/1     Pending             0          0s
cron-app-5df76bc88b-c9lrj   0/1     Pending             0          0s
cron-app-5df76bc88b-hvrc8   0/1     ContainerCreating   0          0s
cron-app-5df76bc88b-9mxl8   0/1     Pending             0          0s
cron-app-5df76bc88b-qcdfx   0/1     Pending             0          0s
cron-app-5df76bc88b-qcdfx   0/1     Pending             0          0s
cron-app-5df76bc88b-mrws9   0/1     ContainerCreating   0          0s
cron-app-5df76bc88b-jnpm6   0/1     ContainerCreating   0          0s
cron-app-5df76bc88b-9mxl8   0/1     ContainerCreating   0          0s
cron-app-5df76bc88b-xjl9c   0/1     ContainerCreating   0          0s
cron-app-5df76bc88b-qcdfx   0/1     ContainerCreating   0          0s
cron-app-5df76bc88b-rgkcz   0/1     ContainerCreating   0          0s
cron-app-5df76bc88b-c9lrj   0/1     ContainerCreating   0          0s
cron-app-5df76bc88b-mrws9   1/1     Running             0          4s
cron-app-5df76bc88b-9mxl8   1/1     Running             0          5s
cron-app-5df76bc88b-qcdfx   1/1     Running             0          6s
cron-app-5df76bc88b-xjl9c   1/1     Running             0          7s
cron-app-5df76bc88b-hvrc8   1/1     Running             0          8s
cron-app-5df76bc88b-jnpm6   1/1     Running             0          9s
cron-app-5df76bc88b-rgkcz   1/1     Running             0          10s
cron-app-5df76bc88b-c9lrj   1/1     Running             0          12s
cron-app-5df76bc88b-mk6d2   0/1     Pending             0          0s
cron-app-5df76bc88b-xxhz9   0/1     Pending             0          0s
cron-app-5df76bc88b-mk6d2   0/1     Pending             0          0s
cron-app-5df76bc88b-pxwn4   0/1     Pending             0          0s
cron-app-5df76bc88b-xxhz9   0/1     Pending             0          0s
cron-app-5df76bc88b-pxwn4   0/1     Pending             0          0s
cron-app-5df76bc88b-hzrg4   0/1     Pending             0          0s
cron-app-5df76bc88b-hzrg4   0/1     Pending             0          0s
cron-app-5df76bc88b-mk6d2   0/1     ContainerCreating   0          0s
cron-app-5df76bc88b-xxhz9   0/1     ContainerCreating   0          0s
cron-app-5df76bc88b-pxwn4   0/1     ContainerCreating   0          0s
cron-app-5df76bc88b-hzrg4   0/1     ContainerCreating   0          0s
cron-app-5df76bc88b-mk6d2   1/1     Running             0          3s
cron-app-5df76bc88b-xxhz9   1/1     Running             0          4s
cron-app-5df76bc88b-pxwn4   1/1     Running             0          5s
cron-app-5df76bc88b-hzrg4   1/1     Running             0          6s
```
Current pod count after the ScaledObject runs within the specified time range:
```bash
k get pod -n test

NAME                        READY   STATUS    RESTARTS   AGE
cron-app-5df76bc88b-29854   1/1     Running   0          69s
cron-app-5df76bc88b-67krr   1/1     Running   0          9m20s
cron-app-5df76bc88b-6ltbp   1/1     Running   0          69s
cron-app-5df76bc88b-8llrz   1/1     Running   0          84s
cron-app-5df76bc88b-9mxl8   1/1     Running   0          54s
cron-app-5df76bc88b-c9lrj   1/1     Running   0          54s
cron-app-5df76bc88b-dbkzx   1/1     Running   0          69s
cron-app-5df76bc88b-fqffn   1/1     Running   0          84s
cron-app-5df76bc88b-hvrc8   1/1     Running   0          54s
cron-app-5df76bc88b-hzrg4   1/1     Running   0          39s
cron-app-5df76bc88b-jnpm6   1/1     Running   0          54s
cron-app-5df76bc88b-mk6d2   1/1     Running   0          39s
cron-app-5df76bc88b-mrws9   1/1     Running   0          54s
cron-app-5df76bc88b-pxwn4   1/1     Running   0          39s
cron-app-5df76bc88b-qcdfx   1/1     Running   0          54s
cron-app-5df76bc88b-qk8qw   1/1     Running   0          84s
cron-app-5df76bc88b-rgkcz   1/1     Running   0          54s
cron-app-5df76bc88b-smfnl   1/1     Running   0          69s
cron-app-5df76bc88b-xjl9c   1/1     Running   0          54s
cron-app-5df76bc88b-xxhz9   1/1     Running   0          39s```
```

Expected output after the specified time range ends:

```bash
cron-app-5df76bc88b-c9lrj   1/1     Terminating         0          9m16s
cron-app-5df76bc88b-jnpm6   1/1     Terminating         0          9m16s
cron-app-5df76bc88b-8llrz   1/1     Terminating         0          9m46s
cron-app-5df76bc88b-fqffn   1/1     Terminating         0          9m46s
cron-app-5df76bc88b-67krr   1/1     Terminating         0          17m
cron-app-5df76bc88b-pxwn4   1/1     Terminating         0          9m1s
cron-app-5df76bc88b-mk6d2   1/1     Terminating         0          9m1s
cron-app-5df76bc88b-xxhz9   1/1     Terminating         0          9m1s
cron-app-5df76bc88b-mrws9   1/1     Terminating         0          9m16s
cron-app-5df76bc88b-6ltbp   1/1     Terminating         0          9m31s
cron-app-5df76bc88b-dbkzx   1/1     Terminating         0          9m31s
cron-app-5df76bc88b-rgkcz   1/1     Terminating         0          9m16s
cron-app-5df76bc88b-qk8qw   1/1     Terminating         0          9m46s
cron-app-5df76bc88b-hzrg4   1/1     Terminating         0          9m1s
cron-app-5df76bc88b-9mxl8   1/1     Terminating         0          9m16s
cron-app-5df76bc88b-29854   1/1     Terminating         0          9m31s
cron-app-5df76bc88b-qcdfx   1/1     Terminating         0          9m16s
cron-app-5df76bc88b-xjl9c   1/1     Terminating         0          9m16s
cron-app-5df76bc88b-hvrc8   1/1     Terminating         0          9m16s
cron-app-5df76bc88b-67krr   0/1     Completed           0          17m
cron-app-5df76bc88b-pxwn4   0/1     Completed           0          9m3s
cron-app-5df76bc88b-mk6d2   0/1     Completed           0          9m3s
cron-app-5df76bc88b-9mxl8   0/1     Completed           0          9m18s
cron-app-5df76bc88b-jnpm6   0/1     Completed           0          9m18s
cron-app-5df76bc88b-xxhz9   0/1     Completed           0          9m3s
cron-app-5df76bc88b-c9lrj   0/1     Completed           0          9m18s
cron-app-5df76bc88b-6ltbp   0/1     Completed           0          9m33s
cron-app-5df76bc88b-hvrc8   0/1     Completed           0          9m18s
cron-app-5df76bc88b-hzrg4   0/1     Completed           0          9m3s
cron-app-5df76bc88b-qk8qw   0/1     Completed           0          9m48s
cron-app-5df76bc88b-fqffn   0/1     Completed           0          9m48s
cron-app-5df76bc88b-mrws9   0/1     Completed           0          9m18s
cron-app-5df76bc88b-8llrz   0/1     Completed           0          9m48s
cron-app-5df76bc88b-xjl9c   0/1     Completed           0          9m18s
cron-app-5df76bc88b-29854   0/1     Completed           0          9m33s
cron-app-5df76bc88b-rgkcz   0/1     Completed           0          9m18s
cron-app-5df76bc88b-qcdfx   0/1     Completed           0          9m18s
cron-app-5df76bc88b-jnpm6   0/1     Completed           0          9m18s
cron-app-5df76bc88b-jnpm6   0/1     Completed           0          9m18s
cron-app-5df76bc88b-67krr   0/1     Completed           0          17m
cron-app-5df76bc88b-67krr   0/1     Completed           0          17m
cron-app-5df76bc88b-dbkzx   0/1     Completed           0          9m33s
cron-app-5df76bc88b-9mxl8   0/1     Completed           0          9m18s
cron-app-5df76bc88b-9mxl8   0/1     Completed           0          9m18s
cron-app-5df76bc88b-pxwn4   0/1     Completed           0          9m3s
cron-app-5df76bc88b-pxwn4   0/1     Completed           0          9m3s
cron-app-5df76bc88b-mk6d2   0/1     Completed           0          9m3s
cron-app-5df76bc88b-mk6d2   0/1     Completed           0          9m3s
cron-app-5df76bc88b-xxhz9   0/1     Completed           0          9m3s
cron-app-5df76bc88b-xxhz9   0/1     Completed           0          9m3s
cron-app-5df76bc88b-29854   0/1     Completed           0          9m33s
cron-app-5df76bc88b-29854   0/1     Completed           0          9m33s
cron-app-5df76bc88b-c9lrj   0/1     Completed           0          9m18s
cron-app-5df76bc88b-c9lrj   0/1     Completed           0          9m18s
cron-app-5df76bc88b-hvrc8   0/1     Completed           0          9m18s
cron-app-5df76bc88b-hvrc8   0/1     Completed           0          9m18s
cron-app-5df76bc88b-qk8qw   0/1     Completed           0          9m48s
cron-app-5df76bc88b-qk8qw   0/1     Completed           0          9m48s
cron-app-5df76bc88b-8llrz   0/1     Completed           0          9m48s
cron-app-5df76bc88b-8llrz   0/1     Completed           0          9m48s
cron-app-5df76bc88b-qcdfx   0/1     Completed           0          9m18s
cron-app-5df76bc88b-qcdfx   0/1     Completed           0          9m18s
cron-app-5df76bc88b-mrws9   0/1     Completed           0          9m18s
cron-app-5df76bc88b-mrws9   0/1     Completed           0          9m18s
cron-app-5df76bc88b-rgkcz   0/1     Completed           0          9m18s
cron-app-5df76bc88b-rgkcz   0/1     Completed           0          9m18s
cron-app-5df76bc88b-xjl9c   0/1     Completed           0          9m18s
cron-app-5df76bc88b-xjl9c   0/1     Completed           0          9m18s
cron-app-5df76bc88b-hzrg4   0/1     Completed           0          9m3s
cron-app-5df76bc88b-hzrg4   0/1     Completed           0          9m3s
cron-app-5df76bc88b-fqffn   0/1     Completed           0          9m48s
cron-app-5df76bc88b-fqffn   0/1     Completed           0          9m48s
cron-app-5df76bc88b-6ltbp   0/1     Completed           0          9m34s
cron-app-5df76bc88b-6ltbp   0/1     Completed           0          9m34s
cron-app-5df76bc88b-dbkzx   0/1     Completed           0          9m34s
cron-app-5df76bc88b-dbkzx   0/1     Completed           0          9m34s
```
After the ScaledObject completes:

```bash
k get pod -n test
NAME                        READY   STATUS    RESTARTS   AGE
cron-app-5df76bc88b-smfnl   1/1     Running   0          10m
```


## Troubleshooting

To troubleshoot KEDA issues:

```bash
# Check KEDA operator logs
kubectl logs -l app=keda-operator -n keda

# Check metrics server logs
kubectl logs -l app=keda-metrics-apiserver -n keda

# Check ScaledObject status
kubectl describe scaledobject cron-app-scaledobject -n test

# Check HPA status
kubectl get hpa -n test
kubectl describe hpa keda-hpa-cron-app-scaledobject -n test
```

## Contributing

To contribute to the KEDA project, you can submit a pull request via [GitHub](https://github.com/kedacore/keda).

## License

KEDA is distributed under the [Apache 2.0 licance](https://github.com/kedacore/keda/blob/main/LICENSE).