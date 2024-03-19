# RKE2 Registry Configuration

Upon startup, RKE2 will check to see if a `registries.yaml` file exists at `/etc/rancher/rke2/` and instruct containerd to use any registries defined in the file. If you wish to use a private registry, then you will need to create this file as root on each node that will be using the registry.

Configuration in containerd can be used to connect to a private registry with a TLS connection and with registries that enable authentication as well. The following section will explain the `registries.yaml` file and give different examples of using private registry configuration in RKE2.

## Configuration File

The file consists of two main sections:

+ mirrors
+ configs

Mirrors is a directive that defines the names and endpoints of the private registries. Private registries can be used as a local mirror for the default docker.io registry, or for images where the registry is explicitly specified.

```yaml
mirrors:
  <EC2_PUBLIC_IP>:8083:
    endpoint:
      - "https://<EC2_PUBLIC_IP>:8083"
```

When pulling an image from a registry, containerd will try these endpoint URLs one by one, and use the first working one.

-----------

The configs section defines the TLS and credential configuration for each mirror. For each mirror you can define `auth` and/or `tls`. The credentials consist of either username/password or authentication token.

## With TLS

Below are examples showing how you may configure `/etc/rancher/rke2/registries.yaml` on each node when using TLS.

```yaml
mirrors:
  <EC2_PUBLIC_IP>:8083:
    endpoint:
      - "https://<EC2_PUBLIC_IP>:8083"
configs:
  "<EC2_PUBLIC_IP>:8083":
    auth:
      username: username # this is the registry username
      password: password # this is the registry password
    tls:
      cert_file:            # path to the cert file used to authenticate to the registry
      key_file:             # path to the key file for the certificate used to authenticate to the registry
      ca_file:              # path to the ca file used to verify the registry's certificate
      insecure_skip_verify: # may be set to true to skip verifying the registry's certificate
```

:warning: If using a registry using plaintext HTTP without TLS, you need to specify `http://` as the endpoint URI scheme.

```yaml
mirrors:
  <EC2_PUBLIC_IP>:8083:
    endpoint:
      - "http://<EC2_PUBLIC_IP>:8083"
configs:
  "<EC2_PUBLIC_IP>:8083":
    auth:
      username: xxxxxx # this is the registry username
      password: xxxxxx # this is the registry password
```

----------------




