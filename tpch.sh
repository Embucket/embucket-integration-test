#!/bin/bash

export SNOWFLAKE_HOME=$(pwd)

source ./venv.sh

tpch_create_schema() {
  snow sql -q "CREATE SCHEMA IF NOT EXISTS embucket.tpch;"
}

tpch_create_customer() {
  snow sql -q "CREATE TABLE embucket.tpch.customer (
            C_CUSTKEY BIGINT NOT NULL,
            C_NAME VARCHAR NOT NULL,
            C_ADDRESS VARCHAR NOT NULL,
            C_NATIONKEY BIGINT NOT NULL,
            C_PHONE VARCHAR NOT NULL,
            C_ACCTBAL DOUBLE NOT NULL,
            C_MKTSEGMENT VARCHAR NOT NULL,
            C_COMMENT VARCHAR NOT NULL);"
}

tpch_create_orders() {
  snow sql -q "CREATE TABLE embucket.tpch.orders (
            O_ORDERKEY BIGINT NOT NULL,
            O_CUSTKEY BIGINT NOT NULL,
            O_ORDERSTATUS CHAR NOT NULL,
            O_TOTALPRICE DOUBLE NOT NULL,
            O_ORDERDATE DATE NOT NULL,
            O_ORDERPRIORITY VARCHAR NOT NULL,
            O_CLERK VARCHAR NOT NULL,
            O_SHIPPRIORITY INTEGER NOT NULL,
            O_COMMENT VARCHAR NOT NULL);"
}

tpch_create_lineitem() {
  snow sql -q "CREATE TABLE embucket.tpch.lineitem (
            L_ORDERKEY BIGINT NOT NULL,
            L_PARTKEY BIGINT NOT NULL,
            L_SUPPKEY BIGINT NOT NULL,
            L_LINENUMBER INT NOT NULL,
            L_QUANTITY DOUBLE NOT NULL,
            L_EXTENDEDPRICE DOUBLE NOT NULL,
            L_DISCOUNT DOUBLE NOT NULL,
            L_TAX DOUBLE NOT NULL,
            L_RETURNFLAG CHAR NOT NULL,
            L_LINESTATUS CHAR NOT NULL,
            L_SHIPDATE DATE NOT NULL,
            L_COMMITDATE DATE NOT NULL,
            L_RECEIPTDATE DATE NOT NULL,
            L_SHIPINSTRUCT VARCHAR NOT NULL,
            L_SHIPMODE VARCHAR NOT NULL,
            L_COMMENT VARCHAR NOT NULL);"
}

tpch_create_nation() {
  snow sql -q "CREATE TABLE embucket.tpch.nation (
            N_NATIONKEY INT NOT NULL,
            N_NAME VARCHAR NOT NULL,
            N_REGIONKEY INT NOT NULL,
            N_COMMENT VARCHAR NOT NULL);"
}

tpch_create_region() {
  snow sql -q "CREATE TABLE embucket.tpch.region (
            R_REGIONKEY INT NOT NULL,
            R_NAME VARCHAR NOT NULL,
            R_COMMENT VARCHAR NOT NULL);"
}

tpch_create_part() {
  snow sql -q "CREATE TABLE embucket.tpch.part (
            P_PARTKEY BIGINT NOT NULL,
            P_NAME VARCHAR NOT NULL,
            P_MFGR VARCHAR NOT NULL,
            P_BRAND VARCHAR NOT NULL,
            P_TYPE VARCHAR NOT NULL,
            P_SIZE INT NOT NULL,
            P_CONTAINER VARCHAR NOT NULL,
            P_RETAILPRICE DOUBLE NOT NULL,
            P_COMMENT VARCHAR NOT NULL);"
}

