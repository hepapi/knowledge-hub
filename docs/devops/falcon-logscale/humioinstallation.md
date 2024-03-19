First, you'll need to create a non-administrative user named, ``humio`` to run LogScale software in the background. You can do this by executing the following from the command-line: 
```yaml
adduser humio --shell=/bin/false --no-create-home --system --group
```

You should add this user to the DenyUsers section of your nodes ``/etc/ssh/sshd_config`` file to prevent it from being able to ssh or sftp into the node. Remember to restart the sshd daemon after making the change. Once the system has finished updating and the user has been created, you can install Kafka.

Next, create the LogScale system directories and give the ``humio`` user ownership of them:
```yaml
mkdir -p /opt/humio /etc/humio/filebeat /var/log/humio /var/humio/data
chown humio:humio /opt/humio /etc/humio/filebeat
chown humio:humio /var/log/humio /var/humio/data
```
## Installation
You're now ready to download and install LogScale's software. You should go to the LogScale directory and use wget to download the LogScale Java Archive. You can do this from the command-line like so: 
```yaml
cd /opt/humio/

wget https://repo.humio.com/repository/maven-releases/com/humio/server/1.112.0/server-1.112.0.tar.gz

tar xzf /opt/humio/server-1.112.0.tar.gz
```
The wget here is used to download the latest release from [Download Humio Server](https://repo.humio.com/service/rest/repository/browse/maven-releases/com/humio/server/). You'll have to adjust the lines for the correct directory and file name, based on the version at the time. After you've downloaded it, enter the last line here to create a symbolic link to it. 

## Configuration
Using a simple text editor, create the LogScale configuration file, server.conf in the ``/etc/humio`` directory. There are a few environment variables you will need to enter in this configuration file in order to run LogScale on a single server or instance. Below are those basic settings:
```yaml
AUTHENTICATION_METHOD=single-user
SINGLE_USER_PASSWORD=<Your-Password-Here>
SINGLE_USER_USERNAME=<Your-Username-Here>
BOOTSTRAP_HOST_ID=1
DIRECTORY=/var/humio/data
HUMIO_AUDITLOG_DIR=/var/log/humio
HUMIO_DEBUGLOG_DIR=/var/log/humio
JVM_LOG_DIR=/var/log/humio
HUMIO_PORT=8080
ELASTIC_PORT=9200
ZOOKEEPER_URL=127.0.0.1:2181
KAFKA_SERVERS=127.0.0.1:9092
EXTERNAL_URL=http://<Your-LogScale-Machine-Ip-Address>:8080
PUBLIC_URL=http://<Your-LogScale-Machine-Ip-Address>
HUMIO_SOCKET_BIND=0.0.0.0
HUMIO_HTTP_BIND=0.0.0.0
```
Next you should set up a service file. Using a simple text editor, create a file named, humio.service in the ``/etc/systemd/system/`` sub-directory. Add these lines to that file:
```yaml
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
WorkingDirectory=/var/humio
ExecStart=/opt/humio/humio/bin/humio-server-start.sh

[Install]
WantedBy=default.target
```
 You will need to change the ownership of the LogScale files and start the LogScale service. To change the ownership, execute the following two lines from the command-line:
```yaml
chown -R humio:humio /opt/humio /etc/humio/filebeat
chown -R humio:humio /var/log/humio /var/humio/data
```
You're ready to start LogScale.
```yaml
systemctl start humio
```
Just to be sure LogScale is running and everything is fine, check it with the journalctl tool. You can do this by entering the following from the command-line
```yaml
journalctl -fu humio
```
If there are no errors, open a web browser and enter the domain name or IP address with port 8080. For example, you would enter something like http://example.com:8080 in the browser's address field.