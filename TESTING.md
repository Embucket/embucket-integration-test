# Test Suite Documentation

This document provides detailed information about the test suite for the Embucket Integration Test Framework.

## Overview

The test suite is located in the `tests/` directory and includes various integration tests and benchmarks for validating Embucket functionality against industry-standard datasets and use cases.

## Test Files

### tests/example.sh

**Purpose:** Basic integration test demonstrating the standard test workflow.

**What it tests:**
- Docker service startup
- Database and schema initialization
- ClickBench data loading (partitioned)
- Spark Iceberg table creation
- Query execution on both Embucket and Spark
- Data equality verification between catalogs

**Usage:**
```bash
sh tests/example.sh
```

**Flow:**
1. Start Docker services with `up`
2. Initialize database with `setup`
3. Load ClickBench partitioned data
4. Create corresponding Spark tables
5. Run sample queries on both catalogs
6. Verify data equality
7. Clean up with `down`

**When to use:** As a template for creating new integration tests or for quick validation that the basic framework is working correctly.

---

### tests/clickbench.sh

**Purpose:** Comprehensive ClickBench benchmark test.

**What it tests:**
- Full ClickBench dataset loading
- All 43 ClickBench query execution
- Performance measurement and benchmarking
- Embucket's web analytics query performance

**Usage:**
```bash
sh tests/clickbench.sh
```

**Data:**
- Uses 100 partitioned parquet files
- Total dataset: ~100 million rows
- Queries: 43 web analytics queries from clickbench/queries.sql

**Output:**
- Query execution times
- Results saved to clickbench/results.csv

**When to use:** For comprehensive performance testing of Embucket against the ClickBench standard or when validating web analytics query patterns.

---

### tests/clickbench_file.sh

**Purpose:** Test file-based storage integration (local filesystem) instead of S3.

**What it tests:**
- File-based external volume creation
- Data loading from local filesystem paths
- Comparison with S3-based loading approach

**Usage:**
```bash
sh tests/clickbench_file.sh
```

**Key difference:** Uses `volume_file` and `database_file` commands from make.sh instead of the S3-based equivalents.

**When to use:**
- Testing file-based storage backends
- Validating that Embucket works with local filesystem access
- Comparing performance between S3 and file-based ingestion

---

### tests/tpch.sh

**Purpose:** TPC-H decision support benchmark test.

**What it tests:**
- TPC-H data loading (scale factor 10 or 100)
- All 22 TPC-H query execution
- Complex join and aggregation performance
- Business intelligence query patterns

**Usage:**
```bash
sh tests/tpch.sh
```

**Data:**
- Scale factor 10: ~10GB of data
- Scale factor 100: ~100GB of data
- Queries: 22 TPC-H decision support queries

**Output:**
- Query execution times
- Results saved to tpch/results.csv

**When to use:**
- Comprehensive performance testing of decision support workloads
- Validating complex joins, aggregations, and analytical queries
- Comparing Embucket performance against TPC-H standards

---

### tests/merge.sh

**Purpose:** Test MERGE (upsert) operations.

**What it tests:**
- MERGE statement functionality
- Update and insert operations in a single statement
- Data consistency after MERGE operations
- Incremental data loading patterns

**Usage:**
```bash
sh tests/merge.sh
```

**What it validates:**
- Correct handling of matching rows (updates)
- Correct handling of non-matching rows (inserts)
- Data integrity after merge operations

**When to use:**
- Testing incremental data loading workflows
- Validating MERGE statement compatibility
- Testing upsert patterns common in data warehousing

---

## Python Helper Scripts

Located in the `scripts/` directory, these scripts assist with Iceberg table creation for Spark compatibility testing.

### scripts/create_iceberg.py

**Purpose:** Create a single Iceberg table from the ClickBench data.

**Usage:**
```bash
python scripts/create_iceberg.py
```

**What it does:**
- Connects to Spark with Iceberg catalog support
- Creates a single Iceberg table from ClickBench data
- Used for comparing Embucket against Spark Iceberg

---

### scripts/create_iceberg_partitioned.py

**Purpose:** Create partitioned Iceberg tables from ClickBench data.

**Usage:**
```bash
python scripts/create_iceberg_partitioned.py
```

