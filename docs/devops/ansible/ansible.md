# Install Ansible with pipx

Use pipx in your environment to install the full Ansible package:

```bash
pipx install --include-deps ansible
```

You can install the minimal ansible-core package:

```bash
pipx install ansible-core
```

Alternately, you can install a specific version of ansible-core

```bash
pipx install ansible-core
```

# Install Ansible with pip

Locate and remember the path to the Python interpreter you wish to use to run Ansible. The following instructions refer to this Python as python3. For example, if you have determined that you want the Python at /usr/bin/python3.9 to be the one that you will install Ansible under, specify that instead of python3

To verify whether pip is already installed for your preferred Python

```bash
python3 -m pip -V
```

If all is well, you should see something like the following:

```bash
pip 21.0.1 from /usr/lib/python3.9/site-packages/pip (python 3.9)
```

If you see an error like No module named pip, you will need to install pip under your chosen Python interpreter before proceeding. This may mean installing an additional OS package (for example, python3-pip), or installing the latest pip directly from the Python Packaging Authority by running the following:

```bash
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py --user
```
If so, pip is available, and you can move on to the install ansible

Use pip in your selected Python environment to install the full Ansible package for the current user:

```bash
python3 -m pip install --user ansible
```

You can install the minimal ansible-core package for the current user:

```bash
python3 -m pip install --user ansible
```

You can install the minimal ansible-core package for the current user:

```bash
python3 -m pip install --user ansible-core
```

# Install Ansible on Ubuntu 22.04

The easiest way to install Ansible on ubuntu 22.04 is to use the apt package manager.

Add a new Ansible repository to the list of software sources that your system uses to install and update software packages.

```bash
sudo apt-add-repository -y ppa:ansible/ansible
```

Update the package index using the following command

```bash
sudo apt-get update
```

If you get the following error You are probably missing the python-software-properties package.

```bash
sudo: add-apt-repository: command not found
```

Install it using the following command.

```bash
sudo apt-get install python-software-properties
```


# Confirm your installation


You can test that Ansible is installed correctly by checking the version:

```bash
ansible --version
```
# What is Ansible ?

Ansible is an open-source automation tool that allows you to automate various tasks, configurations, and deployments in a simple and efficient manner. It is designed to simplify complex IT infrastructure management and can be used for tasks such as application deployment, configuration management, orchestration, and provisioning.

At its core, Ansible uses a declarative language called YAML (YAML Ain’t Markup Language) to describe the desired state of the systems being managed. You define the desired configuration or tasks in simple, human-readable YAML files called “playbooks.” Playbooks contain a series of instructions, known as “tasks,” that Ansible executes on the target systems.

Ansible works by connecting to remote systems over SSH (Secure Shell) or other remote management protocols. It does not require any agents or additional software to be installed on the target systems, making it easy to get started with and maintain.

Some key features and benefits of Ansible include:

1-Simple and human-readable syntax: Ansible uses YAML syntax, which is easy to read and write, making it accessible to both developers and system administrators.
2-Agentless architecture: Ansible communicates with remote systems using SSH or other protocols, eliminating the need for installing agents or daemons on the target systems.
3-Idempotent nature: Ansible ensures that the desired state of the system is achieved regardless of the system’s current state. It only makes necessary changes, which makes it safe to run playbooks multiple times.
4-Extensibility and flexibility: Ansible has a large number of modules that provide the ability to manage a wide range of systems and services. You can also write your own modules to extend its functionality.
5-Orchestration and automation: Ansible allows you to define complex workflows and orchestrate multiple systems simultaneously, making it suitable for automating tasks across large-scale infrastructures.
6-Integration with existing tools and systems: Ansible can integrate with various external tools, such as version control systems (e.g., Git), cloud platforms (e.g., AWS, Azure), and configuration management databases (e.g., Ansible Tower), allowing you to incorporate it into your existing workflows.
7-Ansible is widely adopted and used in various industries and organizations for managing infrastructure, automating deployments, and improving operational efficiency.

# Inventory file and Building an inventory

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

## Ansible Configuration File

