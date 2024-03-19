# NSLOOKUP

### What is the 'nslookup'

##### Nslookup (stands for “Name Server Lookup”) is a useful command for getting information from the DNS server. It is a network administration tool for querying the Domain Name System (DNS) to obtain domain name or IP address mapping or any other specific DNS record. It is also used to troubleshoot DNS-related problems. 

> Syntax of the -`nslookup`- command in Linux System
```
nslookup [option] [hosts]
```

##### Options of nslookup command:  

|Options              |Description                   |
|----------------|-------------------------------|
|-domain=[domain-name]	|`allows you to change the default DNS name.`            |
|-debug	          |`enables the display of debugging information.`            |
|-port=[port-number]	 |`Use the -port option to specify the port number for queries. By default, nslookup uses port 53 for DNS queries`|
|-timeout=[seconds] |`you can specify the time allowed for the DNS server to respond. By default, the timeout is set to a few seconds`|
|-type=a	          |`	Lookup for a record We can also view all the available DNS records for a particular record using the -type=a option`|
|-type=any         |` Lookup for any record We can also view all the available DNS records using the -type=any option. `|
|-type=hinfo		          |` displays hardware-related information about the host. It provides details about the operating system and hardware platform `|
|-type=mx 		          |` Lookup for an mx record MX (Mail Exchange) maps a domain name to a list of mail exchange servers for that domain. The MX record says that all the mails sent to “google.com” should be routed to the Mail server in that domain. `|
|-type=ns		          |`Lookup for an ns record NS (Name Server) record maps a domain name to a list of DNS servers authoritative for that domain. It will output the name serves which are associated with the given domain. `|
|-type=ptr 		          |`used in reverse DNS lookups. It retrieves the Pointer (PTR) records, which map IP addresses to domain names.`|
|-type=soa		          |`Lookup for a soa record SOA record (start of authority), provides the authoritative information about the domain, the e-mail address of the domain admin, the domain serial number, etc… `|

## Examples For K8S Service

```yaml
kubectl exec -i -t dnsutils -- nslookup kubernetes.default
```
`kubectl exec busybox -- nslookup nginx-svc`
```yaml
Name:   nginx-svc.default.svc.cluster.local
Address: 10.100.245.19

nslookup: can't resolve 'kubernetes.default'
```
## Examples For K8S Pod

```yaml
pod-ip-address.my-namespace.pod.cluster-domain.example
```
`kubectl exec busybox -- nslookup 10-244-1-2.default.pod.cluster.local`
```yaml
172-17-0-3.default.pod.cluster.local
```

