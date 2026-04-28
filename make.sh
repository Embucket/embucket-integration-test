#!/bin/bash

export SNOWFLAKE_HOME=$(pwd)

source ./venv.sh

install_snowflake() {
  pip install snowflake-cli
}

up() {
  docker compose up -d
}

down() {
  docker compose down -v
}

volume() {
  snow sql -q "CREATE EXTERNAL VOLUME 'bucket'
  STORAGE_LOCATIONS = 
  (
    (
      NAME = 'bucket'
      STORAGE_PROVIDER = 's3'
      STORAGE_BASE_URL = 'mybucket'
      STORAGE_ENDPOINT = 'http://warehouse.minio:9000'
      CREDENTIALS = (
        AWS_KEY_ID = 'AKIAIOSFODNN7EXAMPLE'
        AWS_SECRET_KEY = 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY'
        REGION = 'us-east-2'
      )
    )
  )"
}

volume_s3() {
  snow sql -q "CREATE EXTERNAL VOLUME 'bucket'
  STORAGE_LOCATIONS = 
  (
    (
      NAME = 'bucket'
      STORAGE_PROVIDER = 's3'
      STORAGE_BASE_URL = 'jan-embucket'
      CREDENTIALS = (
        AWS_KEY_ID = '$AWS_ACCESS_KEY_ID'
        AWS_SECRET_KEY = '$AWS_SECRET_ACCESS_KEY'
        REGION = 'us-east-2'
      )
    )
  )"
}

volume_s3tables() {
  snow sql -q "CREATE EXTERNAL VOLUME 'bucket'
  STORAGE_LOCATIONS = 
  (
    (
      NAME = 'bucket'
      STORAGE_PROVIDER = 's3tables'
      CREDENTIALS = (
        AWS_KEY_ID = '$AWS_ACCESS_KEY_ID'
        AWS_SECRET_KEY = '$AWS_SECRET_ACCESS_KEY'
        REGION = 'us-east-2'
      )
      STORAGE_AWS_ACCESS_POINT_ARN = 'arn:aws:s3tables:us-east-2:767397688925:bucket/jan-table-bucket'
    )
  )"
}

volume_local() {
  snow sql -q "CREATE EXTERNAL VOLUME 'local'
  STORAGE_LOCATIONS = 
  (
    (
      NAME = 'local'
      STORAGE_PROVIDER = 'file'
      STORAGE_BASE_URL = '/storage'
    )
  )"
}

database() {
  snow sql -q "CREATE DATABASE demo EXTERNAL_VOLUME = 'bucket';"
}

volume_file() {
  snow sql -q "CREATE EXTERNAL VOLUME 'file'
  STORAGE_LOCATIONS = 
  (
    (
      NAME = 'file'
      STORAGE_PROVIDER = 'file'
      STORAGE_BASE_URL = '$(pwd)/storage'
    )
  )"
}

database_file() {
  snow sql -q "CREATE DATABASE demo EXTERNAL_VOLUME = 'file';"
}

schema() {
  snow sql -q "CREATE SCHEMA demo.embucket;"
}

schema_fc() {
  snow sql -q "CREATE SCHEMA IF NOT EXISTS embucket.public;"
}

setup() {
  volume
  volume_local
  database
  schema
}

setup_file() {
  volume_file
  database_file
  schema
}

snowsql() {
  snow sql -q "$1"
}

sparksql() {
  docker exec spark-iceberg spark-sql -e "$1"
}

equality() {
  spark_sql "select sum(hash(*)) from $1"
  spark_sql "select sum(hash(*)) from $2"
}

activate

if [ -n "$1" ]; then "$1" "${2:0}"; fi
