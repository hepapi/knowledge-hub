# NMap Command

Nmap (an acronym of Network Mapper) is an open-source command-line utility to securely manage the network. Nmap command has an extensive list of options to deal with security auditing and network exploration.

>Prerequisites
To use the Nmap utility, the Nmap must be installed on your Ubuntu 22.04. Nmap is available on the official repository of Ubuntu 22.04. Before installation, it is a better practice to update the core libraries of Ubuntu 22.04 as follows:

```bash
sudo apt update
sudo apt install nmap
```
or
```bash
sudo apt update
snap install nmap
```

#### Syntax of Nmap command
The syntax of the Nmap command is given below:
```bash
nmap [options] [IP-adress or web-address]
```
The Nmap command can be used to scan through the open ports of the host. For instance, the following command will scan the “xxx.xxx.xxx” for open ports..

#### How to use the Nmap command to scan specific port(s)
By default, the Nmap scans through only 1000 most used ports (these are not consecutive but important). However, there are a total of 65535 ports. The Nmap command can be used to scan a specific port or all the ports.

To scan all ports: The -p- flag of the Nmap command helps to scan through all 65535 ports:
```bash
nmap -p- 192.168.214.138
```

To scan a ``specific port``: One can specify the port number as well. For instance, the following command will scan for port 88 only:
```bash
nmap -p 88 88 192.168.214.138
```

#### How to use the Nmap command to get the OS information
The Nmap command can be used to get the ``Operating System’s information``. For instance, the following command will get the information of the OS associated with the IP address.

```bash
sudo nmap -O 192.168.214.138
```


