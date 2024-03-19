Install at least java version 17 in the following order

Download java package
```yaml
https://cdn.azul.com/zulu/bin/zulu17.48.15-ca-jdk17.0.10-linux_amd64.deb
```

Import Azul’s public key:
```yaml
sudo apt install gnupg ca-certificates curl
```
```yaml
curl -s https://repos.azul.com/azul-repo.key | sudo gpg --dearmor -o /usr/share/keyrings/azul.gpg
```
```yaml
echo "deb [signed-by=/usr/share/keyrings/azul.gpg] https://repos.azul.com/zulu/deb stable main" | sudo tee /etc/apt/sources.list.d/zulu.list
```

Install the required Azul Zulu package:
```yaml
sudo apt install zulu17-jdk
```
Check java version
```yaml
java -version
```


