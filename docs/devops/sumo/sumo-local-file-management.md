## Local Configuration File Management

With local configuration file management, you can configure Sources for an Installed Collector in one or more UTF-8 encoded JSON files.

**IMPORTANT NOTE:** After you switch over to local configuration file management, you can no longer manage Sources through the Sumo web application or the Collector Management API.

Local configuration file management is available on Collector version v19.108 and later.

**Benefits of local configuration file management**

* **You don't need to log in to the Sumo web app or use API calls.** Instead, you edit the JSON configuration file(s), and they are read almost immediately by the Collector.
* **If you have a large scale deployment, it can be impractical to add or edit Sources one at a time.** Using local configuration management allows you to manage Sources more easily.
* **You can use deployment tools so that established policies for deployments are not interrupted.**

## Options for specifying Sources in local configuration file(s)

There are two ways to implement local configuration file management:

1. **Specify all Sources in a single UTF-8 encoded JSON file.**
2. **Use multiple UTF-8 encoded JSON files to specify your Sources, and put all of those files in a single folder.**

**Note:** Each JSON file must have a `.json` extension.

### Define multiple Sources in a JSON file

When you define multiple Sources in a JSON file, you can define each Source in a `sources` JSON array. For example:

```json
{
  "api.version": "v1",
  "sources": [
    {
      "sourceType": "LocalFile",
      "name": "Example1",
      "pathExpression": "/path/to/log"
    },
    {
      "sourceType": "RemoteFile",
      "name": "Example2",
      "pathExpression": "/path/to/log"
    }
  ]
}
```

To define a single source in a JSON file, you just have one source definition under the `sources` array.
```json
{
  "api.version": "v1",
  "sources": [
    {
      "sourceType": "DockerLogs",
      "name": "Example1",
      "pathExpression": "/path/to/log"
    }
  ]
}
```

## Configure the location of JSON file or folder

When using local file configuration management, you specify the location of the JSON file or the folder that contains multiple JSON files in the Collector's `config/user.properties` file. You need to use the `syncSources` parameter to point to your configuration file or folder.

* **To point to a JSON file that defines Sources for a Collector:**

    `syncSources=/path/to/sources.json`

* **To point to a folder that contains JSON files that define Sources for a Collector:**
    `syncSources=/path/to/sources-folder`

* **On Windows (note the escaped backslashes):**
    `syncSources=C:\path\to\sources-folder\`

## Type of Sources

In our case, we are using the `"LocalFile"` type value for Local File Type.

**Note:** You should add the parameter `"sourceType":"LocalFile"` in the source file.

JSON Parameters for Installed Sources

| Parameter | Description |
|---|---|
| sourceType | The type of the data that the collector will collect. |
| description | Type a description of the Source. |
| category | Type a category of the source. |
| cutoffTimestamp | If you have a file that contains logs with timestamps spanning an entire week and set the cutoffTimestamp to two days ago, all of the logs from the entire week will be ingested since the file itself was modified more recent than the cutoffTimestamp |
| pathExpression | A valid path expression (full path) of the file to collect |
| denylist | Comma-separated list of valid path expressions from which logs will not be collected. |
| encoding | Defines the encoding form. Default is "UTF-8"; options include "UTF-16"; "UTF-16BE"; "UTF-16LE". |

## Important Tip: 
While giving the `pathExpression` use a single asterisk wildcard `[*]` for file or folder names. For example:

`pathExpression: "/var/foo/*.log"`

Use two asterisks `[**]` to recurse within directories and subdirectories. For example:

`pathExpression: "var/**/*.log"`

## Editing the configuration file

You can edit the JSON configuration file at any time to edit Source attributes or add new Sources. When you delete Sources from the file, they are deleted from the Collector.

To make the changes take effect, you need to restart the Collector.

**To restart the Collector, use these commands:**

* **Linux:** `sudo ./collector restart`

* **Windows:** `net restart sumo-collector`

## Full example of Local Source file :

```json
{
   "api.version":"v1",
   "sources":[
      {
         "name":"Hepapi-Test-Logs",
         "category":"DockerLogs",
         "automaticDateParsing":true,
         "multilineProcessingEnabled":false,
         "useAutolineMatching":false,
         "forceTimeZone":false,
         "timeZone":"UTC",
         "cutoffTimestamp":0,
         "encoding":"UTF-8",
         "pathExpression":"/var/lib/docker/containers/*/*-json.log",
         "sourceType":"LocalFile"
      } 
   ]
}
```
