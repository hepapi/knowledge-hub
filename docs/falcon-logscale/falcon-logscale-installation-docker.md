# Falcon LogScale Setup With Docker :simple-docker:

##### :information_source: Falcon LogScale Setup Requirements :


| Resources      | Limits                                                       |
| -----------    | ------------------------------------                         |
| `4GB`          | :fontawesome-solid-memory: MEMORY							|
| `2`            | :octicons-cpu-16: CPU            							|
| `30GB`         | :material-database:     STORAGE                              |



:warning: The first step to install LogScale using `Docker` is to `install Docker` on the machine where you want to run `Docker` with LogScale. You can [Download Docker](https://docs.docker.com/engine/install/ubuntu/) from their site or by using a package installation program like yum or apt-get.


**Or You Can Use These Command For Ubuntu**:

```bash
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt install docker.io
systemctl start docker
systemctl enable docker
docker --version
```

>Now let's run a container on port 8080 using the following commands and watch it with ``docker ps``
!!! warning annanote  "Important Installations Notes"

    If your machine is not open to port 8080, make it open

```bash
export HOST_DATA_DIR=/home/ubuntu/mounts/data
export HOST_KAFKA_DATA_DIR=/home/ubuntu/mounts/kafka-data
export PATH_TO_READONLY_FILES=/home/ubuntu/mounts/readonly
export HOST_ENV_FILE=/home/ubuntu/mounts/

mkdir -p $PATH_TO_READONLY_FILES
mkdir -p $HOST_KAFKA_DATA_DIR
mkdir -p $HOST_DATA_DIR
touch $HOST_ENV_FILE.env

docker run -v $HOST_DATA_DIR:/data  \
   -v $HOST_KAFKA_DATA_DIR:/data/kafka-data  \
   -v $PATH_TO_READONLY_FILES:/etc/humio:ro  \
   -e AUTHENTICATION_METHOD=single-user \
   -e SINGLE_USER_USERNAME=hepapi \
   -e SINGLE_USER_PASSWORD=123456 \
   --net=host \
   --name=humio \
   --ulimit="nofile=8192:8192"  \
   --stop-timeout 300 \
   --env-file=$HOST_ENV_FILE  \
   -d \
   -p 8080:8080 \
   humio/humio
```

```bash title=" 'HOST_DATA_DIR, HOST_KAFKA_DATA_DIR, HOST_ENV_FILE, PATH_TO_READONLY_FILES' "
We bind these exported variables to the downloaded HUMIO container.
```
!!! info

    SINGLE_USER_USERNAME= Your Username for login 

    SINGLE_USER_PASSWORD= Your Password for login

!!! success

    Let's go your http://ip-address:8080 and enter activation key and enter your `SINGLE_USER_USERNAME` and `SINGLE_USER_PASSWORD`