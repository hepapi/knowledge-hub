# SCP Command
SCP (secure copy) is a command-line utility that allows you to securely copy files and directories between two locations.


**From your local system to a remote system.**
```bash
scp -i "pam.pem" /home/kullanici/dizin/local_file.txt ubuntu@18.204.206.157:/home/ubuntu/
```
**From a remote system to your local system.**
```bash
scp -i "pam.pem" -r ubuntu@3.86.225.192:/home/ubuntu/  .
```

>Attention 
**pam.pem is the password file of Ec2 instance**

``scp`` provides a number of options that control every aspect of its behavior. The most widely used options are:

``-P`` - Specifies the remote host ssh port.

``-p`` - Preserves files modification and access times.

``-q`` - Use this option if you want to suppress the progress meter and non-error messages.

``-C`` - This option forces scp to compresses the data as it is sent to the destination machine.

``-r`` - This option tells scp to copy directories recursively.

