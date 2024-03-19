# Humio Single Node Installation Guide :fire:

### LogScale installers are available for several Linux distributions.

- Debian/Ubuntu
- Red Hat

### Prerequisites ;
##### :information_source: Minimum hardware requirements:

| Resources      | Limits                                                       |
| -----------    | ------------------------------------                         |
| `16GB`        | :fontawesome-solid-memory: MEMORY                          |
| `8CPU`        | :octicons-cpu-16: CPU                                      |
| `100GB`          | :material-database:     STORAGE                               |



!!! quote "Access Permissions"
    > The machine to be installed must have access to the following addresses.
    
    http://humio.com

    https://archive.apache.org/dist/zookeeper/zookeeper-3.7.1/apache-zookeeper-3.7.1-bin.tar.gz 

    https://downloads.apache.org/kafka/3.5.1/kafka_2.13-3.5.1.tgz [downloads.apache.org]
    
    hkp://keyserver.ubuntu.com:80
    
    http://repos.azulsystems.com/ubuntu [repos.azulsystems.com]
    
    https://repo.humio.com/repository/maven-releases/com/humio/server/1.117.0/server-1.117.0.tar.gz
    

The following ports must be open;
```yaml
80,443,8080,1514
```

You must follow the sequence below to install Falcon LogScale.

- [Java Installation Page](./javainstallation.md)
- [Zookeeper Installation Page](./zookeeperinstallation.md)
- [Kafka Installation Page](./kafkainstallation.md)
- [LogScale Installation Page](./humioinstallation.md)



