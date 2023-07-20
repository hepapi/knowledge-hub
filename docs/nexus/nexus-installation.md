# Nexus Installation - Docker Private Registry

This guide shows how to install Nexus to an EC2 instance and run as a container.

----------------

### Requirements

* EC2 Instance
* Docker

### EC2 Configurations

- Min. 2 GB memory
- Edit security group rules to allow port range from 8080 to 8082.
- Enable Auto-assign public IP

-----------------

## Installation

Since docker volumes are persistent, a volume can be created specifically for this purpose. This is the recommended approach.

```bash
docker volume create --name nexus-data
```

The next step is to mount the volume with docker run command. We will use port 8081 to connect Nexus. Other port(s) are used for repository connections. Repository ports must be unique.

```bash
docker run -d -p 8081:8081 -p 8082:8082 --restart always --name nexus -v nexus-data:/nexus-data sonatype/nexus3
```

Browse following URL:

```bash
http://<EC2_INSTANCE_PUBLIC_IP>:8081
```

Default username is admin. To see the password, run the command:

```bash
sudo cat /var/lib/docker/volumes/nexus-data/_data/admin.password
```

+ After login, it is mandatory to set a new password.
+ Go to repositories and click `Create repository`
+ Select `docker(hosted)`
+ Type the repository name.
+ Select HTTP as repository connector on port 8082.
+ Finally, click `Create repository` at the bottom.

----------------

## Principle of least privilege

For security purposes, we should use roles and users to grant permissions for specific tasks.

### Create Role and User

* Type : Select Nexus role
* Privileges: Add `nx-repository-admin-*-*-*` This permission will allow all actions for all artifact and repository types.
>* First and second "*" represent recipe and repository type (docker hosted, docker proxy, apt hosted, apt proxy etc.) 
>* Last one represents actions (add,browse,read,edit,delete)
* Create a new user using the role just created.

----------------------------------------------------------------------------------------

:warning: In Nexus Repository, the `Docker Bearer Token Realm` is required in order to allow anonymous pulls from Docker repositories

To allow anonymous pull:

+ Go to `Realms` in Secutiry, add Docker Bearer Token Realm to active category.
+ Edit the repo and click `Allow anonymous docker pull`

----------------------------------------------------------------------------------------

## Push an image to Nexus

Tag the image to repository url with HTTP connector port:

```bash
docker tag <IMAGE>:<VERSION> <EC2_PUBLIC_IP>:8082/<IMAGE>:<VERSION>
```

Then, edit docker daemon to insecure connection via HTTP.

```bash
sudo vim /etc/docker/daemon.json
```

Add this:

```bash
{
  "insecure-registries": ["<EC2_PUBLIC_IP>:8082"]
}
```

When you specify `--restart always` in docker run command, the container will also always start on daemon startup, regardless of the current state of the container. If docker service is not running, restart the service and start the container again:

```bash
systemctl restart docker
docker ps -a # Get ID or name of container
docker start <nexus-container>
```

If access to a repository requires the user to be authenticated, Docker will check for authentication access in the `.docker/config.json`file on your local machine. If authentication is not found, you will need to perform a `docker login` command.

```bash
docker login -u <username> <EC2_PUBLIC_IP>:8082
```

Then, push the image:

```bash
docker push <EC2_PUBLIC_IP>:8082/<IMAGE>:<VERSION>
```

## Copy Nexus Credentials into Kubernetes

As we mentioned before, the login process creates or updates a config.json file that holds an authorization token.

View the config.json file:

```bash
cat ~/.docker/config.json
```

The output contains a section similar to this:

```json
{
    "auths": {
        "<EC2_PUBLIC_IP>:8082": {
            "auth": "c3R...zE2"
        }
    }
}

```
A Kubernetes cluster uses the secret of kubernetes.io/dockerconfigjson type to authenticate with a container registry to pull a private image.

If you already ran docker login, you can copy that credential into Kubernetes:

```bash
kubectl create secret generic regcred \
    --from-file=.dockerconfigjson=~/.docker/config.json \
    --type=kubernetes.io/dockerconfigjson
```

----------------------------------------------------------------------------------------