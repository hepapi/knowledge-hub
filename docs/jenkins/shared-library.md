# Jenkins Shared Library :fire:

Hello everybody from Hepapi.We will talk about Jenkins Shared Library.Lets start. We are in a period where modern applications are generally divided into small components and run on a microservice architecture. Compared to a monolithic application, there are many extra pipelines in an application with microservice architecture. Therefore, it is very important to ensure modularity and reusability of the created pipelines. Thanks to Jenkins Shared Library, we can get rid of the code complexity in the pipeline and comply with the DRY (Don't Repeat Yourself) principle.

Example: You can perform the docker build process that you perform jointly for more than one service by simply sending the docker image information to a single function for all services.

```bash
// var/dockerBuild.groovy
#!/usr/bin/env groovy
def call(String REPOSITORY) {
  String REGISTRY = "ersinsari"
  sh "docker build -t ${REGISTRY}/${REPOSITORY}:latest ."
}
// Jenkinsfile
@Library('mylibrary') _
pipeline {
  stages {
    stage('Docker Build') {
      dockerBuild "nodejs-helloworld"    
    }
  }
}
```

## Folder Structure of Shared Library

```
└── jenkins-shared
    ├── src
    │   ├── main
    │       └── groovy
    |           └── *.groovy
    ├── vars           
    |   ├── *.groovy
    └── resources
        ├── config.properties
        └── template.xml
```

- The src directory is structured like a standard Java project. This means that you can use the import statement to import classes from other directories in the src directory.

- The vars directory is a special directory that contains global variables that are defined in the shared library. These variables can be accessed from any Jenkins job that imports the shared library.

- The resources directory is a regular directory that can contain any type of file. However, it is typically used to store static resources that are used by the shared library.

## Global Shared Libraries

There are several places where Shared Libraries can be defined, depending on the use-case

-  Manage Jenkins » System » Global Pipeline Libraries as many libraries as necessary can be configured

These libraries are considered "trusted:" they can run any methods in Java, Groovy, Jenkins internal APIs, Jenkins plugins, or third-party libraries. This allows you to define libraries which encapsulate individually unsafe APIs in a higher-level wrapper safe for use from any Pipeline. Beware that anyone able to push commits to this SCM repository could obtain unlimited access to Jenkins. You need the Overall/RunScripts permission to configure these libraries (normally this will be granted to Jenkins administrators).

## Folder-level Shared Libraries

Any Folder created can have Shared Libraries associated with it. This mechanism allows scoping of specific libraries to all the Pipelines inside of the folder or subfolder.Folder-based libraries are not considered "trusted:" they run in the Groovy sandbox just like typical Pipelines.

## Automatic Shared Libraries

Other plugins may add ways of defining libraries on the fly. For example, the Pipeline: GitHub Groovy Libraries plugin allows a script to use an untrusted library named like github.com/someorg/somerepo without any additional configuration. In this case, the specified GitHub repository would be loaded, from the master branch, using an anonymous checkout.

## Using Libraries

Shared Libraries marked Load implicitly allows Pipelines to immediately use classes or global variables defined by any such libraries. To access other shared libraries, the Jenkinsfile needs to use the @Library annotation, specifying the library’s name:

```bash
@Library('my-shared-library') _

/* Using a version specifier, such as branch, tag, etc */
@Library('my-shared-library@1.0') _

/* Accessing multiple libraries with one statement */
@Library(['my-shared-library', 'otherlib@abc1234']) _
```

## Loading libraries dynamically

As of version 2.7 of the Pipeline: Shared Groovy Libraries plugin, there is a new option for loading (non-implicit) libraries in a script: a library step that loads a library dynamically, at any time during the build.

If you are only interested in using global variables/functions (from the vars/ directory), the syntax is quite simple:

```bash
library 'my-shared-library'
```

Thereafter, any global variables from that library will be accessible to the script.

Using classes from the src/ directory is also possible, but trickier. Whereas the @Library annotation prepares the “classpath” of the script prior to compilation, by the time a library step is encountered the script has already been compiled. Therefore you cannot import or otherwise “statically” refer to types from the library.

## DEMO

First of all we need jenkins server for this demo.There are some options to deploy jenkins-server

```bash
https://www.jenkins.io/doc/book/installing/
```


### Step-1 Creating Shared library

Let's first create the groovy scripts of the Jenkins shared library and push them to git. We have two simple scripts for this example. We will perform docker build and docker push operations using these scripts.

```bash
// vars/dockerBuild.groovy
#!/usr/bin/env groovy
def call(String APP_IMAGE_REGISTRY, String APP_IMAGE_REPOSITORY) {
    dir("${WORKSPACE}") {
        sh "docker build -t ${APP_IMAGE_REGISTRY}/${APP_IMAGE_REPOSITORY}:$(BUILD_NUMBER) ."
    }
}
```


```bash
// vars/dockerPush.groovy
#!/usr/bin/env groovy

def call(String APP_IMAGE_REGISTRY, String APP_IMAGE_REPOSITORY) {

    dir("${WORKSPACE}") {
        sh "echo $DOCKERHUB_CRED_PSW | docker login -u $DOCKERHUB_CRED_USR --password-stdin"
        sh "docker push ${APP_IMAGE_REGISTRY}/${APP_IMAGE_REPOSITORY}:$(BUILD_NUMBER)"
    }
}
```

```bash
// vars/sayHello.groovy
#!/usr/bin/env groovy

def call(String name = 'human') {
  echo "Hello, ${name}."
}
```

Go to the Global Pipeline Library to Jenkins. After accessing the Jenkins dashboard, navigate to Manage Jenkins >  System to find the Global Pipeline Libraries section and click on the add button to add a new library. Manage Jenkins ---> System ---> Global Pipeline Libraries ---> Click Add button

Library Name: my-shared-library
Default version: main
Retrivial method: Modern SCM
Source Code Management
Project Repository: https://github.com/ersinsari13/jenkins-shared-library.git  #enter your repo name

We can leave other parameters as default and save the configuration.

### Step-2 Creating jenkinsfile

Let's first create github repo named docker-build-push then create the Jenkinsfile and push them to git.

```bash
@Library('my-shared-library') _
pipeline {
    agent any
        
    environment {
        DOCKERHUB_CRED=credentials('docker-hub-credential')
    }
    stages {
        stage('Set Environment') {
            steps {
                script {
                    REGISTRY = "ersinsari"
                    REPOSITORY = "docker-build-push"
                }
            }
        }
        stage('Hello') {
            steps {
                sayHello "hepapi"
            }
        }
        stage('Build') {
            steps {
                dockerBuild "${REGISTRY}", "${REPOSITORY}"
            }
        }
        stage('Push') {
            steps {
                dockerPush "${REGISTRY}", "${REPOSITORY}"
            }
        }
    }
}
```

### Step-3 Creating Pipeline

- Go to Jenkins Server Dashboard
- Click New Item
- Enter "docker-build-push" as a name and select pipeline and click Ok
- Under Pipeline Section:

Definition: Pipeline script from SCM
SCM: Git
Repository URL: https://github.com/ersinsari13/docker-build-push.git  #enter your repository name
Branch: main

Since the Jenkinsfile in the repo is not under any folder, it will be sufficient to just specify its name. For example, if my Jenkinsfile file was located under a folder named build; I should have written build/Jenkinsfile in the Script Path section.

- Save the pipeline configuration


### Step-4 Credential for Dockerhub

In order for the images we created in Pipeline to be pushed to the registry, we need to provide registry credential information to the Jenkins server.

- Go to Jenkins Dashboard
- Select Manage Jenkins
- Click Credentials
- Select Global
- Click Add Credentials button:

Kind: Username with password
username: enter your dockerhub registry username
password: enter your dockerhub registry password
id: dockerhub-registry-credentials
description: dockerhub-registry-credentials

- Save credentials configuration

### Step-5 Build Pipeline

After all the steps, the pipeline we created is now ready to be tested.

- Go to Jenkins Server Dashboard
- Select Pipeline was created
- Click Build Now
- You should see the pipeline result success
- You can check your new image on the Dockerhub registry