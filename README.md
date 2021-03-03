# docker-common
Docker configuration for running all CLU projects locally.

## Build and run

First, make sure that you have docker installed. After that:

```shell
mkdir -p db/data
docker-compose up
```

The first run will take a long time. Subsequent runs are faster.

## Run

The system can be run in either local or remote mode. In remote mode storage-service will use production S3,
and processing is disabled (data access is read only).

### Local mode

To start the system in local mode, issue:

```shell
docker-compose up
```

or

```shell
./start.sh local
```

`start.sh` is a small wrapper around `docker-compose`.

### Remote mode

To start the system in remote mode, issue:

```shell
./populate-db.sh # Download remote dbs
./start.sh remote # Start in remote mode, you will be asked for your GPG password
```

After the local postgres instance has been populated, it is enough to issue `./start.sh remote` to start the system in remote mode.

## Stop

```shell
docker-compose down
```

## Additional scripts

- `./populate-db.sh`: Download remote db. Uses a cached db file if such exists. To force re-download use `-u`.
- `./reset-db.sh`: Delete all databases. The databases are recreated on `docker-compose up`. NOTE: dataportal backend will throw an error after this, since there is nothing in its db. Populate the db somehow after issuing this command.

## Accessing database

It is possible to access the database from the host computer using `psql`. Just make sure to source the correct environment variable with:

```shell
source .env.host
```

After that, you should be able to connect to the database with

```shell
psql
```

It might be a good idea to source the host environment variables in `.bashrc`.
