#!/bin/bash

source ./make.sh
source ./tpch.sh

up
setup

tpch_setup

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

down
