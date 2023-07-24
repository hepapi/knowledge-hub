## Docker Proxy Repository

+ Go to repositories and click `Create repository`
+ Select `docker(proxy)`
+ Type the repository name.
+ Select HTTP as repository connector on port 8083.
+ Enable Docker V1 API support if required by the remote repository.
+ Add remote storage URL being proxied *(e.g. https://registry-1.docker.io, https://gcr.io)*
+ If your remote repository is docker hub, select docker index as *"Use Docker Hub"*. Otherwise, select *"Use proxy registry (specified above)"*
+ Finally, click `Create repository` at the bottom.

Then, edit docker daemon to insecure connection via HTTP.

```bash
sudo vim /etc/docker/daemon.json
```

Add this and restart the docker service.

```bash
{
  "insecure-registries": ["<EC2_PUBLIC_IP>:8083"  # proxy repo
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

From docker cli, pull an image but don't pull it from docker hub or gcr, pull it through the HTTP endpoint of your docker proxy repo that you have created above like so:

```bash
docker pull <EC2_PUBLIC_IP>:8083/example-image
```

This will create a pull request to your Nexus OSS, which will proxy the request to remote repository you specified before. The image from remote repository will be cached in your Nexus and will be delivered to you.

----------------------------------------------------------------------------------------
