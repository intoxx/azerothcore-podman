# Authserver

> [!WARNING]
> **WORK IN PROGRESS**
>
> **MUST DO**
> - Improve build by copying only authserver-related SQL files here
> - Replace host filesystem dependency (build and data dir) by building everything inside a container
>
> **SHOULD DO**
> - Write container healthcheck
> - Use podman secret to share the database password

## Compilation
1. Ensure you have built the core first, see `<ROOT>/core/README.md`.
2. Run `build.sh` to create the `ac/authserver` image.

## Run
### Volumes
| volume              | type                  | target             | description                                                                                                               |
|---------------------|-----------------------|--------------------|---------------------------------------------------------------------------------------------------------------------------|
| ./azerothcore-wotlk | bindmount (read-only) | /azerothcore-wotlk | Authserver database migration files from the local `azerothcore-wotlk/data` directory generated after running `build.sh`. |

### Environment variables
Order of priority
1. environment variables
2. `.conf` files in `<BUILD>/dist/etc/`
3. hardcoded values into the core binaries

Each configuration option has their equivalent in the form of an environment variable prefixed with `AC_`.

See [Config overrides with env var](https://www.azerothcore.org/wiki/config-overrides-with-env-var) for more information.

| environment variable  | description                                                                                                                                                                                                                                             |
|-----------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `AC_SOURCE_DIRECTORY` | Root of AzerothCore source code. Used to apply database migrations from `<AC_SOURCE_DIRECTORY>/data/sql/`. In reality we don't need the whole source code that is why a local `azerothcore-wotlk/data` folder will be created after running `build.sh`. |
