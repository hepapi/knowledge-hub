## Principle of least privilege

For security purposes, we should use roles and users to grant permissions for specific tasks.

### Create Role and User

* Type : Select Nexus role
* Privileges: Add `nx-repository-admin-*-*-*` This permission will allow all actions for all artifact and repository types.
>* First and second "*" represent recipe and repository type (docker hosted, docker proxy, apt hosted, apt proxy etc.) 
>* Last one represents actions (add,browse,read,edit,delete)
* Create a new user using the role just created.

----------------------------------------------------------------------------------------

:warning: In Nexus Repository, the `Docker Bearer Token Realm` is required in order to allow anonymous pulls from Docker repositories

To allow anonymous pull:

+ Go to `Realms` in Secutiry, add `Docker Bearer Token Realm` to active category.
+ Edit the repo and click `Allow anonymous docker pull`

----------------------------------------------------------------------------------------