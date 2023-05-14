# PoC

## Setup
- create an Ubuntu VM
- install postgres
<!-- - TODO: continue -->

## Backup

- Assumes you have a shell access running postgres instance.
    - If you're trying to do this over a network, you'll need to figure out other options for the commands run (e.g. host, port, etc.)


### Steps

#### 1. Go to a directory where the `postgres` user has write access


```bash
cd /tmp
```

#### 2. Create a Backup file

!!! Note If you're not certain on which tool to use, try to use the `pg_dumpall`.

**2.A. Using `pg_dump`**

Only dumps a single database named `postgres`. 

- Option 1: Write to SQL file
    ```bash
    sudo -u postgres -- pg_dump -U postgres -d postgres -f db_backup-$(date +%d-%m-%Y_%H-%M).sql
    ```
- Option 2: Write to .dump file
    ```bash
    sudo -u postgres -- pg_dump -Fc -U postgres postgres > db_backup-$(date +%d-%m-%Y_%H-%M).dump
    ```

**2.B. Using `pg_dumpall`**

- Option 1: Write to SQL file
    ```bash
    sudo -u postgres -- pg_dumpall --clean -f db_full_backup-$(date +%d-%m-%Y_%H-%M).sql
    ```
- Option 2: Write to .dump file
    ```bash
    sudo -u postgres -- pg_dumpall --clean -f db_full_backup-$(date +%d-%m-%Y_%H-%M).dump
    ```

#### Upload the backup file to a remote storage
- Create a script that will upload the backup file to a remote storage (e.g. AWS S3, Azure Blob Storage, etc.)




## Restore


### Restore a Single DB


We are now working on the host machine that'll be backed up to.

**[IA] Delete the existing DB from the server**
```bash
sudo -u postgres -- dropdb existing-db-name
```

**[IA] Create a new DB to restore to**

Create a new DB named `new-db-name` from the `template0` template.
```bash
sudo -u postgres -- createdb -T template0 new-db-name
```

**Restore a single DB from .sql file**

SQL files are restored with `psql`.

```bash
sudo -u postgres -- psql -U postgres -f db_backup.sql new-db-name 
```


### Restore a Entire DB Server
<!-- TODO: -->




### Check the Restoration

Enter the psql shell to verify the restore was successful.
```bash
sudo -u postgres -- psql -U postgres
```
Run psql commands:
```sql
-- list databases 
\l
-- connect to the new db
\c new-db-name
-- list tables
\dt
-- list rows in a table
SELECT * FROM users;
-- list users
\du
-- list groups
\dg
```



