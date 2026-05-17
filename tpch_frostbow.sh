#!/bin/bash

SRC_BUCKET="s3://embucket-testdata/tpch/1000"
CATALOG_URL="s3://embucket-jan-temp/catalog"
FROSTBOW_BIN="$HOME/frostbow"
SETUP_SQL="/tmp/tpch_frostbow_setup.sql"
QUERIES_DIR="tpch/frostbow"
RESULTS_CSV="tpch/results_frostbow.csv"
MEM_GB=32

tpch_create_schema() {
  echo "CREATE SCHEMA IF NOT EXISTS warehouse.tpch;"
}

tpch_create_customer_src() {
  echo "CREATE EXTERNAL TABLE customer_src (
            C_CUSTKEY BIGINT NOT NULL,
            C_NAME VARCHAR NOT NULL,
            C_ADDRESS VARCHAR NOT NULL,
            C_NATIONKEY BIGINT NOT NULL,
            C_PHONE VARCHAR NOT NULL,
            C_ACCTBAL DOUBLE NOT NULL,
            C_MKTSEGMENT VARCHAR NOT NULL,
            C_COMMENT VARCHAR NOT NULL
        ) STORED AS PARQUET LOCATION '${SRC_BUCKET}/customer.parquet';"
}

tpch_create_customer() {
  echo "CREATE EXTERNAL TABLE warehouse.tpch.customer (
            C_CUSTKEY BIGINT NOT NULL,
            C_NAME VARCHAR NOT NULL,
            C_ADDRESS VARCHAR NOT NULL,
            C_NATIONKEY BIGINT NOT NULL,
            C_PHONE VARCHAR NOT NULL,
            C_ACCTBAL DOUBLE NOT NULL,
            C_MKTSEGMENT VARCHAR NOT NULL,
            C_COMMENT VARCHAR NOT NULL
        ) STORED AS ICEBERG LOCATION '${CATALOG_URL}/warehouse/tpch/customer';"
}

tpch_insert_customer() {
  echo "INSERT INTO warehouse.tpch.customer SELECT * FROM customer_src;"
}

tpch_create_orders_src() {
  echo "CREATE EXTERNAL TABLE orders_src (
            O_ORDERKEY BIGINT NOT NULL,
            O_CUSTKEY BIGINT NOT NULL,
            O_ORDERSTATUS CHAR NOT NULL,
            O_TOTALPRICE DOUBLE NOT NULL,
            O_ORDERDATE DATE NOT NULL,
            O_ORDERPRIORITY VARCHAR NOT NULL,
            O_CLERK VARCHAR NOT NULL,
            O_SHIPPRIORITY INTEGER NOT NULL,
            O_COMMENT VARCHAR NOT NULL
        ) STORED AS PARQUET LOCATION '${SRC_BUCKET}/orders.parquet';"
}

tpch_create_orders() {
  echo "CREATE EXTERNAL TABLE warehouse.tpch.orders (
            O_ORDERKEY BIGINT NOT NULL,
            O_CUSTKEY BIGINT NOT NULL,
            O_ORDERSTATUS CHAR NOT NULL,
            O_TOTALPRICE DOUBLE NOT NULL,
            O_ORDERDATE DATE NOT NULL,
            O_ORDERPRIORITY VARCHAR NOT NULL,
            O_CLERK VARCHAR NOT NULL,
            O_SHIPPRIORITY INTEGER NOT NULL,
            O_COMMENT VARCHAR NOT NULL
        ) STORED AS ICEBERG LOCATION '${CATALOG_URL}/warehouse/tpch/orders';"
}

tpch_insert_orders() {
  echo "INSERT INTO warehouse.tpch.orders SELECT * FROM orders_src;"
}

tpch_create_lineitem_src() {
  echo "CREATE EXTERNAL TABLE lineitem_src (
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
        ) STORED AS PARQUET LOCATION '${SRC_BUCKET}/lineitem.parquet';"
}

