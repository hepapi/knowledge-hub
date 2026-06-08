# x509-cert-exporter — Elasticsearch Certificate Monitoring

This document covers the installation of **x509-certificate-exporter**, Prometheus `additional_scrape_configs` configuration, and alert rules for monitoring all certificates under `/etc/elasticsearch/certs` in a self-managed Elasticsearch cluster.

---

## References

- x509-certificate-exporter GitHub: <https://github.com/enix/x509-certificate-exporter>

---

## Important Notes

- This setup monitors **all** certificate files under `/etc/elasticsearch/certs`.
- x509-exporter cannot read `.p12` files directly; they must be converted to `.pem` first.
- Installation must be performed on each node individually.
- The service runs as the `elasticsearch` user.
- The exporter listens on port `:9793` by default.

---

## Required Information Per Node

| Field | Value |
|-------|-------|
| VM private IP | `<vm-private-ip>` |

Paths used in this guide:

- Certificate directory: `/etc/elasticsearch/certs`
- Exporter PEM directory: `/etc/elasticsearch/x509-exporter`

---

## Installation Steps

### 1. Download and Install the x509-certificate-exporter Binary

```bash
curl -fSLk -o x509-cert-exporter.tar.gz \
  https://github.com/enix/x509-certificate-exporter/releases/download/v3.21.0/x509-certificate-exporter-linux-amd64.tar.gz

tar -xzf x509-cert-exporter.tar.gz
sudo mv x509-certificate-exporter /usr/local/bin/
sudo chmod +x /usr/local/bin/x509-certificate-exporter
```

Verify the installation:

```bash
x509-certificate-exporter --version
```

---

### 2. Create the Exporter PEM Directory

```bash
mkdir -p /etc/elasticsearch/x509-exporter
```

---

### 3. Convert `.p12` Files to PEM Format

x509-exporter cannot read `.p12` files. All `.p12` files under `/etc/elasticsearch/certs` must be converted to `.pem`.

First, retrieve the `http.p12` password:

```bash
PASS=$(/usr/share/elasticsearch/bin/elasticsearch-keystore show \
  xpack.security.http.ssl.keystore.secure_password | tr -d '\n')
```

Convert `http.p12`:

```bash
openssl pkcs12 \
  -in /etc/elasticsearch/certs/http.p12 \
  -out /etc/elasticsearch/x509-exporter/http.pem \
  -nodes \
  -passin pass:"$PASS" \
  || echo "http.p12 conversion failed"
```

`http_ca.crt` is already in PEM format; copy it directly:

```bash
cp /etc/elasticsearch/certs/http_ca.crt \
   /etc/elasticsearch/x509-exporter/http_ca.pem
```

Verify the output files:

```bash
ls -l /etc/elasticsearch/x509-exporter/
```

---

### 4. Set Ownership and Permissions

```bash
chown -R elasticsearch:elasticsearch /etc/elasticsearch/x509-exporter
chmod 640 /etc/elasticsearch/x509-exporter/*.pem
```

---

### 5. Create the Systemd Service File

```bash
sudo vi /etc/systemd/system/x509-exporter.service
```

Paste the following content:

```ini
[Unit]
Description=X509 Certificate Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=elasticsearch
Group=elasticsearch
Type=simple

ExecStart=/usr/local/bin/x509-certificate-exporter \
  -d /etc/elasticsearch/x509-exporter

Restart=on-failure
RestartSec=5s

NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true

[Install]
WantedBy=multi-user.target
```

---

### 6. Enable and Start the Service

```bash
sudo systemctl daemon-reload
sudo systemctl enable x509-exporter
sudo systemctl start x509-exporter
```

---

### 7. Verify the Service

```bash
sudo systemctl status x509-exporter
```

Follow live logs:

```bash
journalctl -u x509-exporter -f
```

Test Prometheus metrics (default port `9793`):

```bash
curl -s http://localhost:9793/metrics | grep x509_cert_not_after
```

---

## Prometheus Configuration

### additional_scrape_configs

Add the following job to your `prometheus.yml` or a dedicated `additional_scrape_configs` file. Each Elasticsearch node is listed as a separate target:

```yaml
additional_scrape_configs:
  - job_name: 'x509-elasticsearch'
    static_configs:
      - targets:
          - '<node-1-private-ip>:9793'
          - '<node-2-private-ip>:9793'
          - '<node-3-private-ip>:9793'
```

> Replace `<node-1-private-ip>`, `<node-2-private-ip>`, and `<node-3-private-ip>` with the private IP of each node.

Reload Prometheus to apply the configuration change:

---

### Alert Rules

Add the following rules to a Prometheus rule file (e.g. `/etc/prometheus/rules/elasticsearch-certs.yml`):

```yaml
groups:
  - name: elasticsearch_certificates
    rules:
      - alert: ElasticCertificateExpiringWarning
        expr: (x509_cert_not_after - time()) < 30 * 24 * 3600
        for: 3m
        labels:
          alertname: elasticsearch
        annotations:
          summary: "ElasticSearch Certificate will expire in less than 30 days"
          description: "Certificate {{ $labels.common_name }} expires in less than 30 days."

      - alert: ElasticCertificateExpiringCritical
        expr: (x509_cert_not_after - time()) < 14 * 24 * 3600
        for: 3m
        labels:
          alertname: elasticsearch
        annotations:
          summary: "ElasticSearch Certificate will expire in less than 14 days"
          description: "Certificate {{ $labels.common_name }} expires in less than 14 days."
```
