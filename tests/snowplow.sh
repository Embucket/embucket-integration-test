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
sp_create_sessions
sp_create_sessions_expected

# Load expected sessions from CSV
echo "--- Loading expected sessions from CSV ---"
sp_load_sessions_expected
snowsql "SELECT COUNT(*) as expected_session_count FROM demo.embucket.snowplow_web_sessions_expected"

# ============================================
# Batch 1: Initial Load
# ============================================
echo ""
echo "=== BATCH 1: Initial Load ==="
echo ""

# Load first batch of events
echo "--- Loading first batch of events ---"
sp_copy_into_events_n 1
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

# Build sessions from events
echo ""
echo "--- Building sessions from events ---"
sp_create_sessions_this_run
snowsql "SELECT COUNT(*) as sessions_this_run_count FROM demo.embucket.snowplow_web_sessions_this_run"

# Merge sessions into final table
echo ""
echo "--- Merging sessions into final table ---"
sp_merge_sessions
snowsql "SELECT COUNT(*) as session_count FROM demo.embucket.snowplow_web_sessions"
snowsql "SELECT domain_sessionid, start_tstamp, end_tstamp, page_views, total_events FROM demo.embucket.snowplow_web_sessions ORDER BY start_tstamp LIMIT 5"

# ============================================
# Batch 2: Incremental Update
# ============================================
echo ""
echo "=== BATCH 2: Incremental Update ==="
echo ""

# Load second batch of events
echo "--- Loading second batch of events ---"
sp_copy_into_events_n 2
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

# Build sessions from events
echo ""
echo "--- Building sessions from events (incremental) ---"
sp_create_sessions_this_run
snowsql "SELECT COUNT(*) as sessions_this_run_count FROM demo.embucket.snowplow_web_sessions_this_run"

# Merge sessions into final table
echo ""
echo "--- Merging sessions into final table (incremental) ---"
sp_merge_sessions
snowsql "SELECT COUNT(*) as session_count FROM demo.embucket.snowplow_web_sessions"
snowsql "SELECT domain_sessionid, start_tstamp, end_tstamp, page_views, total_events FROM demo.embucket.snowplow_web_sessions ORDER BY start_tstamp LIMIT 5"

# ============================================
# Final Verification
# ============================================
echo ""
echo "=== FINAL VERIFICATION ==="
echo ""

echo "--- Lifecycle Manifest ---"
snowsql "SELECT COUNT(*) as total_sessions FROM demo.embucket.snowplow_web_base_sessions_lifecycle_manifest"
snowsql "SELECT COUNT(*) as total_quarantined FROM demo.embucket.snowplow_web_base_quarantined_sessions"

echo ""
echo "--- Sessions Table ---"
snowsql "SELECT COUNT(*) as total_sessions FROM demo.embucket.snowplow_web_sessions"
snowsql "
  SELECT
    domain_sessionid,
    user_id,
    start_tstamp,
    end_tstamp,
    page_views,
    total_events,
    is_engaged,
    absolute_time_in_s
  FROM demo.embucket.snowplow_web_sessions
  ORDER BY start_tstamp
  LIMIT 10
"

echo ""
echo "--- Key Metrics Summary ---"
snowsql "
  SELECT
    COUNT(*) as total_sessions,
    COUNT(DISTINCT domain_userid) as unique_users,
    SUM(page_views) as total_page_views,
    SUM(total_events) as total_events,
    SUM(CASE WHEN is_engaged THEN 1 ELSE 0 END) as engaged_sessions,
    AVG(absolute_time_in_s) as avg_session_duration_s
  FROM demo.embucket.snowplow_web_sessions
"

# ============================================
# Comparison with Expected Results
# ============================================
echo ""
echo "=== COMPARISON WITH EXPECTED RESULTS ==="
echo ""

echo "--- Session Count Comparison ---"
snowsql "
  SELECT
    'Computed' as source,
    COUNT(*) as session_count
  FROM demo.embucket.snowplow_web_sessions
  UNION ALL
  SELECT
    'Expected' as source,
    COUNT(*) as session_count
  FROM demo.embucket.snowplow_web_sessions_expected
