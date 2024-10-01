### What is Terragrunt?

Terragrunt is a popular open-source tool or ‘thin wrapper’ developed by Gruntwork, that helps manage Terraform configurations by providing additional features and simplifying workflow. It is often used to address common challenges in Terraform, such as keeping configurations DRY (Don’t Repeat Yourself), managing remote state, handling multiple environments, and executing custom code before or after running Terraform.

See [Terragrunt vs Terraform](https://spacelift.io/blog/terragrunt-vs-terraform) for further information.

### Terragrunt features

1. Remote state management
Terragrunt simplifies remote state management for Terraform projects. It can automatically configure and store state files remotely in services like Amazon S3, Google Cloud Storage, or any other backend supported by Terraform.

2. DRY (Don’t Repeat Yourself) configurations
Terragrunt promotes DRY principles by allowing you to define and reuse common configurations across multiple Terraform modules. This helps reduce duplication and makes configurations more maintainable.

3. Dependency management
Terragrunt supports dependency management between different Terraform modules and states, ensuring that dependent resources are deployed in the correct order.

4. Configuration inheritance
Terragrunt allows you to create modular configurations that can inherit parameters and settings from parent configurations, making it easier to manage and organize your infrastructure code.

5. Environment-specific configurations
Terragrunt supports the creation of environment-specific configurations (e.g., dev, staging, prod) using HCL (HashiCorp Configuration Language) interpolation, making it easier to maintain consistent environments.

6. Remote backend configurations
Terragrunt allows you to specify backend configurations (e.g., S3 bucket, DynamoDB table) for each environment, enabling a more dynamic and flexible approach to state storage.

7. Locking mechanism
Terragrunt provides a locking mechanism to prevent concurrent executions that could potentially cause conflicts when modifying shared infrastructure.

8. Secrets management
Terragrunt can integrate with external secrets management tools like AWS Secrets Manager or HashiCorp Vault to handle sensitive data securely.

9. Integration with CI/CD pipelines
Terragrunt can be integrated into continuous integration and continuous deployment (CI/CD) pipelines to automate infrastructure deployments.

10. Configurable hooks
Terragrunt supports pre- and post-terraform hooks, allowing you to run custom scripts or commands before or after running Terraform commands.

### How does Terragrunt work?

Terragrunt relies on a configuration file called `terragrunt.hcl`. This file is placed in the root directory of your Terraform project or in the directories of specific modules. It contains settings and parameters that customize Terragrunt’s behavior for your project or module.

### How to install Terragrunt?

**STEP 1:** Install Terraform
As Terragrunt is a wrapper around Terraform, you’ll need to have [Terraform installed](https://spacelift.io/blog/how-to-install-terraform) first. You can download the appropriate version of Terraform for your operating system [here](https://developer.hashicorp.com/terraform/install).

**STEP 2:** Extract the binary and place it in a directory included in your system’s PATH
After downloading Terraform, extract the binary and place it in a directory included in your system’s `PATH`.
The PATH tells a system where it should look for executables, making them accessible via command-line interfaces or scripts.
To add a new folder to PATH in Windows, navigate to Advanced System Settings > Environment Variables, select PATH, click “Edit” and then “New.”

**STEP 3:** Download Terragrunt
Next, head over to the [Terragrunt GitHub](https://github.com/gruntwork-io/terragrunt/releases) page to download it.

**STEP 4:** Place the Terragrunt binary in a directory included in your system’s PATH
Once you have downloaded the Terragrunt binary, place it in a directory included in your system’s `PATH`. You may also rename the binary to simply `terragrunt` (without the platform-specific suffix) for convenience.

**STEP 5:** Verify the installation
Lastly, verify the installation by running `terragrunt --version` on your console command line. It should show the currently installed version.

```bash
terragrunt --version
```

### Terragrunt basic commands

Terragrunt command should be run from the project directory that contains your `terragrunt.hcl` configuration file. Terragrunt has many of the same commands available you will be familiar with the Terraform workflow, (you just need to replace `terraform` with `terragrunt`).

These include:

- terragrunt init
- terragrunt validate
- terragrunt plan
- terragrunt apply
- terragrunt destroy
- terragrunt graph
- terragrunt state
- terragrunt version
- terragrunt output

Also, check out this [Terraform cheat sheet](https://spacelift.io/blog/terraform-commands-cheat-sheet).

### How to set up Terragrunt configurations?

First, create your `terragrunt.hcl` file in the directory you want to use Terragrunt in. The `terragrunt.hcl` file consists of configuration blocks that define various settings for Terragrunt.

Note that the Terragrunt configuration file uses the same HCL syntax as Terraform itself in `terragrunt.hcl`. Terragrunt also supports JSON-serialized HCL in a `terragrunt.hcl.json` file: where `terragrunt.hcl` is mentioned, you can always use `terragrunt.hcl.json` instead.

The `terraform` block is used to configure how Terragrunt will interact with Terraform. You can configure things like before and after hooks for indicating custom commands to run before and after each terraform call or what CLI args to pass in for each command.

The source attribute specifies where to find [Terraform configuration](https://spacelift.io/blog/terraform-files) files and uses the same syntax as the Terraform module source attribute.

For example, you can pull modules directly from a Github repo:

```hcl
terraform { 
  source = "git::git@github.com:acme/infrastructure-modules.git//networking/vpc?ref=v0.0.1"
}
```

Or modules from the local file system (Terragrunt will make a copy of the source folder in the Terragrunt working directory, typically '.terragrunt-cache'):

```hcl
terraform {  
  source = "../modules/networking/vpc"
}
```

Other blocks you can configure in your `terraform.hcl` file include:

- [remote_state](https://terragrunt.gruntwork.io/docs/reference/config-blocks-and-attributes/#remote_state)
- [include](https://terragrunt.gruntwork.io/docs/reference/config-blocks-and-attributes/#include)
- [locals](https://terragrunt.gruntwork.io/docs/reference/config-blocks-and-attributes/#locals)
- [dependency](https://terragrunt.gruntwork.io/docs/reference/config-blocks-and-attributes/#dependency)
- [dependencies](https://terragrunt.gruntwork.io/docs/reference/config-blocks-and-attributes/#dependencies)
- [generate](https://terragrunt.gruntwork.io/docs/reference/config-blocks-and-attributes/#generate)

### Example

#### STEP 0

You will need `dev` and `prod` accounts. You can create them using your main account. Then, you should create an IAM user account for logging in
multiple accounts, namely SSO. In our example, our account is the "Management Account" which controls the other accounts. Similarly, `dev` and `prod` accounts are the "Environment Accounts" on which the resources are created. The IAM user account should be able to login to all account using "Access Portal".

Before starting, make sure that AWS CLI is installed and configured on your desktop. If not, refer to [download page of AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html). After successful download, configure the CLI with IAM credentials of "Management Account".

```bash
aws configure
```

You will be prompted to enter your AWS Access Key ID, AWS Secret Access Key, default region name and default output format (e.g., json). Now, you are
ready to proceed. Below, you can see the folder structure of the example: 

```bash

modules/
└── vpc/
    ├── main.tf
    ├── versions.tf
    ├── variables.tf
    └── outputs.tf

environments/
├── dev/
│   ├── us-east-1/
│   │   ├── vpc/
│   │   │   └── terragrunt.hcl   # VPC module configuration for dev/us-east-1
│   │   └── region.hcl           # Region-specific configuration for dev/us-east-1
│   ├── us-west-2/
│   │   ├── vpc/
│   │   │   └── terragrunt.hcl   # VPC module configuration for dev/us-west-2
│   │   └── region.hcl           # Region-specific configuration for dev/us-west-2
│   └── env.hcl                  # General environment configuration for dev
├── prod/
│   ├── us-east-1/
│   │   ├── vpc/
│   │   │   └── terragrunt.hcl   # VPC module configuration for prod/us-east-1
│   │   └── region.hcl           # Region-specific configuration for prod/us-east-1
│   ├── us-west-2/
│   │   ├── vpc/
│   │   │   └── terragrunt.hcl   # VPC module configuration for prod/us-west-2
│   │   └── region.hcl           # Region-specific configuration for prod/us-west-2
│   └── env.hcl                  # General environment configuration for prod
└── terragrunt.hcl               # Top-level configuration linking all environments

initial_configs/                  
├── AWSTerraformInitialConfigs_Management.yaml
└── AWSTerraformInitialConfigs_Environment.yaml

```

As you can see, there is a `vpc` module under `modules` folder. Refer to [vpc module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest) page to get the module. Then, change the static values as variables and define the variables in `variables.tf`. Also, you can add `outputs.tf` to check if the module is successfully created. Note that there is no `.tfvars` file and we will see handle this issue in the next steps.

#### STEP 1

Let's analyze the files under `initial_configs` folder. Starting with `AWSTerraformInitialConfigs_Management.yaml`, this CloudFormation template defines resources and configurations necessary for managing Terraform state using AWS S3 and DynamoDB, and it provisions an IAM user with the required permissions. 

**PARAMETERS:**

- **Serial:** A value used to notify CloudFormation to rotate access keys.
- **IaCUserName:** The IAM user name (default: terraform).
- **TerraformStateBucketPrefix:** Prefix for the S3 bucket storing Terraform state.
- **TerraformStateLockTableName:** Name of the DynamoDB table for state locking.

**RESOURCES:**

- **IaCUser (IAM User):**
Creates an IAM user with tags indicating its provision through CloudFormation and its usage for management purposes.

- **IaCUserPolicy (IAM Policy):**
Grants the IAM user permissions to:
Manage the Terraform S3 bucket (create, access, and configure it).
Lock Terraform state via DynamoDB (create, read, update, and delete items).
Assume the TerraformExecutionRole for executing tasks.

- **IaCUserAccessKey & IaCUserSecret (IAM Access Keys & Secret):**
Creates and stores the access keys in AWS Secrets Manager for secure access.

- **TerraformStateS3Bucket (S3 Bucket):**
Creates an S3 bucket to store Terraform state files. It enforces security policies like blocking public access and enabling versioning.

- **TerraformStateS3BucketBucketPolicy (S3 Bucket Policy):**
Adds a policy to the S3 bucket that denies the deletion of Terraform state files.

- **TerraformStateLockDynamoDBTable (DynamoDB Table):**
Creates a DynamoDB table (LockID as the key) for Terraform state locking to prevent concurrent modifications of the state.

**NOTE:** You should create a stack in CloudFormation and upload this file on the "Management Account". Now, let's proceed with the `AWSTerraformInitialConfigs_Environment.yaml` file. 

**PARAMETERS:**

- **IaCUserARN:** A string parameter representing the ARN of the IAM user responsible for running Terraform. This user will be allowed to assume the role defined in the template. By default, this value needs to be provided (though a placeholder "ARN of the IaC User" is set).

**RESOURCES:**

- **TerraformExecutionRole (IAM Role):**
The TerraformExecutionRole is an IAM role that grants specific AWS permissions for Terraform operations, allowing a specified IAM user (via IaCUserARN) to assume it for a maximum of 4 hours. It is associated with the AdministratorAccess policy, providing full administrative privileges, and includes tags for tracking its provisioning through CloudFormation.

**NOTE:** Look at the "IaCUserARN" from the "Management Account" and assign this value to the "Parameters" section of the `AWSTerraformInitialConfigs_Environment.yaml` file. You should create a stack in CloudFormation and upload this file on the "Environment Accounts".

#### STEP 2

Now, we are ready to analyze the `environments` folder. There is a top-level `terragrunt.hcl` under the folder which includes important configurations.
This Terragrunt configuration file sets up local variables and configurations for managing Terraform modules and remote state.

**Local Variables:**
- **base_source_url:** Points to the local module source directory.
- **environment_vars and region_vars:** Load environment-specific and region-specific variables from env.hcl and region.hcl files, respectively.
- **target_account, target_region, remote_state_account, and remote_state_bucket:** Define the AWS account and region for the remote state and specify the bucket for storing Terraform state files.

**AWS Provider Configuration:**
Generates an aws provider block, setting the region for both the remote state and the target account, with an assume role for accessing the target account's resources.

**Remote State Configuration:**
Configures Terraform to use an S3 bucket for remote state storage, with encryption enabled and a DynamoDB table for state locking.

**Global Parameters:**
Merges global inputs from env.hcl and region.hcl, allowing all resources to inherit these configurations, which is useful for multi-account setups.

Let's move with the environment folders. The structure is similar in both of the environments, so it will be enough to analyze one of them. Under the environments, there are regions in which the resources are created. Also, there is a `env.hcl` which includes local variables. The variables in the `env.hcl` are important because they determine the account. Diving into one of the regions, you can see the `region.hcl` which specifies the region. In the same
directory, you can see the folders of the modules, which is `vpc` in our example. Under the `vpc` folder, there is a `terragrunt.hcl` file. This Terragrunt configuration file includes the root `terragrunt.hcl` configuration, which contains common settings for remote state management across all components and environments.

**Include Block:**
The configuration references the root settings using the include directive, allowing access to shared configurations and exposing them for use in the current module.

**Local Variables:**
It defines base_source_url from the root configuration, along with the module_name as "vpc" and module_version as "v0.0.1."

**Terraform Source:**
The source for the Terraform module is set based on the base source URL, module name, and version.

**Inputs:**
Specifies the input variables for the VPC module, including availability zones, VPC CIDR block, NAT and VPN gateway settings, subnet configurations, and tags for environment identification.

**NOTE:** Don't forget to change the necessary values of variables in this folder. For example, the value of "aws_account_id" in the `env.hcl`. Similarly, you
should check the values in the both top and root level `terragrunt.hcl` files.

#### STEP 3

After compliting the necessary adjustments in the files and on the AWS console, you are ready to create the resources. You can open the folder with VSCode and using the terminal, proceed to the `vpc` folders in which the root level `terragrunt.hcl` is located. Finally, enter the following command to create VPC in desired region.

```bash
terragrunt apply
```

If you want to delete the resources, you should proceed to directory of related root level `terragrunt.hcl` file and enter the following command.

```bash
terragrunt destroy
```

For example, if you want to create a `dev-vpc` in `the us-east-1` region, go to `~/environments/dev/us-east-1/vpc` using the terminal and enter `terragrunt apply` command. Similarly, you can delete this using `terragrunt destroy`. Note that the `.tfstate` files are stored in S3 and they are locked in DynamoDB.

The advantage of this configuration is that you can control various resources in different regions. In our example, we show this by creating a VPC  in two different regions. We created and configured multiple VPCs in different accounts and regions by only making minor changes in the structure. The same can be
done using Terraform, but if the number of resources and regions increase, it would be faster and more practical to create with Terragrunt. Furthermore, you can control all of them from one point, namely "Management Account".

### Terragrunt benefits

Where Terraform allows you the freedom to structure your code in multiple ways, Terragrunt places restraints on how you can organize your Terraform code and forces you to use directory structure hierarchies and shared variable definition files to organize your code. These restraints force your code to be more consistent and make it harder to make mistakes. The trade-off is that the amount of flexibility you have is reduced.

The key to using Terragrunt effectively is to carefully plan your directory structure in order to keep your code base DRY. Organizing your infrastructure code into reusable modules that represent logical components of your infrastructure is one way to achieve this. 

### Key points

Terragrunt is a powerful tool that helps you manage Terraform configurations more efficiently. To make the most out of Terragrunt and maintain a clean, scalable, and organized infrastructure codebase, be sure to follow the best practices and plan your folder structure and use of Terragrunt carefully.

### References

[Terragrunt Tutorial – Getting Started & Examples](https://spacelift.io/blog/terragrunt#how-to-set-up-terragrunt-configurations)
