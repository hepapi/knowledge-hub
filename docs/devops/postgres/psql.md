# psql CLI

## Installation

!!! warning "Make sure to use the appropriate version of the client for the server"
`bash
    sudo apt install postgresql-client-<version-number>
    `

Go to official [Download Page](https://www.postgresql.org/download/)

## Running commands

**Accessing with the OS user**

Run your commands as the `postgres` user. This is the default user created by the postgres image.

```bash
# sudo -u postgres:: will run the command as the postgres user
sudo -u postgres psql <database-name>
```

The `postgres` user is the only user that can connect to the database without a password, create other users and databases.

**Using the credentials**

```bash
psql --host <your-servers-dns-or-ip> \
    --username postgres \
    --password \
    --dbname template1
```

## psql commands

| Command        | Description                             |
| -------------- | --------------------------------------- |
| `\conninfo`    | Details about the current db connection |
| `\l`           | List all databases                      |
| `\c <db-name>` | Connect/Select a database               |
| `\dt+`         | Show tables in the current database     |
| `\dg+`         | Show users in the current database      |
