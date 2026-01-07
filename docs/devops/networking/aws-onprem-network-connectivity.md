In an EKS Hybrid architecture, the Kubernetes control plane is managed in AWS, while worker nodes may operate on-premises or across distinct network domains.

Ensuring reliable, `bidirectional connectivity between on-premises pods and the AWS-hosted control plane network` is essential for cluster stability and troubleshooting.

This documentation walks through a practical and reproducible method for validating ICMP reachability and routing paths (ping, traceroute) using a temporary EC2 instance as the AWS-side reference and an NGINX-based debug pod running on a designated hybrid node.


### Export Required Environment Variables

We start by exporting the AWS and network-related variables that will be reused throughout the guide.

Note:
  - VPC_ID must be the same VPC where the EKS cluster resides
  - SUBNET_ID must be one of the cluster subnets
  

```bash
export AWS_PROFILE=AWS_PROFILE
export AWS_DEFAULT_REGION=AWS_DEFAULT_REGION

export VPC_ID=VPC_ID
export SUBNET_ID=SUBNET_ID
export KP_NAME=KP_NAME
```

### Create a Security Group for Network Testing

We create a temporary security group that allows all inbound and outbound traffic.
This is strictly for network diagnostics and must not be used in production workloads.

#### Create the security group

```bash
SG_ID=$(aws ec2 create-security-group \
  --group-name netshoot-test-all \
  --description "Allow all -- network test for hybrid cluster" \
  --vpc-id $VPC_ID \
  --query 'GroupId' \
  --output text)
```

#### Allow all traffic

```bash
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol -1 \
  --port -1 \
  --cidr 0.0.0.0/0
```

### Launch a Temporary EC2 Instance

To avoid hardcoding AMI IDs, we dynamically fetch the latest image from SSM.

#### Fetch latest AMI ID

```bash
AMI_ID=$(aws ssm get-parameter \
  --name /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
  --query 'Parameter.Value' \
  --output text)
```

#### Create the EC2 instance

```bash
aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type t2.small \
  --key-name $KP_NAME \
  --subnet-id $SUBNET_ID \
  --security-group-ids $SG_ID \
  --tag-specifications 'ResourceType=instance,Tags=[
      {Key=Name,Value=netshoot-test-ec2},
      {Key=DeleteAfterTest,Value=true},
      {Key=Team,Value=DevOps}
  ]'
```

This EC2 instance represents the AWS-side network plane of the EKS Hybrid Cluster.

### Deploy an NGINX Debug Pod on a Specific Hybrid Node

To perform deterministic network testing in a Hybrid EKS setup, it is important to control where the test pod is scheduled.

⚠️ `spec.nodeName` is a static field and must be resolved before applying the manifest. As new hybrid worker nodes are added to the cluster, this value can be updated to point to the newly joined nodes.

#### Apply the manifest

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-net-debug
spec:
  nodeName: NODE_NAME
  containers:
  - name: nginx
    image: public.ecr.aws/nginx/nginx:latest
    command:
      - sh
      - -c
      - |
        apt-get update && \
        apt-get install -y \
          iputils-ping \
          traceroute \
          telnet \
          netcat-openbsd \
          curl && \
        nginx -g 'daemon off;'
    ports:
    - containerPort: 80
```

### Run Network Tests from Pod → EC2

Exec into the pod:

```bash
kubectl exec -it nginx-net-debug -- bash
```

Run connectivity tests toward the EC2 instance:

```bash
ping EC2_PRIVATE_IP
traceroute EC2_PRIVATE_IP
```

### Run Network Tests from EC2 → Pod

SSH into the EC2 instance and test connectivity back to the pod:

```bash
ping POD_IP
traceroute POD_IP
```

Below is an example of a successful round-trip network test from the pod:

#### Ping output

```txt
root@nginx-net-debug:/# ping 10.20.78.244
PING 10.20.78.244 (10.20.78.244) 56(84) bytes of data.
64 bytes from 10.20.78.244: icmp_seq=1 ttl=121 time=58.3 ms
64 bytes from 10.20.78.244: icmp_seq=2 ttl=121 time=58.4 ms
64 bytes from 10.20.78.244: icmp_seq=3 ttl=121 time=58.2 ms
--- 10.20.78.244 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss
```

#### Traceroute output

```txt
root@nginx-net-debug:/# traceroute 10.20.78.244
traceroute to 10.20.78.244 (10.20.78.244), 30 hops max
 1  * * *
 2  10.15.78.158 (10.15.78.158)  0.592 ms
 3  172.28.120.254 (172.28.120.254)  3.159 ms
 4  172.28.3.253 (172.28.3.253)  3.095 ms
 5  172.28.99.52 (172.28.99.52)  3.050 ms
 6  192.168.30.2 (192.168.30.2)  2.928 ms
 7  10.20.78.244 (10.20.78.244)  58.149 ms
```


This approach provides a clear, reproducible method to validate:

  - Pod → AWS Control Plane
  - AWS Control Plane → Pod connectivity
  - Routing paths across hybrid boundaries

All without custom images or private registries.