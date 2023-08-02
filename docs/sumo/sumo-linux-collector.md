# Install a Sumo Logic Collector on Linux

### Download a Sumo Logic Collector from a Static URL

Invoke a web request utility such as wget. For Linux 64-bit host, you can wget the Collector from the command line:

```bash
wget "https://collectors.sumologic.com/rest/download/linux/64" -O SumoCollector.sh && chmod +x SumoCollector.sh
```

For other hosts choose the related one above:

| Platform | Download URL |
|---|---|
| Linux 64 | https://collectors.au.sumologic.com/rest/download/linux/64 |
| Linux Debian | https://collectors.au.sumologic.com/rest/download/deb/64 |
| Linux RPM | https://collectors.au.sumologic.com/rest/download/rpm/64 |
| Tarball | https://collectors.au.sumologic.com/rest/download/tar |
| Windows 32 | https://collectors.au.sumologic.com/rest/download/windows |
| Windows 64 | https://collectors.au.sumologic.com/rest/download/win64 |

<span style="color: red;">Important Note:</span>
The latest release of the Sumo Collector targets the Java 8 runtime. Java 6 and Java 7 are no longer supported as the Collector runtime, and Solaris is no longer supported. When you upgrade Collectors, JRE 8 or later is required. The Sumo Collector with a bundled JRE now ships with JRE 8.

### System Requirements

The Sumo Logic Collector has the following system requirements:

* **Operating System:** Linux, major distributions 64-bit, or any generic Unix capable of running Java 1.8
* **CPU:** Single core
* **RAM:** 512MB
* **Disk Space:** 8GB
* **TLS:** Package installers require TLS 1.2 or higher

### Install using the command line installer

1. Add execution permissions to the downloaded Collector file (.sh):

```bash
chmod +x SumoCollector.sh
```
2. Run the script with the parameters that you want to configure 
   ##### Examples
   ###### 1) Using an Installation Token

    ```bash
    sudo ./SumoCollector.sh -q -Vsumo.token_and_url=<installationToken> -Vsources=<absolute_filepath>
    ```
By default, the Collector will be installed in either `/opt/SumoCollector` or `/usr/local/SumoCollector`.

### Other parameters for the command line installer

The command line installer also supports a number of other parameters, including:

* **-dir [directory]** : Sets a different installation directory than the default.
* **-Vsumo.accessid=[accessId]** : The access ID is part of the authentication credentials for your Sumo Logic account.
* **-Vsumo.accesskey=[accessKey]** : The access key is part of the authentication credentials for your Sumo Logic account.
* **-Vsumo.token_and_url=[token]** : The token can be either an Installation Token or Setup Wizard Token.

The command line installer can also use all of the parameters available in the user.properties file. To use parameters from user.properties just add a `-V` to the beginning of the parameter without a space character.

The following parameters have a different format in the command line installer:

| user.properties | cli |
|---|---|
| name | `-Vcollector.name` |
| url | `-Vcollector.url` |
| proxyHost | `-Vproxy.host` |
| proxyPort | `-Vproxy.port` |
| proxyUser | `-Vproxy.user` |
| proxyPassword | `-Vproxy.password` |

### Other user.properties parameters

The user.properties file can also be used to configure the following parameters:

* **-Vdescription** : Description of the collector
* **-VhostName** : Name of the host machine that the collector is installed
* **-Vsources** : The contents of the file or files are read upon Collector registration only, it is not synchronized with the Collector's configuration on an on-going basis.
* **-VsyncSources** : The Source definitions will be continuously monitored and synchronized with the Collector's configuration.

### Start or Stop a Collector using Scripts

To start, stop, check the status of the Collector or restart it, run one of the following commands from the Collector installation directory:
```bash
sudo ./collector start
```
```bash
sudo ./collector stop
```
```bash
sudo ./collector status
```
```bash
sudo ./collector restart
```
### Uninstall using the command line

1. In a terminal prompt, change the directory to the collector installation directory:


2. Run the uninstall binary with the `-q` option. The `-q` option executes the command without presenting additional prompts:

    ```bash
    sudo ./uninstall -q
    ```
