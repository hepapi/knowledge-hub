# Jenkins Install :fire:

### Jenkins installers are available for several Linux distributions.

- Debian/Ubuntu
- Fedora
- Red Hat/Alma/Rocky

### Prerequisites ;
#### :information_source: Minimum hardware requirements:

| Resources      | Limits                                                       |
| -----------    | ------------------------------------                         |
| `256MB`        | :fontawesome-solid-memory: MEMORY                          |
| `512MB`        | :octicons-cpu-16: CPU                                      |
| `1GB`          | :material-database:     STORAGE                               |


!!! info "1 GB of drive space (although 10 GB is a recommended minimum if running Jenkins as a Docker container)"

#### :information_source: Recommended hardware configuration for a small team:

| Resources      | Limits                                                       |
| -----------    | ------------------------------------                         |
| `4GB`          | :fontawesome-solid-memory: MEMORY                            |
| `2`            | :octicons-cpu-16: CPU                                        |
| `50GB`         | :material-database:     STORAGE                              |


## Installation of Java

`Jenkins requires Java in order to run, yet certain distributions don’t include this by default and some Java versions are incompatible with Jenkins.
There are multiple Java implementations which you can use. OpenJDK is the most popular one at the moment, we will use it in this guide.
Update the Debian apt repositories, install OpenJDK 11, and check the installation with the commands: `

```groovy
$ sudo apt update
$ sudo apt install openjdk-11-jre
$ java -version
openjdk version "11.0.12" 2021-07-20
OpenJDK Runtime Environment (build 11.0.12+7-post-Debian-2)
OpenJDK 64-Bit Server VM (build 11.0.12+7-post-Debian-2, mixed mode, sharing)
```

!!! warning "After installing Java without any problems, we will install jenkins"


## Jenkins Install

```groovy
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update
sudo apt-get install jenkins
```

!!! quote

    If Jenkins fails to start because a port is in use, run -- systemctl edit jenkins -- and add the following ;
    ```bash
    [Service]
    Environment="JENKINS_PORT=8081"
    ```

## Start Jenkins
You can enable the Jenkins service to start at boot with the command:
```bash
sudo systemctl enable jenkins
```

You can start the Jenkins service with the command:
```bash
sudo systemctl start jenkins
```

You can check the status of the Jenkins service using the command:
```bash
sudo systemctl status jenkins
```

If everything has been set up correctly, you should see an output like this:
```groovy
Loaded: loaded (/lib/systemd/system/jenkins.service; enabled; vendor preset: enabled)
Active: active (running) since Tue 2018-11-13 16:19:01 +03; 4min 57s ago
```
>If you have a firewall installed, you must add Jenkins as an exception. You must change YOURPORT in the script below to the port you want to use. Port 8080 is the most common.
```groovy
YOURPORT=8080
PERM="--permanent"
SERV="$PERM --service=jenkins"

firewall-cmd $PERM --new-service=jenkins
firewall-cmd $SERV --set-short="Jenkins ports"
firewall-cmd $SERV --set-description="Jenkins port exceptions"
firewall-cmd $SERV --add-port=$YOURPORT/tcp
firewall-cmd $PERM --add-service=jenkins
firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --reload
```

- :arrow_right: After installing Jenkins, we go to the instance ip address e.g : `< ip-address >:8080` 
- :arrow_right: On the page that opens, it asks us to enter a token. We take this token from the server with the `cat /var/lib/jenkins/secrets/initialAdminPassword` code and paste it into the input and log in.

- :arrow_right: Jenkins gives you two options.
    - :arrow_right: `Install Suggested Plugins`
    - :arrow_right: `Select Plugins To Install`

!!! warning "If you don't see jenkins when you go to your server's ip address, allow port 8080"

:fire: *You can login to Jenkins by choosing the one you want and creating Username and Password.*



[For more installation details](https://www.jenkins.io/doc/book/installing/linux/)
### Happy Jenkins  :confetti_ball:



