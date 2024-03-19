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