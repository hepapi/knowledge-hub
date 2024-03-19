# Postgres Configuration

## Helpers

- **[postgresqlco.nf/ Documentation](https://postgresqlco.nf/)** for explanations of all the configuration options.
    - You can upload your `postgresql.conf` file and it will give you recommendations on how to improve it.
- **[pgtune.leopard.in.ua/#/](https://pgtune.leopard.in.ua/#/)** for generating a `postgresql.conf` file based on your hardware and database usage.



## Notes

- Always set the `PGDATA` environment variable to the path of the data directory. As the default directory used by the postgres image could change in the future.

- Always set the `POSTGRES_PASSWORD` environment variable. If not set, a random password will be generated and printed in the logs. 
  - Always manage the password externally, for example by using a [Kubernetes Secret](https://kubernetes.io/docs/concepts/configuration/secret/).

**Status of postgres process**

- Check the status
    ```bash
    sudo systemctl restart postgresql.service
    ```
- [If Applicable] Enable the service to start on boot 
    ```bash
    sudo systemctl enable postgresql.service
    ```

## Configuration Files

- Located at: `/etc/postgresql/<version>/main/*`

- After changing configuration, you must apply it with 
    ```bash
    sudo systemctl restart postgresql.service
    ```

### pg_ident.conf (OS User Identification)
- This file is used for **Operation System User -> Database User** mapping in PostgreSQL. 
- It allows you to define mappings between a local operating system user and a PostgreSQL database user. 

### postgresql.conf (Configuration)
- This is the **primary configuration file** for PostgreSQL. 
- It contains a wide range of settings that control the behavior of the database server. 
- These settings include parameters such as: 
    - database connection settings, 
    - memory allocation, 
    - logging options, 
    - security configurations,
    - and performance-related settings.

### pg_hba.conf (Host Based Authentication)
- This file controls client authentication in PostgreSQL. 
- It specifies the rules for allowing or denying client connections based on various authentication methods such as: 
    - password authentication, 
    - certificate-based authentication, 
    - or IP address-based authentication. 
- It is responsible for defining who can connect to the database and how they are authenticated.

### pg_stat.conf (Statistics)
- This file is related to the statistics collection in PostgreSQL. 
- It defines which statistics are collected and how they are stored. 
- By configuring this file, you can control the collection of various statistics such as: 
    - the number of tuples read or written, 
    - index usage, 
    - query execution time, and more. 
    These statistics help in monitoring and performance tuning of the database.