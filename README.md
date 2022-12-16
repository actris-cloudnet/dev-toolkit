# Cloudnet development toolkit

Docker configuration for running all Cloudnet projects locally.

The toolkit requires Docker version ≥ 20 and Docker Compose version ≥ 2.2.

## Setup

First create a directory for all repositories and clone this repository there:

```shell
mkdir cloudnet
cd cloudnet
git clone git@github.com:actris-cloudnet/dev-toolkit.git
```

Then run `fetch-repos.sh` to fetch other repositories:

```shell
cd dev-toolkit
./fetch-repos.sh
```

You can later pull the latest changes by running `fetch-repos.sh` again.

## Build

First, make sure that you have docker installed. After that:

```shell
mkdir -p db/data
docker compose build
```

The first run will take a long time. Subsequent runs are faster.

Then install Node dependencies to your host system:

```shell
docker compose run dataportal-backend npm install
docker compose run dataportal-frontend npm install
docker compose run dataportal-frontend sh -c 'cd /shared && npm install'
docker compose run storage-service npm install
```

To destroy existing containers, and build & install the project from the scratch, you can issue:

```shell
./clean_install.sh
```

## Unlock encrypted files (only internal developers)

Unlock encrypted pid-service test credentials:

```shell
cd pid-service/
git-crypt unlock
```

## Run

The system can be run in either local or remote mode. In remote mode `storage-service` will use production S3,
and processing is disabled (data access is read only).

### Local mode

To start the system in local mode, issue:

```shell
docker compose up
```

or

```shell
./start.sh local
```

`start.sh` is a small wrapper around `docker compose`.

If you are starting the system in local mode for the first time, you may need to [populate the dataportal database](https://github.com/actris-cloudnet/dataportal/#populating-the-database).

### Remote mode (only internal developers)

First, make sure that you have cloned the `secrets` repository from `actris-cloudnet` and unlocked them using `git-crypt unlock`.

To start the system in remote mode, issue:

```shell
./populate-db.sh # Download remote dbs
./start.sh remote # Start in remote mode, you will be asked for your GPG password
```

After the local postgres instance has been populated, it is enough to issue `./start.sh remote` to start the system in remote mode.

## Stop

Stop containers by pressing `Ctrl+C`.

Destroy containers by running:

```shell
docker compose down
```

## Additional scripts

- `./populate-db.sh`: Download remote db. Uses a cached db file if such exists. To force re-download use `-u`.
For instructions on how to populate the development db with test fixtures, see [here](https://github.com/actris-cloudnet/dataportal/#populating-the-database).

## Accessing database

To access `dataportal` database, run:

```sh
docker compose exec db psql dataportal
```

To access `storage-service` database, run:

```sh
docker compose exec db psql ss
```

## Exposed ports

The following ports are exposed from the containers to `localhost`:

- `8080` Development frontend
- `3000` Development backend
- `3001` Test backend
- `3005` Citation service
- `5800` PID service
- `5900` Storage service
- `54321` PostgreSQL
- `8086` InfluxDB
- `5921` Storage service mock (for tests)

## License

MIT
