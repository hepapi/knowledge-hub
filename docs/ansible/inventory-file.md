 Inventory file and Building an inventory

An Ansible inventory is a collection of managed hosts we want to manage with Ansible for various automation and configuration management tasks. Typically, when starting with Ansible, we define a static list of hosts known as the inventory. These hosts can be grouped into different categories, and then we can leverage various patterns to run our playbooks selectively against a subset of hosts. 
By default, the inventory is stored in /etc/ansible/hosts, but you can specify a different location with the -i flag or the ansible.cfg configuration file.

The most common formats are either INI or YAML.

In this example, we use the INI format, define four managed hosts, and we group them into two host groups; webservers and databases. The group names can be specified between brackets, as shown below.Inventory groups are one of the handiest ways to control Ansible execution. Hosts can also be part of multiple groups.

```bash
[webservers]
host01.hepapi.com
host02.hepapi.com

[databases]
host03.hepapi.com
host04.hepapi.com

[londra]
host01.hepapi.com
host03.mycompany.com

[istanbul]
host02.hepapi.com
host04.hepapi.com
```
By default, we can also reference two groups without defining them. The all group targets all our hosts in the inventory, and the ungrouped contains any host that isn’t part of any user-defined group.

We can also create nested groups of hosts if necessary.

```bash
[londra]
host01.hepapi.com
host03.mycompany.com

[istanbul]
host02.hepapi.com
host04.hepapi.com

[hepapi:children]
istanbul
londra
```
Another useful functionality is the option to define aliases for hosts in the inventory. For example, we can run Ansible against the host alias host01 if we define it in the inventory as:

```bash
host01 ansible_host=host01.hepapi.com
```
# Inventory and Variables

An important aspect of Ansible’s project setup is variable’s assignment and management. Ansible offers many different ways of setting variables, and defining them in the inventory is one of them.

For example, let’s define one variable for a different application version for every host in our dummy inventory from before.

```bash
[webservers]
host01.hepapi.com app_version=1.0.1
host02.hepapi.com app_version=1.0.2

[databases]
host03.hepapi.com app_version=1.0.3
host04.hepapi.com app_version=1.0.4
```
Ansible-specific connection variables such as ansible_user or ansible_host are examples of host variables defined in the inventory.Similarly, variables can also be set at the group level in the inventory and offer a convenient way to apply variables to hosts with common characteristics.

```bash
[webservers]
host01.hepapi.com app_version=1.0.1
host02.hepapi.com app_version=1.0.2

[databases]
host03.hepapi.com app_version=1.0.3
host04.hepapi.com app_version=1.0.4

[webservers:vars]
app_version=1.0.1

[databases:vars]
app_version=1.0.2
```
# Ansible Dynamic Inventories

Many modern environments are dynamic, cloud-based, possibly spread across multiple providers, and constantly changing. In these cases, maintaining a static list of managed nodes is time-consuming, manual, and error-prone. 

Ansible has two methods to properly track and target a dynamic set of hosts: inventory plugins and inventory scripts. The official suggestion is to prefer inventory plugins that benefit from the recent updates to ansible core. 

To see a list of available inventory plugins you can leverage to build dynamic inventories, you can execute ansible-doc -t inventory -l. We will look at one of them, the amazon.aws.aws_ec2, to get hosts from Amazon Web Services EC2.

Requirements
The below requirements are needed on the local controller node that executes this inventory.
- python >= 3.6
- boto3 >= 1.26.0
- botocore >= 1.29.0

dynamic_inventory_aws_ec2.yml
NOTE: The inventory file is a YAML configuration file and must end with aws_ec2.{yml|yaml}. Example: my_inventory.aws_ec2.yml

```bash
plugin: amazon.aws.aws_ec2
regions:
  - us-east-1
  - us-east-2
  - us-west-2
 
hostnames: tag:Name
keyed_groups:
  - key: placement.region
    prefix: aws_region
  - key: tags['environment']
    prefix: env
  - key: tags['role']
    prefix: role
groups:
   # add hosts to the "private_only" group if the host doesn't have a public IP associated to it
  private_only: "public_ip_address is not defined"
compose:
  # use a private address where a public one isn't assigned
  ansible_host: public_ip_address|default(private_ip_address)
```

We declare the plugin we want to use and other options, including regions to consider fetching data from, setting hostnames from the tag Name, and creating inventory groups based on region, environment, and role.