"

echo ""
echo "--- Common Sessions Check ---"
snowsql "
  WITH computed_sessions AS (
    SELECT domain_sessionid FROM demo.embucket.snowplow_web_sessions
  ),
  expected_sessions AS (
    SELECT domain_sessionid FROM demo.embucket.snowplow_web_sessions_expected
  )
  SELECT
    COUNT(DISTINCT c.domain_sessionid) as sessions_in_both,
    (SELECT COUNT(*) FROM computed_sessions) as total_computed,
    (SELECT COUNT(*) FROM expected_sessions) as total_expected,
    (SELECT COUNT(*) FROM computed_sessions WHERE domain_sessionid NOT IN (SELECT domain_sessionid FROM expected_sessions)) as only_in_computed,
    (SELECT COUNT(*) FROM expected_sessions WHERE domain_sessionid NOT IN (SELECT domain_sessionid FROM computed_sessions)) as only_in_expected
  FROM computed_sessions c
  INNER JOIN expected_sessions e ON c.domain_sessionid = e.domain_sessionid
"

echo ""
echo "--- Field-by-Field Comparison (Common Sessions) ---"
snowsql "
  SELECT
    c.domain_sessionid,
    c.user_id as computed_user_id,
    e.user_id as expected_user_id,
    c.start_tstamp as computed_start,
    e.start_tstamp as expected_start,
    c.end_tstamp as computed_end,
    e.end_tstamp as expected_end,
    c.page_views as computed_pv,
    e.page_views as expected_pv,
    c.total_events as computed_events,
    e.total_events as expected_events,
    c.is_engaged as computed_engaged,
    e.is_engaged as expected_engaged
  FROM demo.embucket.snowplow_web_sessions c
  INNER JOIN demo.embucket.snowplow_web_sessions_expected e
    ON c.domain_sessionid = e.domain_sessionid
  WHERE
    c.page_views != e.page_views
    OR c.total_events != e.total_events
    OR COALESCE(c.is_engaged, FALSE) != COALESCE(e.is_engaged, FALSE)
  ORDER BY c.start_tstamp
  LIMIT 10
"

echo ""
echo "--- Summary of Differences ---"
snowsql "
  WITH compared AS (
    SELECT
      c.domain_sessionid,
      CASE WHEN c.user_id != e.user_id THEN 1 ELSE 0 END as user_id_diff,
      CASE WHEN c.start_tstamp != e.start_tstamp THEN 1 ELSE 0 END as start_diff,
      CASE WHEN c.end_tstamp != e.end_tstamp THEN 1 ELSE 0 END as end_diff,
      CASE WHEN c.page_views != e.page_views THEN 1 ELSE 0 END as pv_diff,
      CASE WHEN c.total_events != e.total_events THEN 1 ELSE 0 END as events_diff,
      CASE WHEN COALESCE(c.is_engaged, FALSE) != COALESCE(e.is_engaged, FALSE) THEN 1 ELSE 0 END as engaged_diff,
      CASE WHEN c.first_page_url != e.first_page_url THEN 1 ELSE 0 END as first_url_diff,
      CASE WHEN c.last_page_url != e.last_page_url THEN 1 ELSE 0 END as last_url_diff
    FROM demo.embucket.snowplow_web_sessions c
    INNER JOIN demo.embucket.snowplow_web_sessions_expected e
      ON c.domain_sessionid = e.domain_sessionid
  )
  SELECT
    COUNT(*) as total_compared_sessions,
    SUM(user_id_diff) as user_id_mismatches,
    SUM(start_diff) as start_tstamp_mismatches,
    SUM(end_diff) as end_tstamp_mismatches,
    SUM(pv_diff) as page_views_mismatches,
    SUM(events_diff) as total_events_mismatches,
    SUM(engaged_diff) as is_engaged_mismatches,
    SUM(first_url_diff) as first_url_mismatches,
    SUM(last_url_diff) as last_url_mismatches
  FROM compared
"

echo ""
echo "Test complete!"

down
