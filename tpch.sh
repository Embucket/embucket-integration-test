#!/bin/bash

export SNOWFLAKE_HOME=$(pwd)

source ./venv.sh

mkdir -p data/tpch/10 data/tpch/100

volume_local_file() {
  snow sql -q "CREATE EXTERNAL VOLUME 'local'
  STORAGE_LOCATIONS = 
  (
    (
      NAME = 'local'
      STORAGE_PROVIDER = 'file'
      STORAGE_BASE_URL = '$(pwd)/data/tpch'
    )
  )"
}

tpch_create_customer() {
  snow sql -q "CREATE TABLE demo.embucket.customer (
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
  snow sql -q "CREATE TABLE demo.embucket.orders (
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
  snow sql -q "CREATE TABLE demo.embucket.lineitem (
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
  snow sql -q "CREATE TABLE demo.embucket.nation (
            N_NATIONKEY INT NOT NULL,
            N_NAME VARCHAR NOT NULL,
            N_REGIONKEY INT NOT NULL,
            N_COMMENT VARCHAR NOT NULL);"
}

tpch_create_region() {
  snow sql -q "CREATE TABLE demo.embucket.region (
            R_REGIONKEY INT NOT NULL,
            R_NAME VARCHAR NOT NULL,
            R_COMMENT VARCHAR NOT NULL);"
}

tpch_create_part() {
  snow sql -q "CREATE TABLE demo.embucket.part (
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
  snow sql -q "CREATE TABLE demo.embucket.supplier (
            S_SUPPKEY BIGINT NOT NULL,
            S_NAME VARCHAR NOT NULL,
            S_ADDRESS VARCHAR NOT NULL,
            S_NATIONKEY INT NOT NULL,
            S_PHONE VARCHAR NOT NULL,
            S_ACCTBAL DOUBLE NOT NULL,
            S_COMMENT VARCHAR NOT NULL);"
}

tpch_create_partsupp() {
  snow sql -q "CREATE TABLE demo.embucket.partsupp (
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
  snow sql -q "COPY INTO demo.embucket.customer FROM 'file:///data/tpch/100/customer.parquet' STORAGE_INTEGRATION = local FILE_FORMAT = (TYPE = PARQUET);"
}

tpch_copy_into_orders() {
  snow sql -q "COPY INTO demo.embucket.orders FROM 'file:///data/tpch/100/orders.parquet' STORAGE_INTEGRATION = local FILE_FORMAT = (TYPE = PARQUET);"
}

tpch_copy_into_lineitem() {
  snow sql -q "COPY INTO demo.embucket.lineitem FROM 'file:///data/tpch/100/lineitem.parquet' STORAGE_INTEGRATION = local FILE_FORMAT = (TYPE = PARQUET);"
}

tpch_copy_into_nation() {
  snow sql -q "COPY INTO demo.embucket.nation FROM 'file:///data/tpch/100/nation.parquet' STORAGE_INTEGRATION = local FILE_FORMAT = (TYPE = PARQUET);"
}

tpch_copy_into_region() {
  snow sql -q "COPY INTO demo.embucket.region FROM 'file:///data/tpch/100/region.parquet' STORAGE_INTEGRATION = local FILE_FORMAT = (TYPE = PARQUET);"
}

tpch_copy_into_part() {
  snow sql -q "COPY INTO demo.embucket.part FROM 'file:///data/tpch/100/part.parquet' STORAGE_INTEGRATION = local FILE_FORMAT = (TYPE = PARQUET);"
}

tpch_copy_into_supplier() {
  snow sql -q "COPY INTO demo.embucket.supplier FROM 'file:///data/tpch/100/supplier.parquet' STORAGE_INTEGRATION = local FILE_FORMAT = (TYPE = PARQUET);"
}

tpch_copy_into_partsupp() {
  snow sql -q "COPY INTO demo.embucket.partsupp FROM 'file:///data/tpch/100/partsupp.parquet' STORAGE_INTEGRATION = local FILE_FORMAT = (TYPE = PARQUET);"
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
  tpch_create_tables
  tpch_copy_into_tables
}

tpch_copy_into_customer_file() {
  snow sql -q "COPY INTO demo.embucket.customer FROM 'file://$(pwd)/data/tpch/100/customer.parquet' STORAGE_INTEGRATION = local FILE_FORMAT = (TYPE = PARQUET);"
}

tpch_copy_into_orders_file() {
  snow sql -q "COPY INTO demo.embucket.orders FROM 'file://$(pwd)/data/tpch/100/orders.parquet' STORAGE_INTEGRATION = local FILE_FORMAT = (TYPE = PARQUET);"
}

tpch_copy_into_lineitem_file() {
  snow sql -q "COPY INTO demo.embucket.lineitem FROM 'file://$(pwd)/data/tpch/100/lineitem.parquet' STORAGE_INTEGRATION = local FILE_FORMAT = (TYPE = PARQUET);"
}

tpch_copy_into_nation_file() {
  snow sql -q "COPY INTO demo.embucket.nation FROM 'file://$(pwd)/data/tpch/100/nation.parquet' STORAGE_INTEGRATION = local FILE_FORMAT = (TYPE = PARQUET);"
}

tpch_copy_into_region_file() {
  snow sql -q "COPY INTO demo.embucket.region FROM 'file://$(pwd)/data/tpch/100/region.parquet' STORAGE_INTEGRATION = local FILE_FORMAT = (TYPE = PARQUET);"
}

tpch_copy_into_part_file() {
  snow sql -q "COPY INTO demo.embucket.part FROM 'file://$(pwd)/data/tpch/100/part.parquet' STORAGE_INTEGRATION = local FILE_FORMAT = (TYPE = PARQUET);"
}

tpch_copy_into_supplier_file() {
  snow sql -q "COPY INTO demo.embucket.supplier FROM 'file://$(pwd)/data/tpch/100/supplier.parquet' STORAGE_INTEGRATION = local FILE_FORMAT = (TYPE = PARQUET);"
}

tpch_copy_into_partsupp_file() {
  snow sql -q "COPY INTO demo.embucket.partsupp FROM 'file://$(pwd)/data/tpch/100/partsupp.parquet' STORAGE_INTEGRATION = local FILE_FORMAT = (TYPE = PARQUET);"
}

tpch_copy_into_tables_file() {
  tpch_copy_into_customer_file
  tpch_copy_into_orders_file
  tpch_copy_into_lineitem_file
  tpch_copy_into_nation_file
  tpch_copy_into_region_file
  tpch_copy_into_part_file
  tpch_copy_into_supplier_file
  tpch_copy_into_partsupp_file
}

tpch_customer() {
  tpch_create_table
  tpch_copy_into_customer_file
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