tpch_create_lineitem() {
  echo "CREATE EXTERNAL TABLE warehouse.tpch.lineitem (
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
        ) STORED AS ICEBERG LOCATION '${CATALOG_URL}/warehouse/tpch/lineitem';"
}

tpch_insert_lineitem() {
  echo "INSERT INTO warehouse.tpch.lineitem SELECT * FROM lineitem_src;"
}

tpch_create_nation_src() {
  echo "CREATE EXTERNAL TABLE nation_src (
            N_NATIONKEY INT NOT NULL,
            N_NAME VARCHAR NOT NULL,
            N_REGIONKEY INT NOT NULL,
            N_COMMENT VARCHAR NOT NULL
        ) STORED AS PARQUET LOCATION '${SRC_BUCKET}/nation.parquet';"
}

tpch_create_nation() {
  echo "CREATE EXTERNAL TABLE warehouse.tpch.nation (
            N_NATIONKEY INT NOT NULL,
            N_NAME VARCHAR NOT NULL,
            N_REGIONKEY INT NOT NULL,
            N_COMMENT VARCHAR NOT NULL
        ) STORED AS ICEBERG LOCATION '${CATALOG_URL}/warehouse/tpch/nation';"
}

tpch_insert_nation() {
  echo "INSERT INTO warehouse.tpch.nation SELECT * FROM nation_src;"
}

tpch_create_region_src() {
  echo "CREATE EXTERNAL TABLE region_src (
            R_REGIONKEY INT NOT NULL,
            R_NAME VARCHAR NOT NULL,
            R_COMMENT VARCHAR NOT NULL
        ) STORED AS PARQUET LOCATION '${SRC_BUCKET}/region.parquet';"
}

tpch_create_region() {
  echo "CREATE EXTERNAL TABLE warehouse.tpch.region (
            R_REGIONKEY INT NOT NULL,
            R_NAME VARCHAR NOT NULL,
            R_COMMENT VARCHAR NOT NULL
        ) STORED AS ICEBERG LOCATION '${CATALOG_URL}/warehouse/tpch/region';"
}

tpch_insert_region() {
  echo "INSERT INTO warehouse.tpch.region SELECT * FROM region_src;"
}

tpch_create_part_src() {
  echo "CREATE EXTERNAL TABLE part_src (
            P_PARTKEY BIGINT NOT NULL,
            P_NAME VARCHAR NOT NULL,
            P_MFGR VARCHAR NOT NULL,
            P_BRAND VARCHAR NOT NULL,
            P_TYPE VARCHAR NOT NULL,
            P_SIZE INT NOT NULL,
            P_CONTAINER VARCHAR NOT NULL,
            P_RETAILPRICE DOUBLE NOT NULL,
            P_COMMENT VARCHAR NOT NULL
        ) STORED AS PARQUET LOCATION '${SRC_BUCKET}/part.parquet';"
}

tpch_create_part() {
  echo "CREATE EXTERNAL TABLE warehouse.tpch.part (
            P_PARTKEY BIGINT NOT NULL,
            P_NAME VARCHAR NOT NULL,
            P_MFGR VARCHAR NOT NULL,
            P_BRAND VARCHAR NOT NULL,
            P_TYPE VARCHAR NOT NULL,
            P_SIZE INT NOT NULL,
            P_CONTAINER VARCHAR NOT NULL,
            P_RETAILPRICE DOUBLE NOT NULL,
            P_COMMENT VARCHAR NOT NULL
        ) STORED AS ICEBERG LOCATION '${CATALOG_URL}/warehouse/tpch/part';"
}

tpch_insert_part() {
  echo "INSERT INTO warehouse.tpch.part SELECT * FROM part_src;"
}

tpch_create_supplier_src() {
  echo "CREATE EXTERNAL TABLE supplier_src (
            S_SUPPKEY BIGINT NOT NULL,
            S_NAME VARCHAR NOT NULL,
            S_ADDRESS VARCHAR NOT NULL,
            S_NATIONKEY INT NOT NULL,
            S_PHONE VARCHAR NOT NULL,
            S_ACCTBAL DOUBLE NOT NULL,
            S_COMMENT VARCHAR NOT NULL
        ) STORED AS PARQUET LOCATION '${SRC_BUCKET}/supplier.parquet';"
}

