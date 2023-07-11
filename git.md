## Version Control System (VCS)
A Version Control System (VCS) is a software tool that helps track changes made to files and directories over time. It allows multiple people to collaborate on a project, keeping a history of changes, and providing mechanisms to manage different versions of files. VCS enables teams to work concurrently, facilitating efficient collaboration and providing features like branching, merging, and conflict resolution.

## Git
Git is a widely used distributed version control system designed for speed, flexibility, and data integrity. It is free and open-source, offering powerful features that make it popular among individuals and large organizations. Git provides a decentralized approach, allowing users to have a local copy of the entire repository, including its history, branches, and tags.

## Downloading Git
To download Git for different operating systems, follow these instructions:

### Windows
- Visit the official Git website: `https://git-scm.com/`.
- Click on the "Downloads" link.
- Download the latest Git version for Windows.
- Run the installer and follow the prompts.
- Choose the desired installation options and complete the installation process.

### macOS
- Visit the official Git website: `https://git-scm.com/`.
- Click on the "Downloads" link.
- Download the macOS version of Git.
- Run the installer package and follow the prompts.
- Complete the installation process.

### Linux (Ubuntu)
- Open the terminal.
- Install Git using the package manager:
  - For Debian/Ubuntu-based systems: ``sudo apt-get install git``
  - For Fedora: ``sudo dnf install git``
  - For CentOS/RHEL: ``sudo yum install git``

### Linux (Generic)
- Visit the official Git website: `https://git-scm.com/`.
- Click on the "Downloads" link.
- Download the source code archive for Linux.
- Extract the archive to a desired location.
- In the terminal, navigate to the extracted directory.
- Run the following commands:
  - ``make prefix=/usr/local all``
  - ``sudo make prefix=/usr/local install``

## Verification
Once Git is installed on your system, you can verify the installation by opening a terminal and running ``git --version`` to display the installed version.

## Interfaces
Git provides a command-line interface (CLI) and various graphical user interface (GUI) tools. You can choose the interface that suits your preference and start using Git for version control in your projects.


| Command        | Explanation                                                          | Usage                                   |
| :------------  | :------------------------------------------------------------------: | --------------------------------------: |
| **push**       | Pushing is the process of sending local commits to a remote repository. | `git push origin branch_name`            |
| **pull**       | Pulling is the process of fetching and merging remote changes into the local repository. | `git pull origin branch_name` |
| **add .**      | Adds all modified and new files to the staging area.                   | `git add .`                             |
| **add <file>** | Adds a specific file to the staging area.                               | `git add file_name`                     |
| **commit**     | A commit is a snapshot of changes made to the repository.               | `git commit -m "Commit message"`         |
| **init**       | Initializes a new Git repository in the current directory.              | `git init`                              |
| **log**        | Log displays the commit history of the repository.                      | `git log`                               |
| **status**     | Status shows the current state of the repository.                       | `git status`                            |
| **branch**     | A branch is a separate line of development within a repository.         | `git branch branch_name`                 |
| **merge**      | Merging combines changes from different branches into a single branch.  | `git merge branch_name`                  |
| **revert**     | Revert creates a new commit that undoes changes from a previous commit. | `git revert commit_hash`                 |
| **reset**      | Reset moves the current branch pointer to a specific commit, potentially discarding commits. | `git reset commit_hash`   |
| **rm / remove** | Removes a file from the repository and the working directory.            | `git rm file_name`                       |
| **mv / move**  | Renames or moves a file or directory within the repository.              | `git mv old_file_name new_file_name`     |
| **clone**      | Cloning creates a local copy of a remote repository.                    | `git clone repository_url`               |
| **echo**       | Echo prints a message or value to the terminal or a file.               | `echo "Hello, World!"`                   |
| **touch**      | Touch creates an empty file or updates the timestamp of an existing file. | `touch file_name`                       |
| **ls / list**  | List displays the files and directories in the current directory.       | `ls` or `list`                           |
| **cat**        | Cat displays the contents of a file.                                   | `cat file_name`                          |
| **diff**       | Diff shows the differences between different versions of files.         | `git diff`                              |
| **checkout**   | Checkout allows you to switch between branches or restore files from previous commits. | `git checkout branch_name`   |
| **.gitignore** | A .gitignore file specifies files and patterns to be ignored by Git.    | Create a .gitignore file and list files/patterns to ignore |
| **repository** | A repository is a location where Git stores all the files, history, and changes for a project. | `git init`                |
| **fork**       | Forking creates a copy of a repository under your GitHub account.        | Click on the "Fork" button in the GitHub UI |
| **pull request** | A pull request proposes changes from a forked repository to the original repository. | Create a pull request through the GitHub UI |
| **PR (Pull Request)** | PR is an abbreviation for pull request.                              | Use the term "PR" interchangeably with "pull request" |
| **master**     | Master is the default branch in Git.                                   | The initial branch created in a repository (commonly used) |
| **config**     | Config sets configuration options for Git.                             | `git config --global user.name "Your Name"` |
| **remote**     | Remote refers to a remote repository, typically on a server.            | `git remote add origin repository_url`   |
| **stash**      | Stash temporarily saves local modifications for later use.              | `git stash save "Stash message"`          |
| **pop**        | Pop applies the most recent stash and removes it from the stash list.  | `git stash pop`                          |
| **reflog**     | Reflog shows a log of all reference updates in the repository.          | `git reflog`                            |

| Action | Explanation | Usage |
| :--- | :---: | ---: |
| **Create and Switch to New Branch** | Creates a new branch and switches to it. | `git checkout -b <branch>` |
| **Merge Branch into Main Branch** | Merges changes from a feature branch into the main branch. | `git checkout <main_branch>`<br>`git merge <feature_branch>` |
| **Rebase Branch onto Main Branch** | Updates the feature branch with the latest changes from the main branch. | `git checkout <feature_branch>`<br>`git rebase <main_branch>` |
| **Interactive Rebase** | Allows interactive modification, reordering, or squashing of commits. | `git rebase -i HEAD~<number_of_commits>` |
| **Revert a Commit** | Creates a new commit that undoes the changes from a specific commit. | `git revert <commit_hash>` |
| **Undo Last Commit (Keep Changes)** | Moves the branch pointer back one commit, keeping changes in the staging area. | `git reset --soft HEAD~1` |
| **Discard Last Commit (Lose Changes)** | Moves the branch pointer back one commit, discarding changes in the working directory and staging area. | `git reset --hard HEAD~1` |