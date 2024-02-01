# KEDA (Kubernetes Event-driven Autoscaling) :fire:

**What is KEDA ?**

KEDA is a lightweight, open-source Kubernetes event-driven autoscaler used by DevOps, SRE, and Ops teams to horizontally scale pods based on external events or triggers. KEDA helps to extend the capability of native Kubernetes autoscaling solutions, which rely on standard resource metrics such as CPU or memory. You can deploy KEDA into a Kubernetes cluster and manage the scaling of pods using custom resource definitions (CRDs).
Built on top of Kubernetes HPA, KEDA scales pods based on information from event sources such as AWS SQS, Kafka, RabbitMQ, etc. These event sources are monitored using scalers, which activate or deactivate deployments based on the rules set for them. KEDA scalers can also feed custom metrics for a specific event source, helping DevOps teams observe metrics relevant to them




:warning: KEDA scales down the number of pods to zero in case there are no events to process. This is harder to do using the standard HPA, and it helps ensure effective resource utilization and cost optimization, ultimately bringing down the cloud bills..





!!! quote

    KEDA supports a lot of built-in scalers and external scalers. External scalers include Redis, MYSQL,Prometheus,Rabbit MQ etc. Using external events as triggers aids efficient autoscaling, especially for message-driven microservices like payment gateways or order systems. Since KEDA can be extended by developing integrations with any data source, it can easily fit into any DevOps toolchain. 



### KEDA Components

**Event Sources**

These are the external event/trigger sources by which KEDA changes the number of pods. Prometheus, RabbitMQ, and Apache Pulsar are some examples of event sources.

**Metric Adapter**

Metrics adapter takes metrics from scalers and translates or adapts them into a form that HPA/controller component can understand.

**Controller**

The controller/operator acts upon the metrics provided by the adapter and brings about the desired deployment state specified in the ScaledObject (refer below).


**ScaledObject and ScaledJob:**

ScaledObject represents the mapping between event sources and objects, and specifies the scaling rules for a Deployment, StatefulSet, Jobs or any Custom Resource in a K8s cluster. Similarly, ScaledJob is used to specify scaling rules for Kubernetes Jobs.

Below is an example of a ScaledObject which configures KEDA autoscaling based on Prometheus metrics. Here, the deployment object ‘keda-test’ is scaled based on the trigger threshold (50) from Prometheus metrics. KEDA will scale the number of replicas between a minimum of 1 and a maximum of 10, and scale down to 0 replicas if the metric value drops below the threshold.


```bash
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: prometheus-scaledobject
  namespace: demo3
spec:
  scaleTargetRef:
    apiVersion: argoproj.io/v1alpha1
    kind: Rollout
    name: keda-test-demo3
  triggers:
    - type: prometheus
      metadata:
      serverAddress:  http://<prometheus-host>:9090
      metricName: http_request_total
      query: envoy_cluster_upstream_rq{appId="300", cluster_name="300-0", container="envoy", namespace="test", response_code="200" }
      threshold: "50"
  idleReplicaCount: 0                       
  minReplicaCount: 1
  maxReplicaCount: 10
```

Deploying KEDA on any Kubernetes cluster is easy, as it doesn’t need overwriting or duplication of existing functionalities. Once deployed and the components are ready, the event-based scaling starts with the external event source. The scaler will continuously monitor for events based on the source set in ScaledObject and pass the metrics to the metrics adapter in case of any trigger events. The metrics adapter then adapts the metrics and provides them to the controller component, which then scales up or down the deployment based on the scaling rules set in ScaledObject.

Note that KEDA activates or deactivates a deployment by scaling the number of replicas to zero or one. It then triggers HPA to scale the number of workloads from one to n based on the cluster resources

#### Keda Deployment  :fire:

KEDA can be deployed in a Kubernetes cluster through Helm charts, operator hub, or YAML declarations

**Helm Chart**

- Add Helm repo

```bash
helm repo add kedacore https://kedacore.github.io/charts
```

- Update Helm repo

```bash
helm repo update
```

- Install keda Helm chart

```bash
helm install keda kedacore/keda --namespace keda --create-namespace
```

**Deploying with operator Hub**

On Operator Hub Marketplace locate and install KEDA operator to namespace keda
Create KedaController resource named keda in namespace keda

NOTE: Further information on Operator Hub installation method can be found in the following repository.

https://github.com/kedacore/keda-olm-operator

**Deploying using the deployment YAML files**

Run the following command (if needed, replace the version, in this case 2.13.0, with the one you are using):

```bash
# Including admission webhooks
kubectl apply --server-side -f https://github.com/kedacore/keda/releases/download/v2.13.0/keda-2.13.0.yaml
# Without admission webhooks
kubectl apply --server-side -f https://github.com/kedacore/keda/releases/download/v2.13.0/keda-2.13.0-core.yaml
```
