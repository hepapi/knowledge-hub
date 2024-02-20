```yaml
apt-get update
apt-get upgrade
```
Next, create a non-administrative user named, ``zookeeper`` to run Kafka. You can do this by executing the following from the command-line: 
```yaml
adduser zookeeper --shell=/bin/false --no-create-home --system --group
```
You should add this user to the DenyUsers section of your nodes ``/etc/ssh/sshd_config`` file to prevent it from being able to ssh or sftp into the node. Remember to restart the sshd daemon after making the change. Once the system has finished updating and the user has been created, you can install ZooKeeper.

## Installation
Navigate to opt directory and download a of ZooKeeper. The official release site is [Apache Zookeeper Release](https://zookeeper.apache.org/releases.html)
```yaml
cd /opt
wget https://archive.apache.org/dist/zookeeper/zookeeper-3.7.1/apache-zookeeper-3.7.1-bin.tar.gz
```
After the file downloads, untar the ZooKeeper file and create a symbolic to ``/opt/zookeeper`` like so: 
```yaml
tar -zxf apache-zookeeper-x.x.x-bin.tar.gz
ln -s /opt/apache-zookeeper-x.x.x-bin /opt/zookeeper
```
Navigate to zookeeper sub-directory and create a data directory for ZooKeeper: 
```yaml
cd /opt/zookeeper
mkdir -p /var/zookeeper/data
```
## Configuration
Using a text editor, create the ZooKeeper configuration file in the conf sub-directory. Name the file, zoo.cfg. For example, ``/opt/zookeeper/conf/zoo.cfg``. Copy the lines below into that file:
```yaml
tickTime = 2000
dataDir = /var/zookeeper/data
clientPort = 2181
initLimit = 5
syncLimit = 2
maxClientCnxns=60
autopurge.purgeInterval=1
admin.enableServer=false
4lw.commands.whitelist=*
server.1=127.0.0.1:2888:3888
admin.enableServer=false
```
Create a myid file in the data sub-directory with just the number 1 as its contents. They you can start ZooKeeper to verify that the configuration is working:

```yaml
bash -c 'echo 1 > /var/zookeeper/data/myid'

./bin/zkServer.sh start
ZooKeeper JMX enabled by default
Using config: /opt/zookeeper-x.x.x/bin/../conf/zoo.cfg
Starting zookeeper ... STARTED
```
Stop ZooKeeper and change the ownership of the zookeeper directory like so, adjusting for the version number you installed: 
```yaml
./bin/zkServer.sh stop

chown -R zookeeper:zookeeper /opt/apache-zookeeper-x.x.x
chown -R zookeeper:zookeeper /var/zookeeper/data
```

So that ZooKeeper will start when the server is rebooted, you'll need to create a ZooKeeper service file named zookeeper.service in the ``/etc/systemd/system/`` sub-directory. Use a text editor to create the file and copy the following lines into it.
```yaml
[Unit]
Description=ZooKeeper Daemon
Documentation=http://zookeeper.apache.org
Requires=network.target
After=network.target

[Service]
Type=forking
WorkingDirectory=/opt/zookeeper
User=zookeeper
Group=zookeeper
ExecStart=/opt/zookeeper/bin/zkServer.sh start /opt/zookeeper/conf/zoo.cfg
ExecStop=/opt/zookeeper/bin/zkServer.sh stop /opt/zookeeper/conf/zoo.cfg
ExecReload=/opt/zookeeper/bin/zkServer.sh restart /opt/zookeeper/conf/zoo.cfg
TimeoutSec=30
Restart=on-failure

[Install]
WantedBy=default.target
```
Start the ZooKeeper service. Enter the first line below to start it. When it finishes, enter the second line to check that it's running and there are no errors reported: 
```yaml
systemctl start zookeeper
systemctl status zookeeper
systemctl enable zookeeper
```
