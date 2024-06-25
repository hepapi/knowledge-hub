#!/bin/bash

KAFKA_HOST_1="172.31.18.173"     # Change here with ip of kafka1 node
KAFKA_HOST_2="172.31.23.248"     # Change here with ip of kafka2 node
KAFKA_HOST_3="172.31.25.184"     # Change here with ip of kafka3 node

KAFKA_NODE_NUMBER=1             # Change here with id of kafka1 node

KAFKA_PACKAGE_PATH=""           # If you'll use here change here with path of kafka package
KAFKA_DOWNLOAD_LINK="https://downloads.apache.org/kafka/3.7.0/kafka_2.13-3.7.0.tgz"  # If you'll use here change here with path of kafka package

#### Apt package update ####
apt-get update -y && apt-get upgrade -y
sleep 10


#### Java Install ####
apt-get install openjdk-21-jdk -y
java --version
sleep 10

#### Add IP Addresses to hosts file
echo "$KAFKA_HOST_1 kafka1" >> /etc/hosts
echo "$KAFKA_HOST_2 kafka2" >> /etc/hosts
echo "$KAFKA_HOST_3 kafka3" >> /etc/hosts


#### Kafka user access ####
adduser kafka --shell=/bin/false --no-create-home --system --group
sleep 2

#### Kafka tar.gz package download or move ####
if [ -n "$KAFKA_DOWNLOAD_LINK" ]; then

    cd /opt && wget $KAFKA_DOWNLOAD_LINK
    tar zxf "$(basename $KAFKA_DOWNLOAD_LINK)"

    # Get list of output files
    EXTRACTED_FILES=$(ls)

    # Print the resulting files to the screen
    echo "Get list of output files:"
    echo "$EXTRACTED_FILES"

    # Assign the name of the first file to a variable
    KAFKA_PACKAGE_FILE=$(echo "$EXTRACTED_FILES" | head -n 1)
    ln -s /opt/$KAFKA_PACKAGE_FILE /opt/kafka

else 

    cd /opt && cp -R $KAFKA_PACKAGE_PATH .
    tar zxf $KAFKA_PACKAGE_PATH

    # Get list of output files
    EXTRACTED_FILES=$(ls)

    # Print the resulting files to the screen
    echo "Get list of output files:"
    echo "$EXTRACTED_FILES"

    # Assign the name of the first file to a variable
    KAFKA_PACKAGE_FILE=$(echo "$EXTRACTED_FILES" | head -n 1)
    ln -s /opt/$KAFKA_PACKAGE_FILE /opt/kafka

fi
sleep 2


#### Kafka folders create and access ####
mkdir -p /data/log/kafka
mkdir -p /data/log/zookeeper
mkdir -p /data/kafka/kafka
mkdir -p /data/kafka/zookeeper
chown -R kafka:kafka /data/log/kafka /data/log/zookeeper /data/kafka/zookeeper /data/kafka/kafka
sleep 2


#### Link for kafka ####
ln -s "/opt/$KAFKA_PACKAGE_FILE" /opt/kafka
sleep 2


#### Server properties config ####
cd /opt/kafka/config
FILE="server.properties"

# New variables
BROKER_ID="broker.id=$KAFKA_NODE_NUMBER"
NEW_LOG_DIRS="log.dirs=/data/kafka/kafka"
sleep 2


# Update specific values 
sed -i "s/^broker.id=.*/$BROKER_ID/" "$FILE"
sed -i "s|^log.dirs=.*|$NEW_LOG_DIRS|" "$FILE"
echo "delete.topic.enable = true" >> "$FILE"
sleep 2


#### Kafka user chown ####
chown -R kafka:kafka /opt/kafka
sleep 2


#### Zookeper Config ####
cd /opt/kafka/config
rm -rf zookeeper.properties
cat <<EOF >> zookeeper.properties
dataDir=/data/kafka/zookeeper
clientPort=2181
maxClientCnxns=0
admin.enableServer=false
server.1=kafka1:2888:3888
server.2=kafka2:2888:3888
server.3=kafka3:2888:3888
4lw.commands.whitelist=*
tickTime=2000
initLimit=5
syncLimit=2
EOF
sleep 2


#### Zookeper chown ####
echo $KAFKA_NODE_NUMBER >/data/kafka/zookeeper/myid
chown -R kafka:kafka /data/kafka/zookeeper
sleep 2


#### Zookeeper service config ####
cd /etc/systemd/system
rm -rf zookeeper.service
cat <<EOF >> zookeeper.service
[Unit]

[Service]
Type=simple
User=kafka
LimitNOFILE=800000
Environment="LOG_DIR=/data/log/zookeeper"
Environment="GC_LOG_ENABLED=true"
Environment="KAFKA_HEAP_OPTS=-Xms512M -Xmx4G"
ExecStart=/opt/kafka/bin/zookeeper-server-start.sh /opt/kafka/config/zookeeper.properties
Restart=on-failure
TimeoutSec=900
[Install]
WantedBy=multi-user.target
EOF
sleep 2

#### Zookeeper service start ####
chown -R kafka:kafka /data/kafka/zookeeper
sleep 2

#### Kafka service config ####
cd /etc/systemd/system
rm -rf kafka.service
cat <<EOF >> kafka.service
[Unit]

Requires=zookeeper.service
After=zookeeper.service

[Service]
Type=simple
User=kafka
LimitNOFILE=800000
Environment="LOG_DIR=/data/log/kafka"
Environment="GC_LOG_ENABLED=true"
Environment="KAFKA_HEAP_OPTS=-Xms512M -Xmx4G"
ExecStart=/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties
Restart=on-failure
TimeoutSec=900
[Install]
WantedBy=multi-user.target
EOF

sleep 2
chown -R kafka:kafka /data/log/kafka /data/log/zookeeper /data/kafka/zookeeper /data/kafka/kafka /opt/kafka



