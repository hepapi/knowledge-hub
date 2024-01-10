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