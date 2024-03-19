# Netstat & SS Command

You can check the listening ports and applications with netstat as follows.

> **Prerequisite**
By default, netstat command may not be installed on your system. Hence, use the apk command on Alpine Linux, dnf command/yum command on RHEL & co, apt command/apt-get command on Debian, Ubuntu & co, zypper command on SUSE/OpenSUSE, pacman command on Arch Linux to install the netstat.

```bash
sudo apt update
sudo apt install net-tools
```

Run the netstat command along with grep command to filter out port in LISTEN state:

```bash
netstat -tulpn | grep LISTEN
netstat -tulpn | more
```

**Where netstat command options are:**

``-t`` : Select all TCP ports

``-u`` : Select all UDP ports

``-l`` : Show listening server sockets (open TCP and UDP ports in listing state)

``-p`` : Display PID/Program name for sockets. In other words, this option tells who opened the TCP or UDP port. For example, on my system, Nginx opened TCP port 80/443, so I will /usr/sbin/nginx or its PID.

``-n`` : Don’t resolve name (avoid dns lookup, this speed up the netstat on busy Linux/Unix servers)

---

>The netstat command ``deprecated`` for some time on Linux. Therefore, you need to use the ss command as follows:

```bash
sudo ss -tulw
sudo ss -tulwn
sudo ss -tulwn | grep LISTEN
```

``-t`` : Show only TCP sockets on Linux

``-u`` : Display only UDP sockets on Linux

``-l`` : Show listening sockets. For example, TCP port 22 is opened by SSHD server.

``-p`` : List process name that opened sockets

``-n`` : Don’t resolve service names i.e. don’t use DNS

# PS Command

The ps command without any options displays information about processes that are bound by the controlling terminal.
```yaml
ps
```
The command returns a similar output:
```bash
PID TTY      TIME     CMD
285 pts/2    00:00:00 zsh
334 pts/2    00:00:00 ps
```

The default output of the ps command contains four columns that provide the following information:

``PID``: The process ID is your system’s tracking number for the process. The PID is useful when you need to use a command like kill or nice, which take a PID as their input.

``TTY``: The controlling terminal associated with the process. Processes that do not originate from a controlling terminal and were initiated by the system at boot are displayed with a question mark.

``TIME``: The CPU usage of the process. Displays the amount of CPU time used by the process. This value is not the run time of the process.

``CMD``: The name of the command or executable that is running. The output only includes the name of the command or executable and does not display any options that were passed in.

### The ``aux`` shortcut
Now that you understand the basics of the ``ps`` command, this section covers the benefits to the ``ps`` ``aux`` command. The ``ps`` ``aux`` displays the most amount of information a user usually needs to understand the current state of their system’s running processes. Take a look at the following example:
```bash
ps aux
```
```bash
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0    892   572 ?        Sl   Nov28   0:00 /init
root       227  0.0  0.0    900    80 ?        Ss   Nov28   0:00 /init
root       228  0.0  0.0    900    88 ?        S    Nov28   0:00 /init
zaphod     229  0.0  0.1 749596 31000 pts/0    Ssl+ Nov28   0:15 docker
root       240  0.0  0.0      0     0 ?        Z    Nov28   0:00 [init] <defunct>
root       247  0.0  0.0    900    88 ?        S    Nov28   0:00 /init
root       248  0.0  0.1 1758276 31408 pts/1   Ssl+ Nov28   0:10 /mnt/wsl/docker-desktop/docker-desktop-proxy
root       283  0.0  0.0    892    80 ?        Ss   Dec01   0:00 /init
root       284  0.0  0.0    892    80 ?        R    Dec01   0:00 /init
zaphod     285  0.0  0.0  11964  5764 pts/2    Ss   Dec01   0:00 -zsh
zaphod     343  0.0  0.0  23764  9836 pts/2    T    17:44   0:00 vi foo
root       349  0.0  0.0    892    80 ?        Ss   17:45   0:00 /init
root       350  0.0  0.0    892    80 ?        S    17:45   0:00 /init
zaphod     351  0.0  0.0  11964  5764 pts/3    Ss+  17:45   0:00 -zsh
zaphod     601  0.0  0.0  10612  3236 pts/2    R+   18:24   0:00 ps aux
```

The ``ps aux`` command displays more useful information than other similar options. For example, the ``UID`` column is replaced with a human-readable ``username`` column. ``ps aux`` also displays statistics about your Linux system, like the percent of CPU and memory that the process is using. The ``VSZ`` column displays amount of virtual memory being consumed by the process. ``RSS`` is the actual physical wired-in memory that is being used. The ``START`` column shows the date or time for when the process was started. This is different from the CPU time reported by the ``TIME`` column.