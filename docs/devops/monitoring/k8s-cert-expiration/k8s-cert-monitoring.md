
# 🔐 Monitoring TLS Certificate Expiration in Kubernetes with Alerting

This document explains how to monitor TLS certificate expiration dates in a Kubernetes cluster and generate alerts when they approach critical thresholds.

## 🎯 Objective

- Monitor the expiration dates of TLS certificates used within Kubernetes components.
- Automatically generate alerts when certificates are about to expire or if any read errors occur.
- Ensure continuous and secure cluster operation by proactively addressing certificate issues.

## 🧰 Components Used

- [`x509-certificate-exporter`](https://github.com/enix/x509-certificate-exporter) (deployed via Helm)
- Prometheus + Alertmanager (from kube-prometheus-stack)
- ArgoCD (with ApplicationSet for GitOps-style deployment)
- Grafana (for visualizing certificate metrics)

---

## 🚀 Deployment Steps

### 1️⃣ Deploy `x509-certificate-exporter` with ArgoCD (Helm)

The following `ApplicationSet` definition deploys the `x509-certificate-exporter` Helm chart to the cluster:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: x509-certificate-exporter
  namespace: argocd
spec:
  generators:
    - list:
        elements:
          - cluster: dev
  template:
    metadata:
      name: '{{cluster}}-x509-certificate-exporter'
    spec:
      syncPolicy:
        automated:
          selfHeal: true
        syncOptions:
          - CreateNamespace=true
      destination:
        namespace: rke2-cert-monitoring
        name: '{{cluster}}'
      project: default
      source:
        repoURL: "https://charts.enix.io"
        targetRevision: 3.18.1 # if need change me
        chart: x509-certificate-exporter
        helm:
          values: |
            hostPathsExporter:
              podAnnotations:
                prometheus.io/port: "9793"
                prometheus.io/scrape: "true"
              daemonSets:
                cp:
                  nodeSelector:
                    node-role.kubernetes.io/control-plane: "true"
                    beta.kubernetes.io/os: "linux"
                  tolerations:
                    - effect: "NoExecute"
                      key: "CriticalAddonsOnly"
                      operator: "Exists"
                  watchFiles:
                    - /var/lib/rancher/rke2/server/tls/client-admin.crt
                    - /var/lib/rancher/rke2/server/tls/client-kube-apiserver.crt
                    - /var/lib/rancher/rke2/server/tls/server-ca.crt
                    - /var/lib/rancher/rke2/server/tls/serving-kube-apiserver.crt
                    - /var/lib/rancher/rke2/server/tls/client-ca.crt
                etcd:
                  nodeSelector:
                    node-role.kubernetes.io/etcd: "true"
                    beta.kubernetes.io/os: "linux"
                  tolerations:
                    - effect: "NoExecute"
                      key: "CriticalAddonsOnly"
                      operator: "Exists"
                  watchFiles:
                    - /var/lib/rancher/rke2/server/tls/etcd/server-client.crt
                    - /var/lib/rancher/rke2/server/tls/etcd/server-ca.crt
                worker:
                  affinity:
                    nodeAffinity:
                      requiredDuringSchedulingIgnoredDuringExecution:
                        nodeSelectorTerms:
                          - matchExpressions:
                              - key: "node-role.kubernetes.io/worker"
                                operator: In
                                values:
                                  - "true"
                          - matchExpressions:
                              - key: "node-role.kubernetes.io/worker"
                                operator: In
                                values:
                                  - "worker"
                  watchFiles:
                    - /var/lib/rancher/rke2/agent/client-ca.crt
                    - /var/lib/rancher/rke2/agent/client-kubelet.crt
                    - /var/lib/rancher/rke2/agent/client-kube-proxy.crt
                    - /var/lib/rancher/rke2/agent/client-rke2-controller.crt
                    - /var/lib/rancher/rke2/agent/server-ca.crt
                    - /var/lib/rancher/rke2/agent/serving-kubelet.crt
            prometheusPodMonitor:
              create: true
            secretsExporter:
              enabled: false
```

---

### 2️⃣ Prometheus Alert Rules

Add the following alert rules to the Prometheus alerting configuration to monitor the exporter and certificate expiration:

```yaml
groups:
  - name: x509-certificate-exporter.rules
    rules:
      - alert: X509ExporterReadErrors
        annotations:
          summary: Increasing read errors for x509-certificate-exporter
          description: >
            Over the last 15 minutes, this x509-certificate-exporter instance
            has experienced errors reading certificate files or querying the Kubernetes API.
            This could be caused by a misconfiguration if triggered when the exporter starts.
        expr: delta(x509_read_errors[15m]) > 0
        for: 5m
        labels:
          severity: warning

      - alert: CertificateRenewal
        annotations:
          summary: Certificate should be renewed
          description: >
            Certificate for "{{ $labels.subject_CN }}" should be renewed
            {{if $labels.secret_name }}in Kubernetes secret "{{ $labels.secret_namespace }}/{{ $labels.secret_name }}"
            {{else}}at location "{{ $labels.filepath }}"{{end}}
        expr: ((x509_cert_not_after - time()) / 86400) < 28
        for: 15m
        labels:
          severity: warning

      - alert: CertificateExpiration
        annotations:
          summary: Certificate is about to expire
          description: >
            Certificate for "{{ $labels.subject_CN }}" is about to expire
            {{if $labels.secret_name }}in Kubernetes secret "{{ $labels.secret_namespace }}/{{ $labels.secret_name }}"
            {{else}}at location "{{ $labels.filepath }}"{{end}}
        expr: ((x509_cert_not_after - time()) / 86400) < 14
        for: 15m
        labels:
          severity: critical
```

---

## 📊 Grafana Dashboard Integration

To visualize certificate metrics, import the official Grafana dashboard created for the `x509-certificate-exporter`.

### 🔧 Importing via Grafana.com Dashboard ID

1. Log in to your Grafana instance.
2. Go to the left menu and select **+ Create > Import**.
3. In the **Import via grafana.com** field, enter the following dashboard ID:

   ```
   13922
   ```

4. Click **Load**.
5. Select your Prometheus data source.
6. Click **Import** to complete the setup.

> This dashboard provides a visual representation of certificate expiration dates, issuers, subjects, and alert states.

---

## ✅ Summary

By completing the above steps, you will have:

- Deployed a certificate monitoring exporter to your Kubernetes cluster
- Configured Prometheus alert rules for expiring certificates
- Visualized certificate metrics in Grafana
- Ensured proactive alerting and observability for certificate expiration

---

## 📦 References

- [Enix x509-certificate-exporter](https://github.com/enix/x509-certificate-exporter)
- [Helm Chart Repository](https://charts.enix.io)
- [Grafana Dashboard 13922](https://grafana.com/grafana/dashboards/13922)
