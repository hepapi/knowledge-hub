# Falcon LogScale Agent(Log Collector) Setup :octicons-log-24:

First of all, you need to create a new repo from `Repositories and View`.After creating the repo, you will go into the repo.You need to enter `Settings` from the upper menus.You need to enter `Ingest Tokens` under the `Ingest` category in the left menu.Then you will create a new token with `Add New Token`.

>Remember that this token will be useful later.


### Download Collector

You should follow the steps below to reach the download page, select the package suitable for your system and download it.

Main Page ➡️ Fleet Management ➡️ LogScale Collector Download

!!! warning annanote  "Important Installations Notes"

    You may get an error while downloading.This is because the download URL is wrong or incorrect.

    For example: ``http://10.40.140.2:8080/None/api/v1/log-collector/download/humio-log-collector_1.4.1_linux_amd64.deb``. 

    The `NONE` here may cause you to download an incorrect file.Delete it !.After downloading the file, check its size with the `ls -alh` command.  


 Follow these steps after downloading the file.

```bash

dpkg -i humio-log-collector_x.x.x_linux_amd64.deb

```

By default, the humio-log-collector process will run as the humio-log-collector user, which is installed by the package and won't have access to logs in ``/var/log``.

This can be granted by adding the user to the adm group.
```bash
sudo usermod -a -G adm humio-log-collector
```

## You can run the LogScale Collector as a standalone process and ignore the service file etc.


```yaml
/etc/humio-log-collector/config.yaml
```


Open the source field and enter the token and ip address you created in the relevant fields.
> Remember the source option specifies where you want to get the logs from

```yaml
sources:
  var_log:
    type: file
    include: /var/log/*
    exclude: /var/log/*.gz
    sink: humio
sinks:
  humio:
    type: humio
    token: <Ingest Token> # 210f4309-0d71-4d3d-b4e3-d503d46b93b9
    url: <host ip-address of the humio> # http://52.91.72.78:8080/
```

Now you need to start and enable the services to apply the changes

```bash
sudo systemctl start humio-log-collector.service
```
```bash
sudo systemctl enable humio-log-collector.service
```

Check the status of the service

```bash
sudo systemctl status humio-log-collector.service
```

!!! success
     If Active:{++active++} (running), you can go to the repository from the interface and check your logs

!!! warning annanote  "Important Installations Notes"

    If you get your logs as `Docker Container`, you can get your logs without installing an agent by using the following command with `Driver:Splunk`

```yaml
export YOUR_LOGSCALE_URL="<10.40.140.2:8080>"
export INGEST_TOKEN="<210f4309-0d71-4d3d-b4e3-d503d46b93b9>"
cat << EOF > docker-compose.yaml
version: '3'
services:
  nginx-log-generator:
    image: kscarlett/nginx-log-generator
    environment:
      - RATE=10
      # other environment variables
    logging:
      driver: "splunk"
      options:
        splunk-url: $YOUR_LOGSCALE_URL
        splunk-token: $INGEST_TOKEN
EOF
```

## :fire: To generate logs with `docker` for testing, you can generate test logs using the following `docker-compose` commands.

```yaml
export YOUR_LOGSCALE_URL=""
export INGEST_TOKEN=""
cat << EOF > docker-compose.yaml
version: '3'
services:
  nginx-log-generator:
    image: kscarlett/nginx-log-generator
    environment:
      - RATE=10
      # other environment variables
    logging:
      driver: "splunk"
      options:
        splunk-url: $YOUR_LOGSCALE_URL
        splunk-token: $INGEST_TOKEN

  chentex-random-logger:
    image: chentex/random-logger:latest
    command: ["100", "300"] 
    logging:
      driver: "splunk"
      options:
        splunk-url: $YOUR_LOGSCALE_URL
        splunk-token: $INGEST_TOKEN

  flog-format-apache-common:
    image: mingrammer/flog
    command: ["--loop", "--format",  "apache_common", "--number", "1", "--delay", "250ms", "--type", "stdout"] 
    logging:
      driver: "splunk"
      options:
        splunk-url: $YOUR_LOGSCALE_URL
        splunk-token: $INGEST_TOKEN

  flog-format-rfc5424:
    image: mingrammer/flog
    command: ["--loop", "--format",  "rfc5424", "--number", "1", "--delay", "250ms", "--type", "stdout"] 
    logging:
      driver: "splunk"
      options:
        splunk-url: $YOUR_LOGSCALE_URL
        splunk-token: $INGEST_TOKEN

  flog-format-json:
    image: mingrammer/flog
    command: ["--loop", "--format",  "json", "--number", "1", "--delay", "250ms", "--type", "stdout"]
    logging:
      driver: "splunk"
      options:
        splunk-url: $YOUR_LOGSCALE_URL
        splunk-token: $INGEST_TOKEN
EOF
docker-compose up -d
docker-compose logs
```