# Worldserver

> [!WARNING]
> **WORK IN PROGRESS**
>
> **MUST DO**
> - Improve build by copying only worldserver-related SQL files here
> - Replace host filesystem dependency (build and data dir) by building everything inside a container
>
> **SHOULD DO**
> - Write container healthcheck
> - Use podman secret to share the database password

## Compilation
1. Ensure you have built the core first, see `<ROOT>/core/README.md`.
2. Run `build.sh` to create the `ac/worldserver` image.

## Run
> [!NOTE]
> The worldserver is a **REPL** which means it is **interactive.** That is why it's important to have it started with the `--tty` *(`-t`)* flag, while the `--interactive` *(`-i`)* flag is optional as we don't need persistent STDIN, simply attaching to the container will open it on-demand.
> As a consequence if you want to **attach** to this process you must run `podman attach <CONTAINER>` but **careful** about doing **`CTRL+C`** as it will **kill the process**, exiting should be done with the standard **podman key sequences `CTRL+P CTRL+Q`.**

### Volumes
| volume              | type                  | target             | description                                                                                                                |
|---------------------|-----------------------|--------------------|----------------------------------------------------------------------------------------------------------------------------|
| ./azerothcore-wotlk | bindmount (read-only) | /azerothcore-wotlk | Worldserver database migration files from the local `azerothcore-wotlk/data` directory generated after running `build.sh`. |
| ./data              | bindmount (read-only) | /ac/data           | Localized client data files supported by the server.                                                                       |

### Environment variables
Order of priority
1. environment variables
2. `.conf` files in `<BUILD>/dist/etc/`
3. hardcoded values into the core binaries

Each configuration option has their equivalent in the form of an environment variable prefixed with `AC_`.

See [Config overrides with env var](https://www.azerothcore.org/wiki/config-overrides-with-env-var) for more information.

| environment variable     | description                                                                                                                                                                                                                                             |
|--------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `AC_SOURCE_DIRECTORY`    | Root of AzerothCore source code. Used to apply database migrations from `<AC_SOURCE_DIRECTORY>/data/sql/`. In reality we don't need the whole source code that is why a local `azerothcore-wotlk/data` folder will be created after running `build.sh`. |
| `AC_DATA_DIR`            | Root of localized client data files supported by the server.                                                                                                                                                                                            |
| `AC_MAP_UPDATE_INTERVAL` | Time in milliseconds for map update interval. Impacts performance.                                                                                                                                                                                      |
| `AC_MAP_UPDATE_THREADS`  | Number of cores + 1 to use to distribute the map updating process. Impacts performance.                                                                                                                                                                 |