**What it does:**
- Creates partitioned Iceberg tables
- Uses the same partitioning scheme as the source data
- Enables partition pruning tests and performance comparisons

---

## Test Workflow Guidelines

### Standard Test Structure

Most tests follow this pattern:

```bash
#!/bin/bash
source ./make.sh
source ./clickbench.sh  # or tpch.sh

# 1. Start infrastructure
up

# 2. Initialize database
setup

# 3. Load test data
clickbench_partitioned  # or other data loading function

# 4. Run test operations
# Your test-specific logic here

# 5. Verify results
equality table1 table2  # or custom verification

# 6. Cleanup
down
```

### Creating Custom Tests

To create a new test:

1. Copy an existing test as a template:
   ```bash
   cp tests/example.sh tests/my_test.sh
   ```

2. Source the required script libraries:
   ```bash
   source ./make.sh
   source ./clickbench.sh  # and/or tpch.sh
   ```

3. Implement your test logic following the standard structure

4. Make the test executable:
   ```bash
   chmod +x tests/my_test.sh
   ```

5. Run your test:
   ```bash
   sh tests/my_test.sh
   ```

---

## Benchmarking

### Running Benchmarks

**ClickBench:**
```bash
# After loading data
sh clickbench.sh benchmark
```

**TPC-H:**
```bash
# After loading data
sh tpch.sh benchmark
```

### Interpreting Results

Benchmark results are saved to CSV files:
- `clickbench/results.csv` - ClickBench query timings
- `tpch/results.csv` - TPC-H query timings

Format:
```csv
query_number,execution_time_seconds,status
1,0.234,success
2,0.567,success
```

### Performance Considerations

- **First run:** May be slower due to cold caches
- **Subsequent runs:** Typically faster due to warm caches
- **Scale factors:** Higher scale factors (TPC-H 100 vs 10) significantly impact query times
- **Partitioning:** Partitioned data may improve query performance with partition pruning

---

## Troubleshooting

### Common Issues

**Test fails at Docker startup:**
- Check that Docker is running: `docker ps`
- Check port conflicts: Ensure ports 3000, 9000, 9001, 8474 are available
- Review Docker logs: `docker-compose logs`

**Data loading fails:**
- Verify data exists in correct directory (`clickbench/` or `tpch/`)
- Check MinIO is running: `docker ps | grep minio`
- Verify S3 credentials are set: `source s3.sh && echo $AWS_ACCESS_KEY_ID`

**Query execution fails:**
- Check Embucket is running: `docker ps | grep embucket`
- Verify connection: `sh make.sh snowsql "SELECT 1"`
- Check Snowflake CLI is installed: `snow --version`

**Data equality check fails:**
- Expected for some test scenarios (different data representations)
- Investigate with manual queries to understand differences
- Check for precision/data type mismatches

---

## Advanced Testing Patterns

### Testing Storage Backends

Compare S3 vs file-based storage:
```bash
# S3-based (default)
sh tests/example.sh

# File-based
sh tests/clickbench_file.sh
```

### Testing Different Data Sizes

For ClickBench:
```bash
# Small dataset (first partition only)
sh clickbench.sh clickbench_partitioned_small

# Full dataset (all 100 partitions)
sh clickbench.sh clickbench_partitioned
```

For TPC-H:
```bash
# Smaller scale (10GB)
sh tpch.sh load 10

# Larger scale (100GB)
sh tpch.sh load 100
```

### Testing Cross-Catalog Queries

```bash
# Create tables in both Embucket and Spark
clickbench_partitioned
clickbench_spark_partitioned

# Query both catalogs
snowsql "SELECT COUNT(*) FROM demo.embucket.hits"
sparksql "SELECT COUNT(*) FROM demo.spark.hits"

# Verify equality
equality demo.embucket.hits demo.spark.hits
```

---

## Continuous Integration

For CI/CD pipelines, consider:

1. **Quick smoke test:**
   ```bash
   sh tests/example.sh
   ```

2. **Comprehensive benchmark:**
   ```bash
   sh tests/clickbench.sh && sh tests/tpch.sh
   ```

3. **Clean up:**
   ```bash
   sh make.sh down
   ```

4. **Resource monitoring:**
   - Monitor Docker container memory and CPU usage
   - Track query execution times over builds
   - Alert on performance regressions
