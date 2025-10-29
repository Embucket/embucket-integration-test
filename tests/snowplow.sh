#!/bin/bash

source ./make.sh
source ./snowplow.sh

up
setup

sp_create_events
sp_create_incremental_manifest
sp_create_quarantined_sessions
sp_create_new_event_limits
sp_create_sessions_lifecycle_manifest

# ============================================
# Batch 1: Initial Load
# ============================================
echo ""
echo "=== BATCH 1: Initial Load ==="
echo ""

# Load first batch of events
echo "--- Loading first batch of events ---"
sp_copy_into_events1
snowsql "SELECT COUNT(*) as event_count FROM demo.embucket.events"

# Calculate time window for first run
echo ""
echo "--- Calculating time window (first run) ---"
sp_populate_new_event_limits
snowsql "SELECT lower_limit, upper_limit FROM demo.embucket.snowplow_web_base_new_event_limits"

# Initial population of lifecycle manifest
echo ""
echo "--- Merging sessions into lifecycle manifest ---"
sp_merge_sessions_lifecycle_manifest
snowsql "SELECT COUNT(*) as session_count FROM demo.embucket.snowplow_web_base_sessions_lifecycle_manifest"
snowsql "SELECT session_identifier, user_identifier, start_tstamp, end_tstamp FROM demo.embucket.snowplow_web_base_sessions_lifecycle_manifest ORDER BY start_tstamp LIMIT 5"

# Detect quarantined sessions
echo ""
echo "--- Detecting quarantined sessions (exceeding 3 days) ---"
sp_detect_quarantined_sessions
snowsql "SELECT COUNT(*) as quarantined_count FROM demo.embucket.snowplow_web_base_quarantined_sessions"

# Update incremental manifest
echo ""
echo "--- Updating incremental manifest ---"
sp_update_incremental_manifest
snowsql "SELECT model, last_success FROM demo.embucket.snowplow_web_incremental_manifest"

# ============================================
# Batch 2: Incremental Update
# ============================================
echo ""
echo "=== BATCH 2: Incremental Update ==="
echo ""

# Load second batch of events
echo "--- Loading second batch of events ---"
sp_copy_into_events2
snowsql "SELECT COUNT(*) as event_count FROM demo.embucket.events"

# Recalculate time window with lookback
echo ""
echo "--- Recalculating time window (with 6-hour lookback) ---"
sp_populate_new_event_limits
snowsql "SELECT lower_limit, upper_limit FROM demo.embucket.snowplow_web_base_new_event_limits"

# Incremental MERGE - update existing sessions and add new ones
echo ""
echo "--- Incremental MERGE: extending existing sessions + adding new sessions ---"
sp_merge_sessions_lifecycle_manifest
snowsql "SELECT COUNT(*) as session_count FROM demo.embucket.snowplow_web_base_sessions_lifecycle_manifest"
snowsql "SELECT session_identifier, user_identifier, start_tstamp, end_tstamp FROM demo.embucket.snowplow_web_base_sessions_lifecycle_manifest ORDER BY start_tstamp LIMIT 5"

# Detect newly quarantined sessions
echo ""
echo "--- Detecting quarantined sessions ---"
sp_detect_quarantined_sessions
snowsql "SELECT COUNT(*) as quarantined_count FROM demo.embucket.snowplow_web_base_quarantined_sessions"

# Update incremental manifest
echo ""
echo "--- Updating incremental manifest ---"
sp_update_incremental_manifest
snowsql "SELECT model, last_success FROM demo.embucket.snowplow_web_incremental_manifest"

# ============================================
# Final Verification
# ============================================
echo ""
echo "=== FINAL VERIFICATION ==="
echo ""
snowsql "SELECT COUNT(*) as total_sessions FROM demo.embucket.snowplow_web_base_sessions_lifecycle_manifest"
snowsql "SELECT COUNT(*) as total_quarantined FROM demo.embucket.snowplow_web_base_quarantined_sessions"
echo ""
echo "Test complete!"

down
