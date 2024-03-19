# Understanding Sealed Secrets: Solving the Challenge of Securely Managing Kubernetes Secrets

Let's start by defining Sealed Secrets and addressing the problem it aims to solve.

When working with Kubernetes manifests, we often store them in Git version control systems alongside our application code. However, a challenge arises when dealing with Kubernetes Secret manifests, as they contain data that needs to be hidden but is stored in base64 format, which can be easily decrypted.

This is where Sealed Secrets comes to the rescue. It allows us to encrypt our Secrets into SealedSecrets, making them safe to store, even in public repositories. The decryption of SealedSecrets is only possible by the controller running in the target cluster, ensuring that not even the original author can obtain the original Secret from the SealedSecret.

To achieve this, two components are required: **kubeseal**, which we install locally, and the **controller** running in Kubernetes. With kubeseal, we encrypt our Secret manifests before pushing them to the Git repository. The Kubernetes controller is responsible for decrypting these encrypted Secret objects.

## Sealed Secret Example
These encrypted secrets are encoded in a SealedSecret resource, which you can see as a recipe for creating a secret. Here is how it looks:

```yaml
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: mysecret
  namespace: mynamespace
spec:
  encryptedData:
    foo: AgBy3i4OJSWK+PiTySYZZA9rO43cGDEq.....
```
Once unsealed, this produces a Secret equivalent to the following:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
  namespace: mynamespace
data:
  foo: YmFy  # <- base64 encoded "bar"
```
Having explored how a Secret is securely stored in a Git repository, let's proceed to the usage.
---
## Installation
Firstly, let's set up the Sealed Secrets controller in Kubernetes. I'll perform this task using Helm.
#### Helm Chart

The Sealed Secrets helm chart is now officially supported and hosted in this GitHub repo.

```bash
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
```
```bash
helm install sealed-secrets -n kube-system sealed-secrets/sealed-secrets
```

When the controller in the cluster up-and-running, it will generate a key. We will perform the encryption process with kubeseal, which we will install locally. You can find the kubeseal installation below for Mac and linux.

### Kubeseal

#### For Mac (Homebrew)

The `kubeseal` client is also available on [homebrew](https://formulae.brew.sh/formula/kubeseal):

```bash
brew install kubeseal
```
#### For Linux 
The `kubeseal` client can be installed on Linux, using the below commands:

```bash
KUBESEAL_VERSION='' # Set this to, for example, KUBESEAL_VERSION='0.23.0'
wget "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION:?}/kubeseal-${KUBESEAL_VERSION:?}-linux-amd64.tar.gz"
tar -xvzf kubeseal-${KUBESEAL_VERSION:?}-linux-amd64.tar.gz kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
```
If you have `curl` and `jq` installed on your machine, you can get the version dynamically this way. This can be useful for environments used in automation and such.

```
# Fetch the latest sealed-secrets version using GitHub API
KUBESEAL_VERSION=$(curl -s https://api.github.com/repos/bitnami-labs/sealed-secrets/tags | jq -r '.[0].name' | cut -c 2-)

# Check if the version was fetched successfully
if [ -z "$KUBESEAL_VERSION" ]; then
    echo "Failed to fetch the latest KUBESEAL_VERSION"
    exit 1
fi

wget "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz"
tar -xvzf kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
```
With the tools in place, both the cluster-side controller/operator and the client-side utility kubeseal are ready.
---
## Usage
Assuming we have a Kubernetes Secret manifest file named `mysecret.yaml` as follows:
```mysecret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
  namespace: mynamespace
data:
  foo: YmFy  # <- base64 encoded "bar"
```
We can encrypt the Kubernetes Secret file using the following command:
```
kubeseal --controller-name sealed-secrets -o yaml -n kube-system < mysecrets.yaml > encrypted-mysecret.yaml
```
Subsequently, we can apply the `encrypted-mysecret.yaml` file:
```
kubectl apply -f encrypted-mysecret.yaml
```
To summarize the process:

- The Sealed Secrets controller, installed with Helm, generated public and private keys.
- We encrypted the decrypted mysecret.yaml file locally using the kubeseal command.
- When deploying the encrypted-mysecret.yaml file into Kubernetes, the controller decrypted it with the private key, converting it into a Kubernetes Secret.

Now, with peace of mind, we can store our Secret manifests in Git repositories, especially if you are using GitOps, where you can automate your work by planning the file directory containing your encrypted manifests as an ArgoCD application.
