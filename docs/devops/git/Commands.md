
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