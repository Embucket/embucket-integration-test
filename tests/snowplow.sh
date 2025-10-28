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

# Load first batch of events
echo "=== Loading first batch of events ==="
sp_copy_into_events1
snowsql "SELECT COUNT(*) as event_count FROM demo.embucket.events"

# Initial population of lifecycle manifest
echo "=== Initial population of lifecycle manifest ==="
sp_merge_sessions_lifecycle_manifest
snowsql "SELECT COUNT(*) as session_count FROM demo.embucket.snowplow_web_base_sessions_lifecycle_manifest"
snowsql "SELECT session_identifier, user_identifier, start_tstamp, end_tstamp FROM demo.embucket.snowplow_web_base_sessions_lifecycle_manifest LIMIT 5"

# Load second batch of events (for incremental testing)
echo "=== Loading second batch of events ==="
sp_copy_into_events2
snowsql "SELECT COUNT(*) as event_count FROM demo.embucket.events"

# Incremental MERGE - update existing sessions and add new ones
echo "=== Incremental MERGE into lifecycle manifest ==="
sp_merge_sessions_lifecycle_manifest
snowsql "SELECT COUNT(*) as session_count FROM demo.embucket.snowplow_web_base_sessions_lifecycle_manifest"
snowsql "SELECT session_identifier, user_identifier, start_tstamp, end_tstamp FROM demo.embucket.snowplow_web_base_sessions_lifecycle_manifest LIMIT 5"

snowsql "SHOW TABLES IN demo.embucket"
