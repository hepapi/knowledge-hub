# OpenTelemetry Instrumentation: Manual vs. Automatic

## What Is OpenTelemetry Instrumentation?

OpenTelemetry provides a set of APIs, libraries, and agents designed to capture, process, and export telemetry data from software applications. Instrumentation refers to ensuring an application’s code generates traces, metrics, and logs that make it observable.

### Manual instrumentation
Involves adding specific code snippets to your application to capture and send telemetry data. It can capture custom metrics specific to your application, like items in a shopping cart or the time it takes to perform a specific database query. Manual instrumentation provides a high level of control and flexibility but takes time to implement.

Advantages
- Full Control:
You have complete authority over what gets measured, when, and in how much detail. This allows you to focus exclusively on critical business transactions and functions, maximizing the signal-to-noise ratio.

- Rich Business Context:
You can enrich traces with valuable, domain-specific attributes that are crucial for debugging and performance analysis. For example, you can add tags like customer_id, cart_value, or subscription_tier='premium' to a trace. This helps answer complex questions like, "Why do requests slow down only for premium users with a cart value over $500?"

- Reliability & Independence:
The instrumentation code is a part of your application's source code. It is not dependent on the internal implementation details of third-party frameworks, making it more robust against framework updates that might otherwise break instrumentation.

Disadvantages
- Time-Consuming & High-Effort:
Writing, adding, and maintaining instrumentation code across a large codebase requires significant developer time and effort. As the application evolves or is refactored, this code must also be updated.

- Requires Expertise:
Developers must be knowledgeable in both the application's architecture and the specific API of the observability SDK being used.


### Automatic instrumentation
Involves using pre-built libraries or agents that automatically capture and send telemetry data without requiring you to modify your application’s code. It is typically used to capture standard metrics like CPU usage, memory usage, request latency, and error rates. This is less flexible than manual instrumentation but much simpler and quicker to implement.

Advantages
- Fast & Easy Setup:
Getting started is often as simple as including an agent in the application's startup command. You can begin collecting a wide range of telemetry data within minutes.


- No Code Changes Required:
The application's source code remains untouched. This is a major benefit, especially for legacy systems, applications with low test coverage, or when you don't have direct access to the code.

- Standardization:
It enforces a consistent baseline of observability across all services and teams in an organization, ensuring that everyone gets a standard set of telemetry.

Disadvantages
The Version Compatibility Nightmare:

- Framework Version: The agent must explicitly support the exact version of the framework (e.g., Spring Boot 3.1.x) your project uses. If not, it may fail to identify the framework's internal classes and methods.

- Library Version: The versions of libraries like database drivers or HTTP clients must be recognized by the agent.

- Language Runtime Version: The agent must be compatible with the Java, Python, or Node.js version you are running.

### Demonstration

#### OpenTelemtry Operator

First, install the OpenTelemetry Operator into your cluster.

* opentelemetry-operator-values.yaml

```yaml
manager:
    collectorImage:
        repository: ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-k8s
admissionWebhooks:
    certManager:
        enabled: false 
    autoGenerateCert:
        enabled: true
```


```bash
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo update
helm upgrade --install opentelemetry-operator open-telemetry/opentelemetry-operator -n monitoring -f opentelemetry-operator-values.yaml
```

#### OpenTelemetry Collector

* opentelemetry-collector-values.yaml

```yaml
config:
  exporters:
    otlphttp/tempo:
      endpoint: http://tempo-gateway.monitoring:80 ## add tempo service address
      tls:
        insecure: true
    prometheusremotewrite:
      endpoint: http://prometheus-kube-prometheus-prometheus.monitoring:9090/api/v1/write ## add prometheus service address
      target_info:
        enabled: true
  extensions:
    health_check:
      endpoint: ${env:MY_POD_IP}:13133
  receivers:
    otlp:
      protocols:
        grpc:
          endpoint: 0.0.0.0:4317
        http:
          endpoint: 0.0.0.0:4318
  service:
    pipelines:
      metrics:
        exporters:
        - debug
        - prometheusremotewrite
        processors:
        - memory_limiter
        receivers:
        - otlp
      traces:
        exporters:
        - otlphttp/tempo
        processors:
        - memory_limiter
        - batch
        receivers:
        - otlp
image:
  repository: docker.io/otel/opentelemetry-collector-contrib
mode: daemonset
ports:
  otlp:
    appProtocol: grpc
    containerPort: 4317
    enabled: true
    hostPort: 4317
    protocol: TCP
    servicePort: 4317
  otlp-http:
    containerPort: 4318
    enabled: true
    hostPort: 4318
    protocol: TCP
    servicePort: 4318
replicaCount: 1
```


```bash
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo update
helm upgrade --install opentelemetry-collector open-telemetry/opentelemetry-collector -f opentelemetry-collector-values.yaml -n monitoring
```

#### OpenTelemetry Instrumentation

```yaml
kubectl apply -f - <<EOF
apiVersion: opentelemetry.io/v1alpha1
kind: Instrumentation
metadata:
  name: java-instrumentation
  namespace: monitoring
spec:
  java:
    image: "otel/opentelemetry-javaagent:2.19.0"
  exporter:
    endpoint: http://opentelemetry-collector.monitoring:4318
  propagators:
    - tracecontext
    - baggage
  sampler:
    type: parentbased_traceidratio
    argument: "1"
```

** Excluding auto-instrumentation

By default, the Java auto-instrumentation ships with many instrumentation libraries. This makes instrumentation easy, but could result in too much or unwanted data. If there are any libraries you do not want to use you can set the OTEL_INSTRUMENTATION_[NAME]_ENABLED=false where [NAME] is the name of the library. If you know exactly which libraries you want to use, you can disable the default libraries by setting OTEL_INSTRUMENTATION_COMMON_DEFAULT_ENABLED=false and then use OTEL_INSTRUMENTATION_[NAME]_ENABLED=true where [NAME] is the name of the library. For more details, see Suppressing specific instrumentation.

[Environment-list-link](https://opentelemetry.io/docs/zero-code/java/agent/getting-started/)

```yaml
apiVersion: opentelemetry.io/v1alpha1
kind: Instrumentation
metadata:
  name: demo-instrumentation
spec:
  exporter:
    endpoint: http://demo-collector:4318
  propagators:
    - tracecontext
    - baggage
  sampler:
    type: parentbased_traceidratio
    argument: '1'
  java:
    env:
      - name: OTEL_INSTRUMENTATION_KAFKA_ENABLED
        value: false
      - name: OTEL_INSTRUMENTATION_REDISCALA_ENABLED
        value: false
```

#### Application Annotation

The final step is to opt in your services to automatic instrumentation. This is done by updating your service’s spec.template.metadata.annotations to include a language-specific annotation:

* .NET: instrumentation.opentelemetry.io/inject-dotnet: "true"
* Go: instrumentation.opentelemetry.io/inject-go: "true"
* Java: instrumentation.opentelemetry.io/inject-java: "true"
* Node.js: instrumentation.opentelemetry.io/inject-nodejs: "true"
* Python: instrumentation.opentelemetry.io/inject-python: "true"

The possible values for the annotation can be
"true" - to inject Instrumentation resource with default name from the current namespace.
"my-instrumentation" - to inject Instrumentation CR instance with name "my-instrumentation" in the current namespace.
"my-other-namespace/my-instrumentation" - to inject Instrumentation CR instance with name "my-instrumentation" from another namespace "my-other-namespace".
"false" - do not inject

Note: For our example, add monitoring/java-instrumentation as the annotation.

[doc-link](https://opentelemetry.io/docs/platforms/kubernetes/operator/automatic/)