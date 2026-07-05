# Database
> [!WARNING]
> **WORK IN PROGRESS**
>
> **MUST DO**
> - Add bind-mount for migrations
> - Add data persistence with a named volume

> [!NOTE]
> See the official AzerothCore [recommendations for MySQL](https://github.com/azerothcore/azerothcore-wotlk/security/policy#supported-mysql-versions) versions.
>
> In the future it might be possible to run with other relational databases like PostgreSQL, either fully or partially.

> [!TIP]
> When hosting the database on a different machine not part of a VPC, use an SSH-Tunnel to connect to it remotely instead of opening ports to the internet. This is safer, database-agnostic and SSH has more features than the database auth layer even if it may add a little bit more overhead.
> ```
> # Create a local SSH tunnel to a remote MySQL database
> ssh -fNL TEMP_PORT:localhost:MYSQL_SERVER_PORT USER@SERVER_NAME
>
> # Use it as if the database was local (ssh will redirect to it).
> # Note that localhost and 127.0.0.1 are treated differently in MySQL on Unix, localhost establishes a connection with the use of a local socket file while 127.0.0.1 establishes a TCP/IP connection.
> # Here we are using 127.0.0.1 to ensure it connects with TCP/IP.
> mysql -u root -p -h 127.0.0.1 -P TEMP_PORT
> ```

## Secrets
Mandatory secrets that must be created with the `podman secret create` command before starting the container.
Remember to avoid passing any password as plaintext as well as storing them as environment variables as they can leak with `ps`.
If you need to authenticate with a client, simply use an [~/.my.cnf option file](https://dev.mysql.com/doc/refman/9.7/en/password-security-user.html) with 400 or 600 permissions :

```ini
# ~/.my.cnf
[client]
password=<password>
```

and then running commands like `mysqladmin ping` will automatically read it.
You can also pass a specific path with `--defaults-file`.

| secret                    | type  | target          | mode  | description                                                                                                                                                                                                                                                                                                                                                    |
|---------------------------|-------|-----------------|-------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `ac-database-password`    | mount | `password`      | `400` | MySQL database password. Since target is relatively specified, it will be mounted at `/run/secrets/password`.                                                                                                                                                                                                                                                  |
| `ac-database-option-file` | mount | `/root/.my.cnf` | `400` | [MySQL default option file](https://dev.mysql.com/doc/refman/9.7/en/password-security-user.html). It's a duplicate of `ac-database-password` but within a template to be used for authentication by tools like `msqladmin` without cleartext passwords, therefore you must update both secrets when changing the password. See the previous `.my.cnf` example. |

## Environment variables
Mandatory environment variables.

| environment variable       | description                                                                                        |
|----------------------------|----------------------------------------------------------------------------------------------------|
| `MYSQL_ROOT_PASSWORD_FILE` | **Absolute** target path of `ac-database-password`. This variable is specific to the docker image. |

## Volumes
| volume         | type                  | target                        | description                                      |
|----------------|-----------------------|-------------------------------|--------------------------------------------------|
| `./migrations` | bindmount (read-only) | `/docker-entrypoint-initdb.d` | Files used for database initialization.          |
| `ac-database`  | named volume          | `/var/lib/mysql`              | Location where MySQL writes all data by default. |

## Migrations
The initial setup `migrations/init.sql` takes care of creating the right user and databases which is the same as the one provided by [AzerothCore](https://github.com/azerothcore/azerothcore-wotlk/blob/master/data/sql/create/create_mysql.sql) but with every host occurence of `localhost` replaced by `127.0.0.1` because we're not connecting through the local socket but rather TCP/IP.

## Optimizing playerbots
See [mod-playerbot tuning](https://github.com/mod-playerbots/mod-playerbots/wiki/Installation-Guide#4-configure-playerbots).
