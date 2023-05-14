# Kubectl Autocompletion


## Install Dependencies

```bash
sudo apt-get install bash-completion 
```

## Install Kubectl Autocompletion
```bash
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
```
Restart your shell.

## Install Kubectl Alias `k` Autocompletion
```bash
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc
```