tpch_create_supplier() {
  snow sql -q "CREATE TABLE embucket.tpch.supplier (
            S_SUPPKEY BIGINT NOT NULL,
            S_NAME VARCHAR NOT NULL,
            S_ADDRESS VARCHAR NOT NULL,
            S_NATIONKEY INT NOT NULL,
            S_PHONE VARCHAR NOT NULL,
            S_ACCTBAL DOUBLE NOT NULL,
            S_COMMENT VARCHAR NOT NULL);"
}

tpch_create_partsupp() {
  snow sql -q "CREATE TABLE embucket.tpch.partsupp (
            PS_PARTKEY BIGINT NOT NULL,
            PS_SUPPKEY BIGINT NOT NULL,
            PS_AVAILQTY BIGINT NOT NULL,
            PS_SUPPLYCOST DOUBLE NOT NULL,
            PS_COMMENT VARCHAR NOT NULL);"
}

tpch_create_tables() {
  tpch_create_customer
  tpch_create_orders
  tpch_create_lineitem
  tpch_create_nation
  tpch_create_region
  tpch_create_part
  tpch_create_supplier
  tpch_create_partsupp
}

tpch_copy_into_customer() {
  snow sql -q "COPY INTO embucket.tpch.customer FROM 's3://embucket-testdata/tpch/1000/customer.parquet' FILE_FORMAT = (TYPE = PARQUET);"
}

tpch_copy_into_orders() {
  snow sql -q "COPY INTO embucket.tpch.orders FROM 's3://embucket-testdata/tpch/1000/orders.parquet' FILE_FORMAT = (TYPE = PARQUET);"
}

tpch_copy_into_lineitem() {
  snow sql -q "COPY INTO embucket.tpch.lineitem FROM 's3://embucket-testdata/tpch/1000/lineitem.parquet' FILE_FORMAT = (TYPE = PARQUET);"
}

tpch_copy_into_nation() {
  snow sql -q "COPY INTO embucket.tpch.nation FROM 's3://embucket-testdata/tpch/1000/nation.parquet' FILE_FORMAT = (TYPE = PARQUET);"
}

tpch_copy_into_region() {
  snow sql -q "COPY INTO embucket.tpch.region FROM 's3://embucket-testdata/tpch/1000/region.parquet' FILE_FORMAT = (TYPE = PARQUET);"
}

tpch_copy_into_part() {
  snow sql -q "COPY INTO embucket.tpch.part FROM 's3://embucket-testdata/tpch/1000/part.parquet' FILE_FORMAT = (TYPE = PARQUET);"
}

tpch_copy_into_supplier() {
  snow sql -q "COPY INTO embucket.tpch.supplier FROM 's3://embucket-testdata/tpch/1000/supplier.parquet' FILE_FORMAT = (TYPE = PARQUET);"
}

tpch_copy_into_partsupp() {
  snow sql -q "COPY INTO embucket.tpch.partsupp FROM 's3://embucket-testdata/tpch/1000/partsupp.parquet' FILE_FORMAT = (TYPE = PARQUET);"
}

tpch_copy_into_tables() {
  tpch_copy_into_customer
  tpch_copy_into_orders
  tpch_copy_into_lineitem
  tpch_copy_into_nation
  tpch_copy_into_region
  tpch_copy_into_part
  tpch_copy_into_supplier
  tpch_copy_into_partsupp
}

tpch_setup() {
  tpch_create_schema
  tpch_create_tables
  tpch_copy_into_tables
}

benchmark() {
  echo "query_number,execution_time_seconds" >tpch/results.csv
  for query_file in tpch/queries/*.sql; do
    if [[ -f "$query_file" ]]; then
      query_num=$(basename "$query_file" .sql)
      start_time=$(date +%s.%N)
      snow sql -f "$query_file"
      end_time=$(date +%s.%N)
      execution_time=$(awk "BEGIN {print $end_time - $start_time}")
      echo "$query_num,$execution_time" >>tpch/results.csv
    fi
  done
}

activate

if [ -n "$1" ]; then "$1" "${2:0}"; fi
