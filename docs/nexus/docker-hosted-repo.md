## Docker Hosted Repository

+ Go to repositories and click `Create repository`
+ Select `docker(hosted)`
+ Type the repository name.
+ Select HTTP as repository connector on port 8082.
+ Finally, click `Create repository` at the bottom.

## Push an image to Nexus

Tag the image to repository url with HTTP connector port:

```bash
docker tag <IMAGE>:<VERSION> <EC2_PUBLIC_IP>:8082/<IMAGE>:<VERSION>
```

Then, edit docker daemon to insecure connection via HTTP.

```bash
sudo vim /etc/docker/daemon.json
```

Add this and restart the docker service.

```bash
{
  "insecure-registries": ["<EC2_PUBLIC_IP>:8082" # hosted repo
  ]
}
```

```bash
systemctl restart docker
```

When you specify `--restart always` in docker run command, the container will also always start on daemon startup, regardless of the current state of the container. If docker service is not running, after restart the service, start the container again:

```bash
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

----------------------------------------------------------------------------------------
