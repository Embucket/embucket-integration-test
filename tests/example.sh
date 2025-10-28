#!/bin/bash

source ./make.sh
source ./clickbench.sh

up
setup

clickbench_partitioned
clickbench_spark_partitioned

snowsql "SELECT watchid FROM demo.spark.hits LIMIT 100;"
sparksql "SELECT watchid FROM demo.embucket.hits LIMIT 100;"

equality demo.embucket.hits demo.spark.hits

down
