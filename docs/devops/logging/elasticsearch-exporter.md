# Elasticsearch-Exporter

https://github.com/prometheus-community/elasticsearch_exporter

The Elasticsearch Exporter is a tool that may be utilized to check the performance and health of Elasticsearch. This application gathers metrics and information from Elasticsearch and makes them available to Prometheus, a widely used open-source monitoring system. The Elasticsearch Exporter enables you to monitor a range of metrics, including cluster, node, and index-level information. These metrics encompass CPU utilization, memory usage, indexing rate, search rate, and other relevant data.

## Step-by-step guide to configure Elasticsearch Exporter

### Create a system user for Elasticsearch

```bash
sudo useradd elastic_search
```

### Download Elasticsearch Exporter

```bash
sudo wget https://github.com/prometheus-community/elasticsearch_exporter/releases/download/v1.7.0/elasticsearch_exporter-1.7.0.linux-amd64.tar.gz
```

### Extract the tar.gz file

```bash
sudo tar -xvzf elasticsearch_exporter-1.7.0.linux-amd64.tar.gz
```

### Move to the extracted directory

```bash
cd elasticsearch_exporter-1.7.0.linux-amd64/
```

### Copy the exporter binary to /usr/local/bin/

```bash
sudo cp elasticsearch_exporter /usr/local/bin/
```

### Change ownership of the exporter binary

```bash
sudo chown elastic_search:elastic_search /usr/local/bin/elasticsearch_exporter
```

### Create a systemd service file

Copy the /etc/elasticsearch/certs/http_ca.crt file to the /home/elastic_search directory and set the necessary permissions with the chown elastic_search:elasticsearch /home/elastic_search/http_ca.crt command.

```bash
sudo vim /etc/systemd/system/elasticsearch_exporter.service
-----------------------------------------------------------
[Unit]
Description=Prometheus ES_exporter
After=local-fs.target network-online.target network.target
Wants=local-fs.target network-online.target network.target
[Service]
User=elastic_search
Nice=10
ExecStart=/usr/local/bin/elasticsearch_exporter --es.uri=https://elastic:password@localhost:9200 --es.ca /home/elastic_search/http_ca.crt  --es.all --es.indices --es.timeout 20s
ExecStop=/usr/bin/killall elasticsearch_exporter
[Install]
WantedBy=default.target
```
! Note: Update your user and password for elasticsearch

### Start the Elasticsearch Exporter service and enable the service to start on boot

```bash
sudo systemctl start elasticsearch_exporter.service
sudo systemctl enable elasticsearch_exporter.service
sudo systemctl status elasticsearch_exporter.service
```
!Note: Elastic search exporter uses port 9114, therefore expose it within the VPC in the security group.

### Configure Prometheus.yml

To pull data from the elasticsearch-exporter into Prometheus and Grafana, you should update the prometheus.yml file with the following code, replacing the Elasticsearch node IP addresses as needed

```bash
    additionalScrapeConfigs:
    - job_name: 'elasticsearch-exporter'
      static_configs:
        - targets: ['<elasticsearch-node-ip-1>:9114', '<elasticsearch-node-ip-2>:9114', '<elasticsearch-node-ip-3>:9114']
```

### Add Grafana Dashboard for Elasticsearch

Go to Grafana WebUI Click Dashboard --> New --> New Dashboard --> Import --> Add 266 --> load

![image](./images/dash-1.png)

![image](./images/dash-2.png)

![image](./images/dash-3.png)

![image](./images/dash-4.png)

![image](./images/dash-5.png)

![image](./images/dash-6.png)

### Add alert

You can use Alertmanager or Grafana Alert section.

elasticsearch.rules.yml

```bash
groups:
  - name: elasticsearch
    rules:
      - record: elasticsearch_filesystem_data_used_percent
        expr: 100 * (elasticsearch_filesystem_data_size_bytes - elasticsearch_filesystem_data_free_bytes)
          / elasticsearch_filesystem_data_size_bytes
      - record: elasticsearch_filesystem_data_free_percent
        expr: 100 - elasticsearch_filesystem_data_used_percent
      - alert: ElasticsearchTooFewNodesRunning
        expr: elasticsearch_cluster_health_number_of_nodes < 3
        for: 5m
        labels:
          severity: critical
        annotations:
          description: There are only {{$value}} < 3 Elasticsearch nodes running
          summary: Elasticsearch running on less than 3 nodes
      - alert: ElasticsearchHeapTooHigh
        expr: elasticsearch_jvm_memory_used_bytes{area="heap"} / elasticsearch_jvm_memory_max_bytes{area="heap"}
          > 0.9
        for: 15m
        labels:
          severity: critical
        annotations:
          description: The heap usage is over 90% for 15m
          summary: Elasticsearch node {{$labels.node}} heap usage is high
```

elasticsearch.rules

```bash
# calculate filesystem used and free percent
elasticsearch_filesystem_data_used_percent = 100 * (elasticsearch_filesystem_data_size_bytes - elasticsearch_filesystem_data_free_bytes) / elasticsearch_filesystem_data_size_bytes
elasticsearch_filesystem_data_free_percent = 100 - elasticsearch_filesystem_data_used_percent

# alert if too few nodes are running
ALERT ElasticsearchTooFewNodesRunning
  IF elasticsearch_cluster_health_number_of_nodes < 3
  FOR 5m
  LABELS {severity="critical"}
  ANNOTATIONS {description="There are only {{$value}} < 3 Elasticsearch nodes running", summary="Elasticsearch running on less than 3 nodes"}

# alert if heap usage is over 90%
ALERT ElasticsearchHeapTooHigh
  IF elasticsearch_jvm_memory_used_bytes{area="heap"} / elasticsearch_jvm_memory_max_bytes{area="heap"} > 0.9
  FOR 15m
  LABELS {severity="critical"}
  ANNOTATIONS {description="The heap usage is over 90% for 15m", summary="Elasticsearch node {{$labels.node}} heap usage is high"}
```

You can add slack,email or another connector for alert mechanism.