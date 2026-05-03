#!/bin/bash

DATA_DIR="$(pwd)/data/tpch/100"
SETUP_SQL="/tmp/tpch_setup.sql"
DATAFUSION_OPTIMIZER_PREFER_HASH_JOIN=false

tpch_create_schema() {
  echo "CREATE SCHEMA IF NOT EXISTS tpch;"
}

tpch_create_customer() {
  echo "CREATE EXTERNAL TABLE tpch.customer (
            C_CUSTKEY BIGINT NOT NULL,
            C_NAME VARCHAR NOT NULL,
            C_ADDRESS VARCHAR NOT NULL,
            C_NATIONKEY BIGINT NOT NULL,
            C_PHONE VARCHAR NOT NULL,
            C_ACCTBAL DOUBLE NOT NULL,
            C_MKTSEGMENT VARCHAR NOT NULL,
            C_COMMENT VARCHAR NOT NULL
        ) STORED AS PARQUET LOCATION '${DATA_DIR}/customer.parquet';"
}

tpch_create_orders() {
  echo "CREATE EXTERNAL TABLE tpch.orders (
            O_ORDERKEY BIGINT NOT NULL,
            O_CUSTKEY BIGINT NOT NULL,
            O_ORDERSTATUS CHAR NOT NULL,
            O_TOTALPRICE DOUBLE NOT NULL,
            O_ORDERDATE DATE NOT NULL,
            O_ORDERPRIORITY VARCHAR NOT NULL,
            O_CLERK VARCHAR NOT NULL,
            O_SHIPPRIORITY INTEGER NOT NULL,
            O_COMMENT VARCHAR NOT NULL
        ) STORED AS PARQUET LOCATION '${DATA_DIR}/orders.parquet';"
}

tpch_create_lineitem() {
  echo "CREATE EXTERNAL TABLE tpch.lineitem (
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
            L_COMMENT VARCHAR NOT NULL
        ) STORED AS PARQUET LOCATION '${DATA_DIR}/lineitem.parquet';"
}

tpch_create_nation() {
  echo "CREATE EXTERNAL TABLE tpch.nation (
            N_NATIONKEY INT NOT NULL,
            N_NAME VARCHAR NOT NULL,
            N_REGIONKEY INT NOT NULL,
            N_COMMENT VARCHAR NOT NULL
        ) STORED AS PARQUET LOCATION '${DATA_DIR}/nation.parquet';"
}

tpch_create_region() {
  echo "CREATE EXTERNAL TABLE tpch.region (
            R_REGIONKEY INT NOT NULL,
            R_NAME VARCHAR NOT NULL,
            R_COMMENT VARCHAR NOT NULL
        ) STORED AS PARQUET LOCATION '${DATA_DIR}/region.parquet';"
}

tpch_create_part() {
  echo "CREATE EXTERNAL TABLE tpch.part (
            P_PARTKEY BIGINT NOT NULL,
            P_NAME VARCHAR NOT NULL,
            P_MFGR VARCHAR NOT NULL,
            P_BRAND VARCHAR NOT NULL,
            P_TYPE VARCHAR NOT NULL,
            P_SIZE INT NOT NULL,
            P_CONTAINER VARCHAR NOT NULL,
            P_RETAILPRICE DOUBLE NOT NULL,
            P_COMMENT VARCHAR NOT NULL
        ) STORED AS PARQUET LOCATION '${DATA_DIR}/part.parquet';"
}

tpch_create_supplier() {
  echo "CREATE EXTERNAL TABLE tpch.supplier (
            S_SUPPKEY BIGINT NOT NULL,
            S_NAME VARCHAR NOT NULL,
            S_ADDRESS VARCHAR NOT NULL,
            S_NATIONKEY INT NOT NULL,
            S_PHONE VARCHAR NOT NULL,
            S_ACCTBAL DOUBLE NOT NULL,
            S_COMMENT VARCHAR NOT NULL
        ) STORED AS PARQUET LOCATION '${DATA_DIR}/supplier.parquet';"
}

tpch_create_partsupp() {
  echo "CREATE EXTERNAL TABLE tpch.partsupp (
            PS_PARTKEY BIGINT NOT NULL,
            PS_SUPPKEY BIGINT NOT NULL,
            PS_AVAILQTY BIGINT NOT NULL,
            PS_SUPPLYCOST DOUBLE NOT NULL,
            PS_COMMENT VARCHAR NOT NULL
        ) STORED AS PARQUET LOCATION '${DATA_DIR}/partsupp.parquet';"
}

tpch_write_setup() {
  {
    tpch_create_schema
    tpch_create_customer
    tpch_create_orders
    tpch_create_lineitem
    tpch_create_nation
    tpch_create_region
    tpch_create_part
    tpch_create_supplier
    tpch_create_partsupp
  } >"$SETUP_SQL"
}

tpch_setup() {
  tpch_write_setup
  datafusion-cli -f "$SETUP_SQL"
}

benchmark() {
  tpch_write_setup
  echo "query_number,execution_time_seconds" >tpch/results.csv
  for query_file in tpch/df/*.sql; do
    if [[ -f "$query_file" ]]; then
      query_num=$(basename "$query_file" .sql)
      start_time=$(date +%s.%N)
      echo "$query_file"
      datafusion-cli -m 8g -d 100g -f "$SETUP_SQL" -f "$query_file"
      end_time=$(date +%s.%N)
      execution_time=$(awk "BEGIN {print $end_time - $start_time}")
      echo "$query_num,$execution_time" >>tpch/results.csv
    fi
  done
}

if [ -n "$1" ]; then "$1" "${2:0}"; fi
