# What is Istio?

Istio is an open-source service mesh solution that provides secure and observable networking between services running on Kubernetes. It helps manage service-to-service communication, enhances security, and controls traffic flow with minimal changes to application code. This document covers the following aspects of Istio:

- How Istiod (Istio Control Plane) works
- What mutual TLS (mTLS) is and how it secures service-to-service communication
- The differences between installing Istio using **Helm** and **istioctl**
- Different methods for enabling sidecar injection, including exclusions
- Demonstrating mTLS with two example pods

## How Istiod Works

Istiod is the **control plane** of Istio. It manages the configuration and behavior of the **data plane**, which consists of Envoy proxies deployed as sidecars in pods. The main responsibilities of Istiod include:

- **Service Discovery**: Detecting and managing services within the cluster.
- **Configuration Management**: Dynamically configuring Envoy proxies based on Istio policies.
- **Traffic Control**: Routing traffic based on rules defined in VirtualService and DestinationRule objects.
- **Security Enforcement**: Handling authentication, authorization, and mTLS policies.
- **Observability**: Collecting telemetry data such as logs, metrics, and traces for better monitoring.

## What is Mutual TLS (mTLS)?

Mutual TLS (mTLS) is a security feature of Istio that ensures encrypted and authenticated communication between services. With mTLS enabled:

- Each service is issued a cryptographic certificate to verify its identity.
- Traffic between services is encrypted, preventing eavesdropping.
- Unauthorized services cannot communicate with protected services.

Istio supports different mTLS modes:

- **PERMISSIVE**: Allows both plaintext and mTLS communication (useful for migration).
- **STRICT**: Enforces mTLS for all service-to-service communication.
- **DISABLE**: Turns off mTLS.

## Installing Istio (Helm vs istioctl)

Istio can be installed using **Helm** or **istioctl**, with each having different advantages:

| Method      | Pros | Cons |
|------------|------|------|
| **Helm**   | More control over Kubernetes manifests, easier GitOps integration | More manual configuration required |
| **istioctl** | Simplifies installation, automatic best-practice settings | Less control over individual manifests |

### Install Istio with Helm

```sh
helm repo add istio-official https://istio-release.storage.googleapis.com/charts
helm repo update
helm install my-istiod istio-official/istiod --version 1.25.0 -n istio-system --create-namespace
```

## Enabling Sidecar Injection

Sidecar injection ensures that each pod in a namespace gets an **Envoy proxy** automatically. Istio supports different methods of enabling injection:

### 1. Namespace-Based Auto Injection

```sh
kubectl label namespace default istio-injection=enabled
```

- This method enables automatic sidecar injection for **all new pods** in the `default` namespace.
- Existing pods **must be restarted** to get the sidecar.

### 2. Manual Sidecar Injection

```sh
kubectl get deployment nginx -o yaml | istioctl kube-inject -f - | kubectl apply -f -
```

- This injects the Envoy proxy **manually** into the `nginx` deployment.
- Useful for cases where you don't want automatic injection.

### 3. Excluding Pods from Injection

To exclude specific pods from sidecar injection, use **annotations**:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: no-sidecar-pod
  annotations:
    sidecar.istio.io/inject: "false"
spec:
  containers:
  - name: app
    image: nginx
```

This ensures that the pod **does not get an Envoy sidecar**, even if injection is enabled for the namespace.

## Verifying Sidecar Injection
To test if sidecar injection is working correctly, deploy an Nginx pod and check its status:

```sh
kubectl create deployment nginx --image=nginx
kubectl get pods
```

Expected output (`READY` should be `2/2`):

```
NAME                     READY   STATUS    RESTARTS   AGE
nginx-xxxxxxx-xxxxx      2/2     Running   0          1m
```

## Enabling and Testing mTLS

To enforce **STRICT mTLS**, apply the following `PeerAuthentication` policy:

```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: istio-system
spec:
  mtls:
    mode: STRICT
```

Apply with:
```sh
kubectl apply -f mtls-policy.yaml
```

### Testing mTLS with Two Pods

1. Deploy two pods (`client` and `server`) in the `default` namespace:

```sh
kubectl run client --image=curlimages/curl -i --tty -- sh
kubectl run server --image=nginx
```

2. Try sending a request from `client` to `server`:

```sh
kubectl exec -it client -- curl http://server.default.svc.cluster.local
```

If **mTLS is enabled (STRICT mode)**, the request should **fail** because direct HTTP (plaintext) communication is blocked. If mTLS were **PERMISSIVE**, the request would succeed.

### Conclusion

- **Istiod** manages service discovery, security, and traffic routing.
- **mTLS** ensures encrypted and authenticated service-to-service communication.
- **Helm vs istioctl**: Helm provides more control, istioctl is easier.
- **Sidecar Injection** can be enabled per namespace, manually, or excluded per pod.
- **mTLS can be tested using two pods** to verify encryption enforcement.

This completes the **basic Istio setup with security best practices**.


## Kaynaklar

- [Istio Resmi Dokümantasyonu](https://istio.io/latest/docs/)
- [YouTube: Dokümantasyona öğrettiği bilgilerle yön veren Hintli abi 🤝](https://www.youtube.com/watch?v=eSNetKBe7Z8)