# Kafka Installation (kafka.sh)


> Usage of KAFKA_HOST

If you are going to install more than one kafka, you need to change the following variables

KAFKA_HOST_1=`"<Node1 Kafka IP Address>"`

KAFKA_HOST_2=`"<Node2 Kafka IP Address>"`

KAFKA_HOST_3=`"<Node3 Kafka IP Address>"`

*Ex: KAFKA_HOST_1="172.296.22.10"*

---

> Usage of KAFKA_NODE_NUMBER

If you are installing more than one kafka, you must specify a node number for each kafka. The value you provide indicates the rank of the kafka node.

`KAFKA_NODE_NUMBER=<Kafka Node Number>`

### 3 Cluster Kafka Example:
`(Primary Node kafka.sh)`   : KAFKA_NODE_NUMBER=1

`(Secondary Node kafka.sh)` : KAFKA_NODE_NUMBER=2

`(Third Node kafka.sh)` : KAFKA_NODE_NUMBER=3

---

> Usage of KAFKA_DOWNLOAD_LINK / KAFKA_PACKAGE_PATH

If you are going to download a package from humio.com in the Kafka installation, you must fill in the `"KAFKA_DOWNLOAD_LINK"` variable and leave the `"KAFKA_PACKAGE_PATH"` variable empty. If you are going to use a package on the server, you must fill in the `"KAFKA_PACKAGE_PATH"` variable and leave the `"KAFKA_PACKAGE_URL"` variable empty.

*Sample Usage (We will use URL):*

KAFKA_PACKAGE_PATH=""
KAFKA_DOWNLOAD_LINK="https://downloads.apache.org/kafka/3.7.0/kafka_2.13-3.7.0.tgz"

*Example Usage (We will use PATH):*

KAFKA_PACKAGE_PATH="/tmp/packages/kafka_2.13-3.7.0.tgz"
KAFKA_DOWNLOAD_LINK=""

---

# Humio Setup (humio.sh)

> Usage of KAFKA_HOST

If you are going to install more than one kafka, you need to change the following variables

KAFKA_HOST_1=`"<Node1 Kafka IP Address>"`
KAFKA_HOST_2=`"<Node2 Kafka IP Address>"`
KAFKA_HOST_3=`"<Node3 Kafka IP Address>"`

---

> Usage of EXTERNAL_IP / INTERNAL_IP

To access the Humio interface:

EXTERNAL_IP=`"<Humio External IP Address>"`

INTERNAL_IP=`"<Humio Internal IP Address>"`


---

> Usage of HUMIO_DOWNLOAD_LINK / HUMIO_PACKAGE_PATH

If you are going to download a package from humio.com in the Kafka installation, you must fill in the `"HUMIO_DOWNLOAD_LINK"` variable and leave the `"HUMIO_PACKAGE_PATH"` variable empty. If you are going to use a package on the server, you must fill in the `"HUMIO_PACKAGE_PATH"` variable and leave the `"HUMIO_DOWNLOAD_LINK"` variable empty.

*Sample Usage (We will use URL):*

HUMIO_PACKAGE_PATH=""
HUMIO_DOWNLOAD_LINK="https://repo.humio.com/repository/maven-releases/com/humio/server/1.131.1/server-1.131.1.tar.gz"

*Example Usage (We will use PATH):*

HUMIO_PACKAGE_PATH="/tmp/packages/server-1.131.1.tar.gz"
HUMIO_DOWNLOAD_LINK=""

# Run The Services

After the installation is completed, quickly run the following commands one by one.

> For each node (node1, node2, node3)

`systemctl enable zookeeper`

`systemctl start zookeeper`

`systemctl status zookeeper`


`systemctl enable kafka`

`systemctl start kafka`

`systemctl status kafka`
