```
#!/bin/bash

KAFKA_HOST_1="172.31.18.173"    # Change here with ip of kafka1 node
KAFKA_HOST_2="172.31.23.248"    # Change here with ip of kafka2 node
KAFKA_HOST_3="172.31.25.184"    # Change here with ip of kafka3 node

EXTERNAL_IP=3.76.209.91         # Change here with ip of humio node
INTERNAL_IP=3.76.209.91         # Change here with ip of humio node

echo "$KAFKA_HOST_1 kafka1" >> /etc/hosts
echo "$KAFKA_HOST_2 kafka2" >> /etc/hosts
echo "$KAFKA_HOST_3 kafka3" >> /etc/hosts

HUMIO_DOWNLOAD_LINK="https://repo.humio.com/repository/maven-releases/com/humio/server/1.131.1/server-1.131.1.tar.gz" # If you'll use here change here with path of humio
HUMIO_PACKAGE_PATH=""   # If you'll use here change here with path of humio package

#### Apt package update ####
apt-get update -y && apt-get upgrade -y
sleep 10

#### Java Install ####
apt-get install openjdk-21-jdk -y

#### Java version control ####
java --version
sleep 10


#### Hunio user access ####
adduser humio --shell=/bin/false --no-create-home --system --group

#### Kafka folders create and access ####
mkdir -p /opt/humio /etc/humio/filebeat /data/log/humio /data/humio/data
chown humio:humio /opt/humio /etc/humio/filebeat
chown humio:humio /data/log/humio /data/humio/data
sleep 2

#### Humio tar.gz package download or move ####
cd /opt/humio/
sleep 2

if [ -n "$HUMIO_DOWNLOAD_LINK" ]; then

    cd /opt/humio && wget $HUMIO_DOWNLOAD_LINK
    tar zxf "$(basename $HUMIO_DOWNLOAD_LINK)"

    # Get list of output files
    EXTRACTED_FILES=$(ls)

    # Print the resulting files to the screen
    echo "Get list of output files:"
    echo "$EXTRACTED_FILES"

    # Assign the name of the first file to a variable
    HUMIO_PACKAGE_FILE=$(echo "$EXTRACTED_FILES" | head -n 1)
    

else 

    cd /opt/humio && cp -R $HUMIO_PACKAGE_PATH .
    tar zxf $HUMIO_PACKAGE_PATH

    # Get list of output files
    EXTRACTED_FILES=$(ls)

    # Print the resulting files to the screen
    echo "Get list of output files:"
    echo "$EXTRACTED_FILES"

    # Assign the name of the first file to a variable
    HUMIO_PACKAGE_FILE=$(echo "$EXTRACTED_FILES" | head -n 1)

fi
sleep 2


#### Humio server.conf create ####
cd /etc/humio/
cat <<EOF >> server.conf
AUTHENTICATION_METHOD=single-user
SINGLE_USER_USERNAME=admin
SINGLE_USER_PASSWORD=admin
DIRECTORY=/data/humio/data
HUMIO_AUDITLOG_DIR=/data/log/humio
HUMIO_DEBUGLOG_DIR=/data/log/humio
JVM_LOG_DIR=/data/log/humio
HUMIO_PORT=8080
ELASTIC_PORT=9200

KAFKA_SERVERS=kafka1:9092,kafka2:9092,kafka3:9092
EXTERNAL_URL=http://$EXTERNAL_IP:8080
PUBLIC_URL=http://$INTERNAL_IP:8080
EOF
sleep 2

#### Humio system service create ####
cd /etc/systemd/system/
cat <<EOF >> humio.service
[Unit]
Description=LogScale service
After=network.service

[Service]
Type=notify
Restart=on-abnormal
User=humio
Group=humio
LimitNOFILE=250000:250000
EnvironmentFile=/etc/humio/server.conf
WorkingDirectory=/data/humio
ExecStart=/opt/humio/humio/bin/humio-server-start.sh
TimeoutSec=900

[Install]
WantedBy=default.target
EOF
sleep 2

#### User access ####
chown -R humio:humio /opt/humio /etc/humio

sleep 2

chown -R humio:humio /data/log/humio /data/humio/data

```

