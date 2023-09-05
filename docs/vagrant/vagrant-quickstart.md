# Vagrant

## What is Vagrant?
CLI tool for managing the life-cycle of VMs

- Reproducible local dev environments  
- Vagrantfile, akin to Dockerfile for VMs

## Installation
See the [official Vagrant downloads page](https://developer.hashicorp.com/vagrant/downloads)  
Ubuntu/Debian:
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant
```

You also need VirtualBox, VMware or Hyper-V on your machine.

## Important Commands
Initialize a new Vagrant environment by creating a Vagrantfile:  
`vagrant init`  
Starts and provisions the Vagrant environment:  
`vagrant up`  
Connects to machine via ssh:  
`vagrant ssh`  
Outputs status of the machine:  
`vagrant status`  
Suspends the machine:  
`vagrant suspend`  
Stops the machine:  
`vagrant halt`  
Stops and deletes all traces of the machine:  
`vagrant destroy`  

## Boxes
Vagrant base images are called boxes.  
See the [official Vagrant boxes page](https://app.vagrantup.com/boxes/search)

## Synced Folders
By default, Vagrant will share your project directory (the directory with the Vagrantfile) to `/vagrant`.

## Vagrantfile
Example Vagrantfiles:
<details>
  <summary>Vagrantfile for Jenkins</summary>
  This Vagrantfile installs Jenkins, AWS CLI, unzip and zip tools.

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"

  # Port forwarding
  config.vm.network "forwarded_port", guest: 8080, host: 8080

  config.vm.provision "shell", inline: <<-SHELL
    # Update repositories
    sudo apt-get update

    # Install CA certificates (optional but recommended)
    sudo apt-get install -y ca-certificates

    # Install Java (a requirement for Jenkins)
    sudo apt-get install -y openjdk-11-jdk

    # Add Jenkins repository
    wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
    sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

    sudo apt-get update

    # Install Jenkins
    sudo apt-get install -y jenkins

    # Start Jenkins
    sudo systemctl start jenkins

    # Install necessary utilities
    sudo apt-get install -y unzip
    sudo apt-get install -y zip

    # Install AWS CLI version 2
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
  SHELL
end
```
</details>

<details>
  <summary>Vagrantfile using Ansible for provisioning</summary>
  This Vagrantfile uses an Ansible playbook for provisioning.

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/bionic64"
  config.vm.network :forwarded_port, guest: 80, host: 8080
  config.vm.network :forwarded_port, guest: 443, host: 8081
  config.vm.network :forwarded_port, guest: 8080, host: 8082
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "main.yml"
  end

end
```
</details>

<details>
  <summary>Vagrantfile with advanced networking</summary>
  This Vagrantfile brings up 2 VMs, assigns them static hostnames and IPs, allows root login and password authentication, and installs Ansible on one of the VMs.

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # Define VMs
  (1..2).each do |i|
    config.vm.define "vm#{i}" do |vmconfig|

      # Use CentOS 8
      vmconfig.vm.box = "generic/centos8"
      
      # Set hostname
      vmconfig.vm.hostname = "vm#{i}"

      # Set private network
      vmconfig.vm.network "private_network", ip: "192.168.56.1#{i}"
      
      # Sync project directory to /vagrant
      vmconfig.vm.synced_folder ".", "/vagrant", type: "virtualbox"
      
      # Enable provisioning with a shell script
      vmconfig.vm.provision "shell", inline: <<-SHELL
        echo 'vagrant:vagrant' | chpasswd
        sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
        sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
        systemctl restart sshd
      SHELL
      
      if i == 1
        vmconfig.vm.provision "shell", inline: <<-SHELL
          sudo yum update -y
          sudo yum install -y epel-release
          sudo yum install -y python3-pip gcc openssl-devel libffi-devel python3-devel
          sudo pip3 install --upgrade pip
          sudo pip3 install setuptools_rust
          pip3 install ansible
        SHELL
      end
    end
  end

  # Enable ssh agent forwarding
  config.ssh.forward_agent = true
  
end
```
</details>


