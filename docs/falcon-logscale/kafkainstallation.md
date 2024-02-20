### Kafka Installation for Humio

LogScale recommend that the latest Kafka version be used with your LogScale deployment. The latest version of Kafka is available at [Kafka Downloads](https://kafka.apache.org/downloads)

```bash
apt-get update
apt-get upgrade
```
 Next, create a non-administrative user named, ``kafka`` to run Kakfa. You can do this by executing the following from the command-line: 
```bash
adduser kafka --shell=/bin/false --no-create-home --system --group
```
### Installation
 To install Kafka, you'll need to go to the /opt directory and download the latest release. You can do that like so with wget. 
```bash
cd /opt
wget https://www-us.apache.org/dist/kafka/x.x.x/kafka_x.x.x.x.tgz
```
You would adjust this last line, change the Xs to the latest version number. Once it downloads, untar the file and then create the directories it needs like this: 
```bash
tar zxf kafka_x.x.x.x.tgz

mkdir /var/log/kafka
mkdir /var/kafka/data
chown kafka:kafka /var/log/kafka
chown kafka:kafka /var/kafka/data

ln -s /opt/kafka_x.x.x.x /opt/kafka
```

The four lines in the middle here create the directories for Kafka's logs and data, and changes the ownership of those directories to the kafka user. The last line creates a symbolic to /opt/kafka. You would adjust that, though, replacing the Xs with the version number.

Using a simple text editor, open the Kafka properties file, server.properties, located in the kafka/config sub-directory. You'll need to set a few options — the lines below are not necessarily the order in which they'll be found in the configuration file:
```bash
broker.id=1
log.dirs=/var/kafka/data
delete.topic.enable = true
```
The first line sets the broker.id value to match the server number (myid) you set when configuring ZooKeeper. The second sets the data directory. The third line should be added to the end of the configuration file. When you're finished, save the file and change the owner to the kafka user: 
```bash
chown -R kafka:kafka /opt/kafka_x.x.x.x
```

You'll have to adjust this to the version you installed. Note, changing the ownership of the link /opt/kafka doesn't change the ownership of the files in the directory.

Now you'll need to create a service file for starting Kafka. Use a simple text editor to create a file named, kafka.service in the /etc/systemd/system/ sub-directory. Then add the following lines to the service file:
```bash
[Unit]
Requires=zookeeper.service
After=zookeeper.service

[Service]
Type=simple
User=kafka
LimitNOFILE=800000
Environment="LOG_DIR=/var/log/kafka"
Environment="GC_LOG_ENABLED=true"
Environment="KAFKA_HEAP_OPTS=-Xms512M -Xmx4G"
ExecStart=/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties
Restart=on-failure

[Install]
WantedBy=multi-user.target
```
Now you're ready to start the Kafka service. Enter the first line below to start it. When it finishes, enter the second line to check that it's running and there are no errors reported: 
```bash
systemctl start kafka
systemctl status kafka
systemctl enable kafka
```