tpch_create_supplier() {
  echo "CREATE EXTERNAL TABLE warehouse.tpch.supplier (
            S_SUPPKEY BIGINT NOT NULL,
            S_NAME VARCHAR NOT NULL,
            S_ADDRESS VARCHAR NOT NULL,
            S_NATIONKEY INT NOT NULL,
            S_PHONE VARCHAR NOT NULL,
            S_ACCTBAL DOUBLE NOT NULL,
            S_COMMENT VARCHAR NOT NULL
        ) STORED AS ICEBERG LOCATION '${CATALOG_URL}/warehouse/tpch/supplier';"
}

tpch_insert_supplier() {
  echo "INSERT INTO warehouse.tpch.supplier SELECT * FROM supplier_src;"
}

tpch_create_partsupp_src() {
  echo "CREATE EXTERNAL TABLE partsupp_src (
            PS_PARTKEY BIGINT NOT NULL,
            PS_SUPPKEY BIGINT NOT NULL,
            PS_AVAILQTY BIGINT NOT NULL,
            PS_SUPPLYCOST DOUBLE NOT NULL,
            PS_COMMENT VARCHAR NOT NULL
        ) STORED AS PARQUET LOCATION '${SRC_BUCKET}/partsupp.parquet';"
}

tpch_create_partsupp() {
  echo "CREATE EXTERNAL TABLE warehouse.tpch.partsupp (
            PS_PARTKEY BIGINT NOT NULL,
            PS_SUPPKEY BIGINT NOT NULL,
            PS_AVAILQTY BIGINT NOT NULL,
            PS_SUPPLYCOST DOUBLE NOT NULL,
            PS_COMMENT VARCHAR NOT NULL
        ) STORED AS ICEBERG LOCATION '${CATALOG_URL}/warehouse/tpch/partsupp';"
}

tpch_insert_partsupp() {
  echo "INSERT INTO warehouse.tpch.partsupp SELECT * FROM partsupp_src;"
}

tpch_write_setup() {
  {
    tpch_create_schema
    for t in region nation supplier customer part partsupp orders lineitem; do
      "tpch_create_${t}_src"
      "tpch_create_${t}"
      "tpch_insert_${t}"
    done
  } >"$SETUP_SQL"
}

tpch_setup() {
  tpch_write_setup
  echo "Running TPC-H setup (catalog: $CATALOG_URL) — loads SF=1000 data into Iceberg."
  "$FROSTBOW_BIN" -u "$CATALOG_URL" -s s3 -m "$MEM_GB" -f "$SETUP_SQL"
}

generate_queries() {
  mkdir -p "$QUERIES_DIR"
  for src in tpch/df/*.sql; do
    [[ -f "$src" ]] || continue
    base=$(basename "$src")
    sed -E 's/(^|[^a-zA-Z0-9_])tpch\.([a-zA-Z_]+)/\1warehouse.tpch.\2/g' "$src" >"$QUERIES_DIR/$base"
  done
}

benchmark() {
  if [ ! -d "$QUERIES_DIR" ] || ! compgen -G "$QUERIES_DIR/*.sql" >/dev/null; then
    generate_queries
  fi
  echo "query_number,execution_time_seconds" >"$RESULTS_CSV"
  for query_file in "$QUERIES_DIR"/*.sql; do
    if [[ -f "$query_file" ]]; then
      query_num=$(basename "$query_file" .sql)
      start_time=$(date +%s.%N)
      echo "$query_file"
      "$FROSTBOW_BIN" -u "$CATALOG_URL" -s s3 -m "$MEM_GB" -f "$query_file"
      end_time=$(date +%s.%N)
      execution_time=$(awk "BEGIN {print $end_time - $start_time}")
      echo "$query_num,$execution_time" >>"$RESULTS_CSV"
    fi
  done
}

if [ -n "$1" ]; then "$1" "${2:-}"; fi
