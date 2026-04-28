#!/bin/bash
set -e
source ./make.sh
source ./clickbench.sh

up

cb_download_partitioned_n 0

schema_fc
cb_create_table_fc
cb_copy_into_partitioned_n_fc 0

snowsql "SELECT COUNT(*) FROM embucket.public.hits;"

down
