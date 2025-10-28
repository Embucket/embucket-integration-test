source ./make.sh
source ./clickbench.sh

up
setup

clickbench_setup_partitioned

echo "query_number,execution_time_seconds" >clickbench/results.csv
query_num=1
cat clickbench/queries.sql | while read -r query; do
  if [[ -n "$query" && ! "$query" =~ ^[[:space:]]*$ ]]; then
    start_time=$(date +%s.%N)
    snowsql "$query"
    end_time=$(date +%s.%N)
    execution_time=$(awk "BEGIN {print $end_time - $start_time}")
    echo "$query_num,$execution_time" >>clickbench/results.csv
    query_num=$((query_num + 1))
  fi
done

down
