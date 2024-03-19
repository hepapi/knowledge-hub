# Azure Self-Hosted Agent Installation

## Creating a Personal Access Token

1. Log into Azure DevOps.
1. Under User settings select `Personal access tokens`
1. Click `New Token`
1. Fill the `Name` and `Expiration` fields.
1. In scope select `Custom defined`, then click `Show all scopes` and tick `Read & manage `under `Agent Pools`
1. Click `Create` and make sure to securely store the token because it will not be accessible later.

## Installing and configuring the agent

1.  - If you want the agent to be usable by different projects in your organization go to `Organization Settings` on your Azure Devops Organization page.
    - If you want the agent to be exclusive to a specific project, go to `Project Settings` on the Azure Devops Project page.

1. Select `Agent pools` under the `Pipelines` section on the left
1. Select an existing `Agent Pool` or create a new one.
1. After you've selected an `Agent Pool`, click `New Agent`
    - Linux: 
        - Select `Linux`
        - Press the Copy button next to the Download button to copy the URL.

### Linux

In the Linux machine:

1. Create a user for the Azure Agent:
    ```bash
    sudo adduser azureagent
    ```
1. Add the user to sudoers:
    ```bash
    sudo usermod -aG sudo azureagent
    ```
1. If needed add the user to other necessary groups like `docker`:
    ```bash
    sudo usermod -aG docker azureagent
    ```
1. Create any necessary working directories and grant ownership to the user:
    ```bash
    sudo chown -R azureagent:azureagent /home/app/foo
    ```
1. Switch to the azureagent user and navigate to the `/home/azureagent` directory:
    ```bash
    su - azureagent
    cd /home/azureagent
    ```
1. Download the agent using the URL we copied earlier:
    ```bash
    wget https://vstsagentpackage.azureedge.net/agent/3.220.2/vsts-agent-linux-x64-3.220.2.tar.gz
    ```
1. Create a new directory for the agent and extract the tar.gz inside and confirm with ls:
    ```bash
    mkdir agent
    cd agent
    tar zxf ../vsts-agent-linux-x64-3.220.2.tar.gz
    ls
    ```
1. Run the config script to start the agent configuration:
    ```bash
    ./config.sh
    ```
1. Provide the info requested by the script
    - Enter your Azure Devops server URL:
        ```
        https://dev.azure.com/orgname
        ```
    - Press Enter to continue using PAT then paste the PAT we created earlier.
    - Enter the agent pool name and a name for the agent we're creating.
    - Press enter to use the default work folder (`_work`)

1. Configure the agent to run as a service:
    ```bash
    sudo ./svc.sh install azureagent
    sudo ./svc.sh start
    ```

1. Navigate to the `Agent pools` page on Azure Devops and select the relevant `Agent Pool`, then click on the `Agents` tab to verify that our new `Agent` is added as a self-hosted agent.