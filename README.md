# Embucket Integration Test Framework

This project provides a comprehensive test framework for running integration tests and benchmarks on Embucket (a Snowflake-compatible database) using industry-standard datasets: ClickBench and TPC-H.

## Overview

The test framework consists of three main scripts:

- `make.sh` - Core utilities for database setup, Docker management, and data operations
- `clickbench.sh` - ClickBench dataset management and benchmarking
- `tpch.sh` - TPC-H dataset management and benchmarking

## Architecture

The framework uses Docker Compose to orchestrate the following services:

- **Embucket** (port 3000) - The main database being tested, Snowflake-compatible interface
- **MinIO** (ports 9000, 9001) - S3-compatible object storage for testing cloud data integration
- **Toxiproxy** (port 8474) - Network proxy for simulating latency and failures
- **MC** (MinIO Client) - Automated MinIO bucket setup

All data is stored in the `storage/` directory, which is mounted into Docker containers and gitignored.

## Prerequisites

- Docker and Docker Compose
- Python with virtual environment support
- Snowflake CLI

## Quick Start

1. Start Docker services:

   ```bash
   sh make.sh up
   ```

2. Initialize database and schema:

   ```bash
   sh make.sh setup
   ```

3. Load benchmark data (choose one):

   **ClickBench (web analytics benchmark):**

   ```bash
   sh clickbench.sh clickbench_partitioned
   ```

   **TPC-H (decision support benchmark):**

   ```bash
   # First, manually place TPC-H parquet files in storage/tpch/100/
   sh tpch.sh tpch_setup
   ```

## Core Commands

### make.sh Commands

- `sh make.sh install_snowflake` - Install Snowflake CLI
- `sh make.sh up` - Start Docker Compose services
- `sh make.sh down` - Stop Docker Compose services
- `sh make.sh volume` - Create S3-based external volume
- `sh make.sh volume_file` - Create file-based external volume
- `sh make.sh database` - Create demo database
- `sh make.sh schema` - Create schema
- `sh make.sh setup` - Run complete database, schema setup
- `sh make.sh snowsql "query"` - Execute Snowflake SQL
- `sh make.sh sparksql "query"` - Execute Spark SQL
- `sh make.sh equality table1 table2` - Compare data between tables

### clickbench.sh Commands

- `sh clickbench.sh cp_download_partitioned` - Download partitioned ClickBench data
- `sh clickbench.sh cb_download_single` - Download single ClickBench file
- `sh clickbench.sh cb_create_table` - Create ClickBench table schema
- `sh clickbench.sh cb_copy_into_partitioned` - Load partitioned data
- `sh clickbench.sh cb_copy_into_single` - Load single file data
- `sh clickbench.sh clickbench_partitioned` - Full partitioned setup
- `sh clickbench.sh clickbench_single` - Full single file setup
- `sh clickbench.sh clickbench_spark_partitioned` - Create Spark Iceberg table
- `sh clickbench.sh benchmark` - Run ClickBench queries and measure performance

### tpch.sh Commands

- `sh tpch.sh volume_local_file` - Create local file-based external volume
- `sh tpch.sh tpch_create_tables` - Create all TPC-H table schemas
- `sh tpch.sh tpch_copy_into_tables` - Load data from mounted storage (/storage/tpch/100/)
- `sh tpch.sh tpch_copy_into_tables_file` - Load data from local filesystem (tpch/100/)
- `sh tpch.sh tpch_setup` - Create tables and load data (complete setup)
- `sh tpch.sh benchmark` - Run TPC-H queries from tpch/queries/ and measure performance

**Data Preparation:**
TPC-H data must be manually placed in the `storage/tpch/100/` or `tpch/100/` directory as Parquet files. The script expects these files:

- customer.parquet
- orders.parquet
- lineitem.parquet
- nation.parquet
- region.parquet
- part.parquet
- supplier.parquet
- partsupp.parquet

**Example Usage:**

```bash
# Ensure TPC-H data files are in place
# (manually copy parquet files to storage/tpch/100/ or tpch/100/)

# Create tables and load data
sh tpch.sh tpch_setup

# Run benchmark
sh tpch.sh benchmark
```

## Creating Test Files

Test files should follow the pattern in `tests/example.sh`:

```bash
#!/bin/bash
source ./make.sh
source ./clickbench.sh

# Start services
up

# Initialize Snowflake
setup

# Load test data
clickbench_partitioned
clickbench_spark_partitioned

# Run test queries
snowsql "SELECT watchid FROM demo.spark.hits LIMIT 100;"
sparksql "SELECT watchid FROM demo.embucket.hits LIMIT 100;"

# Verify data equality
equality demo.embucket.hits demo.spark.hits

# Cleanup
down
```

### Test File Structure

1. **Start services** - Use `sh make.sh up` to start Docker containers
2. **Initialize** - Run `sh make.sh setup` to create Snowflake resources
3. **Load data** - Choose appropriate data loading function
4. **Execute tests** - Run your specific test queries
5. **Verify results** - Use `sh make.sh equality` or custom validation
6. **Cleanup** - Use `sh make.sh down` to stop services

### Available Data Loading Options

- `sh clickbench.sh clickbench_partitioned` - Load all 100 partitioned files
- `sh clickbench.sh clickbench_partitioned_small` - Load only first partition for testing
- `sh clickbench.sh clickbench_single` - Load single large file
- `sh clickbench.sh clickbench_spark_partitioned` - Create corresponding Spark tables

## Storage Configuration

Two storage types are configured:

- **S3 storage** (`mybucket`) - MinIO-based object storage
- **File storage** (`local`) - Local filesystem access

Both point to the same data location for testing different ingestion paths.

## Usage Examples

### Basic Integration Test

```bash
sh tests/example.sh
```

### Custom Test Creation

```bash
# Create new test file
cp tests/example.sh tests/my_test.sh
# Edit to add your specific test logic
# Run your test
sh tests/my_test.sh
```

### Manual Operations

```bash
# Start only the infrastructure
sh make.sh up
sh make.sh setup

# Load specific dataset
sh clickbench.sh clickbench_single

# Run custom queries
sh make.sh snowsql "SELECT COUNT(*) FROM demo.embucket.hits"
sh make.sh sparksql "SELECT COUNT(*) FROM demo.spark.hits"

# Compare results
sh make.sh equality demo.embucket.hits demo.spark.hits

# Cleanup
sh make.sh down
```

## Configuration Files

### config.toml

Snowflake CLI configuration pointing to the local Embucket instance:

```toml
[connections.dev]
host = "localhost"
port = 3000
user = "user"
password = "password"
database = "demo"
schema = "embucket"
warehouse = "warehouse"
```

### docker-compose.yaml

Defines all services (Embucket, MinIO, Toxiproxy, MC) with port mappings and volume mounts to the `storage/` directory.

### s3.sh

Sets environment variables for S3/MinIO access:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`

Source this file with `. ./s3.sh` when needed for manual S3 operations.

## Test Suite

For detailed information about the test suite and available test scripts, see [TESTING.md](TESTING.md).

Available test files:

- `tests/example.sh` - Basic integration test
- `tests/clickbench.sh` - ClickBench benchmark
- `tests/clickbench_file.sh` - File-based storage test
- `tests/tpch.sh` - TPC-H benchmark
- `tests/merge.sh` - MERGE operations test

## Environment Variables

The scripts automatically handle:

- `SNOWFLAKE_HOME` - Set to current project directory
- Virtual environment activation via `venv.sh`
