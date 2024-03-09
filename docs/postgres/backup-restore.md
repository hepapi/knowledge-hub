# Backup

https://www.postgresql.org/docs/current/app-pgdump.html

## OPSEC

!!! warning "About the versions"
Make sure to use the same version on **all postgres tooling**. Do this OPSEC every time!

- Check the postgres config, including the **version number on the last line**:
  ```bash
  pg_config
  ```
- Check the `pg_dump` version:
  ```bash
  pg_dump --version
  pg_dumpall --version
  ```
- Check the `psql` version:
  ```bash
  psql --version
  ```
- Check the `pg_restore` version:
  ```bash
  pg_restore --version
  ```

Make sure **all the versions match**. Otherwise you might run into issues when restoring the backup.

---

## Choosing the right backup tool

| tool            | right time to use                                                                                                                                                                                                                     |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `pg_basebackup` | **[Physical Copy]** Typically used for disaster recovery scenarios or when you need a complete copy of the database cluster. It allows for easy and efficient restoration of the entire database cluster to a specific point in time. |
| `pg_dumpall`    | **[All DBs in Server]** Routine backups, database migration, or replicating the database structure and data to another server.                                                                                                        |
| `pg_dump`       | **[Single DB in Server]** Commonly used for routine backups of individual databases, database migration, and selective restoration of specific databases or objects.                                                                  |

### pg_dump

- `pg_dump` only dumps a single database.

### pg_dumpall

- Use `pg_dumpall` to back up an entire cluster, or to back up global objects that are common to all databases in a cluster (such as roles and tablespaces).

- Used for logical backups, creating a script that contains SQL commands to recreate the database objects and data.

### pg_basebackup

- Primarily used for **creating physical backups of the entire PostgreSQL database cluster**, including all databases, tablespaces, and configuration files.

### pg_restore

TODO: add pg_restore docs
