# Demo API
The go code is based on the sample from [this post](https://deadsimplechat.com/blog/rest-api-with-golang-and-postgresql/).

I added support to upload images to S3.

## Build
You will need golang `1.22.3` to build this project.

Run this to build:
```
make build
```
This will create an executable at `./build/`

## Docker compose
You can also use the docker compose file provided at `docker/docker-compose.yml`.
This will create the postgresql database and start the api on `localhost:8080`.
You will still need to create the table in the database.

You will need to provide the `BUCKET_NAME` and `AWS_CONFIG_DIR` (probably `/home/<your-user>/.aws`) for it to work.

## Configuration
You need to set up the following environment variables when running the API:
* `API_PORT`
* `BUCKET_NAME`
* `BUCKET_PREFIX`
* `DB_DATABASE_NAME`
* `DB_HOSTNAME`
* `DB_PASSWORD`
* `DB_USERNAME`

## Setting up the database
Create the table:
```sql
CREATE TABLE albums (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255),
  artist VARCHAR(255),
  price DECIMAL(10, 2),
  cover VARCHAR(255)
);
```

## Using API with curl
Create an album
```bash
cover_file=./your/album/image.jpg
json='{"id": 123, "title":"On Circles", "artist":"Caspian", "price":3.4, "cover":"'$(base64 -w0 "$cover_file")'"}'
echo "$json" | curl -X POST -d @- http://localhost:8080/albums
```

Get all albums. This will also give you the URL for the image uploaded.
```bash
curl http://localhost:8080/albums
```
