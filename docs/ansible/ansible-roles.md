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