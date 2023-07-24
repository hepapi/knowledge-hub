# Nexus Installation - Docker Private Registry

This guide shows how to install Nexus to an EC2 instance and run as a container.

----------------

### Requirements

* EC2 Instance
* Docker

### EC2 Configurations

- Min. 4 GB memory
- Edit security group rules to allow port range from 8080 to 8082.
- Enable Auto-assign public IP

-----------------

## Installation

Since docker volumes are persistent, a volume can be created specifically for this purpose. This is the recommended approach.

```bash
docker volume create --name nexus-data
```

The next step is to mount the volume with docker run command. We will use port 8081 to connect Nexus. Other port(s) are used for repository connections. Repository ports must be unique.

In this guide, we open port 8082 as docker hosted repository connection and port 8083 as docker proxy connection.

```bash
docker run -d -p 8081:8081 -p 8082:8082 -p 8083:8083 --restart always --name nexus -v nexus-data:/nexus-data sonatype/nexus3
```

Browse following URL:

```bash
http://<EC2_INSTANCE_PUBLIC_IP>:8081
```

Default username is admin. To see the password, run the command:

```bash
sudo cat /var/lib/docker/volumes/nexus-data/_data/admin.password
```

:warning: After login, it is mandatory to set a new password.

----------------------------------------------------------------------------------------
