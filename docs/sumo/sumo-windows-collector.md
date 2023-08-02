# Install a Sumo Logic Collector on Windows
## System Requirements for Windows

* Windows 7, 32 or 64 bit
* Windows 8, 32 or 64 bit
* Windows 8.1, 32 or 64 bit
* Windows 10, 32 or 64 bit
* Windows 11, 32 or 64 bit
* Windows Server 2012
* Windows Server 2016
* Windows Server 2019
* Windows Server 2022
* Single core, 512MB RAM
* 8GB disk space
* Package installers require TLS 1.2 or higher.

## Download a Collector from a Static URL

1. Open a terminal window or command prompt.
2. If you're using PowerShell on a 64-bit Windows host, you can use Invoke-WebRequest:

#### Configure usage of TLS

```powershell
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Tls,Tls11,Tls12'
```

#### Download the installer
```powershell
Invoke-WebRequest 'https://collectors.sumologic.com/rest/download/win64' -outfile '<download_path>\SumoCollector.exe'
```

Replace the <download_path> with the location where you want to download the Collector. For example, `C:\user\example\path\to\SumoCollector.exe`

## Install the Sumo Logic Collector using the command line installer

From the command prompt, run the downloaded EXE file with the parameters that you want to configure. For example:

#### Using an Installation Token

```powershell
./SumoCollector.exe -console -q "-Vsumo.token_and_url=<installationToken>" "-Vsources=<filepath>"
```

Reminder: You can pass other `user.properties` parameters as well inside `""`.

When you see the `Finishing installation...` message, you can close the command prompt window. The installation is complete.

| Parameter | Description |
|---|---|
| `-console`| Only has an effect when used with `-q`. Causes the installer to send progress messages to the console. On Windows, for this option to take effect, you must run the installer with start /wait. For example: `start /wait installer.exe -q -console` |
|` -q` |  Causes the installer to run silently, which means you won't be prompted to supply installation parameters. For any installation parameter that you do not define at the command line, Sumo will use a default value. No output is sent to the console during installation, unless you also use the `-console` parameter. |

### Configuring Sources for Collectors

After installing Collectors, you can configure Sources directly in Sumo Logic or by providing the Source settings in a JSON file.

##### Using a JSON file

If you're using a UTF-8 encoded JSON file, you must provide the file before starting the Collector. The JSON file needs to be UTF-8 encoded.

**Important Note:**

In Windows Host by using double backslashes, the JSON parser will interpret each backslash as a literal character rather than an escape character. For example:

* Backslashes are **<span style="color:red">NOT</span>** treated correctly:
 `"-Vsources=<C:\some\path\to\SumoCollector.exe>"` or `"pathExpression":"<C:\path\to\source.json>"`
* Backslashes **<span style="color:green">ARE </span>** treated correctly: 
  `"-Vsources=<C:\\some\\path\\to\\SumoCollector.exe>"` or `"pathExpression":"<C:\\path\\to\\source.json>"`

### Uninstalling from the command line

From the command prompt, run the `uninstall.exe` file with the `-q` option. The `-q` option executes the command without presenting additional prompts.

```powershell
./uninstall.exe -q -console
```