With a fresh installation of Ansible, like every other software, it ships with a default configuration file. This is the brain and the heart of Ansible, the file that governs the behavior of all interactions performed by the control node. In Ansible’s case that default configuration file is (ansible.cfg) located in /etc/ansible/ansible.cfg.

The default Ansible configuration file is very large and divided into ten different sections. Each section denoted within the square brackets gives you an idea about this massive configuration file.

Ansible is so flexible, and it chooses its configuration file from one of several possible locations on the control node. One use case where this might be useful would be managing a web server and a database server. You might need to gather facts from one host and not on the other one. Having an ansible.cfg in the current project working directory can facilitate this behavior. If we’re going to be working with multiple configuration files, it is important to understand the order of precedence on how it chooses its configuration file; we’ll go through them below.

By default Ansible reads its configuration file in /etc/ansible/ansible.cfg , however this behavior can be altered. The recommended practice is either to have an ansible.cfg in your current project working directory or to set it as an environment variable. One way to determine which configuration file ansible is using is to use the $ansible --version command, you can also run your ansible commands with the -v option.
When it comes to the order of precedence, the ANSIBLE_CONFIG  environment variable has the highest precedence. If this environment variable is in your current shell, it will override all other configuration files. Here is one reason you might want to use the environment variable: let’s say you have multiple projects and you want all of them to use one specific configuration file, besides the default one located in /etc/ansible. Setting the environment variable would be a good way to solve this problem. 

The second priority is  ansible.cfg in your current working directory. if Ansible doesn’t find a configuration file in the current working directory, it will then look in for an .ansible.cfg file in the user’s home directory, if there isn’t one there either, it will finally grab the /etc/ansible/ansible.cfg.

Use the ansible-config utility to view, list, or dump the various different settings available for Ansible. Running the $ansible-config view utility will print in your standard output your current ansible.cfg content, as you can see, this below outcome is the exact same as the earlier $cat ansible.cfg command

sample of ansible.cfg

```bash
# Location of inventory file
inventory      = /path/to/your/inventory

# Default user to use for playbooks if not specified
remote_user    = your_remote_user

# Path to private key file for authentication
private_key_file = /path/to/your/private_key.pem

# Disable host key checking (not recommended for production)
host_key_checking = False

#Ansible may issue deprecation warnings when you use certain features that are slated for removal in future versions. Setting this parameter to False suppresses these deprecation warnings. Be cautious when using this option, as it might hide important information about upcoming changes in Ansible.
deprecation_warnings=False

#This parameter sets the Python interpreter discovery mode. When set to auto_silent, Ansible will automatically discover the Python interpreter on the target hosts, and if not found, it will silently proceed. This can be useful in environments where Python may be installed in non-standard locations
interpreter_python=auto_silent
```

# Ansible Playbooks

Ansible Playbooks offer a repeatable, reusable, simple configuration management and multi-machine deployment system, one that is well suited to deploying complex applications. If you need to execute a task with Ansible more than once, write a playbook and put it under source control.

Playbooks can:

- declare configurations

- orchestrate steps of any manual ordered process, on multiple sets of machines, in a defined order

- launch tasks synchronously or asynchronously

### Playbook syntax

Playbooks are expressed in YAML format with a minimum of syntax.A playbook is composed of one or more ‘plays’ in an ordered list. The terms ‘playbook’ and ‘play’ are sports analogies. Each play executes part of the overall goal of the playbook, running one or more tasks. Each task calls an Ansible module.A playbook runs in order from top to bottom. Within each play, tasks also run in order from top to bottom. Playbooks with multiple ‘plays’ can orchestrate multi-machine deployments, running one play on your webservers, then another play on your database servers, then a third play on your network infrastructure, and so on

```bash
---
- name: Update web servers 
  hosts: webservers
  remote_user: root

  tasks:
  - name: Ensure apache is at the latest version
    ansible.builtin.yum:
      name: httpd
      state: latest

  - name: Write the apache config file
    ansible.builtin.template:
      src: /srv/httpd.j2
      dest: /etc/httpd.conf

- name: Update db servers
  hosts: databases
  remote_user: root

  tasks:
  - name: Ensure postgresql is at the latest version
    ansible.builtin.yum:
      name: postgresql
      state: latest

  - name: Ensure that postgresql is started
    ansible.builtin.service:
      name: postgresql
      state: started
```
This Ansible playbook updates web servers by ensuring the Apache package is at the latest version and configuring Apache with a template. It also updates database servers by ensuring the PostgreSQL package is at the latest version and starting the PostgreSQL service. Each play is defined by a set of tasks to be executed on the specified hosts

By default, Ansible executes each task in order, one at a time, against all machines matched by the host pattern. Each task executes a module with specific arguments. When a task has executed on all target machines, Ansible moves on to the next task. You can use strategies to change this default behavior. Within each play, Ansible applies the same task directives to all hosts. If a task fails on a host, Ansible takes that host out of the rotation for the rest of the playbook.

When you run a playbook, Ansible returns information about connections, the name lines of all your plays and tasks, whether each task has succeeded or failed on each machine, and whether each task has made a change on each machine. At the bottom of the playbook execution, Ansible provides a summary of the nodes that were targeted and how they performed. General failures and fatal “unreachable” communication attempts are kept separate in the counts.

# Desired state and idempotency

Most Ansible modules check whether the desired final state has already been achieved, and exit without performing any actions if that state has been achieved, so that repeating the task does not change the final state. Modules that behave this way are often called ‘idempotent.’ Whether you run a playbook once, or multiple times, the outcome should be the same. However, not all playbooks and not all modules behave this way. If you are unsure, test your playbooks in a sandbox environment before running them multiple times in production.

### Ansible Roles

Ansible Roles provide a well-defined framework and structure for setting your tasks, variables, handlers, metadata, templates, and other files. They enable us to reuse and share our Ansible code efficiently. This way, we can reference and call them in our playbooks with just a few lines of code while we can reuse the same roles over many projects without the need to duplicate our code.

# Why Roles Are Useful in Ansible

When starting with Ansible, it’s pretty common to focus on writing playbooks to automate repeating tasks quickly. As new users automate more and more tasks with playbooks and their Ansible skills mature, they reach a point where using just Ansible playbooks is limiting
Since we have our code grouped and structured according to the Ansible standards, it is quite straightforward to share it with others. We will see an example of how we can accomplish that later with Ansible Galaxy.
Organizing our Ansible content into roles provides us with a structure that is more manageable than just using playbooks. This might not be evident in minimal projects but as the number of playbooks grows, so does the complexity of our projects.

## Ansible Role Structure
Ansible checks for main.yml files, possible variations, and relevant content in each subdirectory. It’s possible to include additional YAML files in some directories. For instance, you can group your tasks in separate YAML files according to some characteristic
my_role/
|-- defaults/
|   |-- main.yml
|-- files/
|-- handlers/
|   |-- main.yml
|-- meta/
|   |-- main.yml
|-- tasks/
|   |-- main.yml
|-- templates/
|-- tests/
|-- vars/
|   |-- main.yml
|-- README.md

- defaults:Includes default values for variables of the role. Here we define some sane default variables, but they have the lowest priority and are usually overridden by other methods to customize the role.
- files:Contains static and custom files that the role uses to perform various tasks.
- handlers: A set of handlers that are triggered by tasks of the role. 
- meta:Includes metadata information for the role, its dependencies, the author, license, available platform, etc.
- tasks: A list of tasks to be executed by the role. This part could be considered similar to the task section of a playbook.
- templates:Contains Jinja2 template files used by tasks of the role. (Read more about how to create an Ansible template.)
- tests: Includes configuration files related to role testing.
- vars: Contains variables defined for the role. These have quite a high precedence in Ansible.

# Sharing Roles with Ansible Galaxy

Ansible Galaxy is an online open-source, public repository of Ansible content. There, we can search, download and use any shared roles and leverage the power of its community. We have already used its client, ansible-galaxy, which comes bundled with Ansible and provides a framework for creating well-structured roles.You can use Ansible Galaxy to browse for roles that fit your use case and save time by using them instead of writing everything from scratch. For each role, you can see its code repository, documentation, and even a rating from other users. Before running any role, check its code repository to ensure it’s safe and does what you expect.

To download and install a role from Galaxy, use the ansible-galaxy install command. You can usually find the installation command necessary for the role on Galaxy