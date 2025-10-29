#!/bin/bash

export SNOWFLAKE_HOME=$(pwd)

source ./venv.sh

sp_create_events() {
  snow sql -q "CREATE TABLE demo.embucket.events (
    -- IMPORTANT: Column order MUST match CSV file order for COPY INTO to work correctly
    -- Core event identifiers
    app_id VARCHAR(255),
    platform VARCHAR(255),
    etl_tstamp TIMESTAMP,
    collector_tstamp TIMESTAMP,
    dvce_created_tstamp TIMESTAMP,
    event VARCHAR(128),
    event_id VARCHAR(36),
    txn_id INTEGER,
    name_tracker VARCHAR(128),
    v_tracker VARCHAR(100),
    v_collector VARCHAR(100),
    v_etl VARCHAR(100),

    -- User identifiers
    user_id VARCHAR(255),
    user_ipaddress VARCHAR(128),
    user_fingerprint VARCHAR(128),
    domain_userid VARCHAR(128),
    domain_sessionidx INTEGER,
    network_userid VARCHAR(128),

    -- Geo location
    geo_country VARCHAR(2),
    geo_region VARCHAR(3),
    geo_city VARCHAR(75),
    geo_zipcode VARCHAR(15),
    geo_latitude DOUBLE PRECISION,
    geo_longitude DOUBLE PRECISION,
    geo_region_name VARCHAR(100),

    -- IP information
    ip_isp VARCHAR(100),
    ip_organization VARCHAR(128),
    ip_domain VARCHAR(128),
    ip_netspeed VARCHAR(100),

    -- Page URL components
    page_url TEXT,
    page_title VARCHAR(2000),
    page_referrer TEXT,
    page_urlscheme VARCHAR(16),
    page_urlhost VARCHAR(255),
    page_urlport INTEGER,
    page_urlpath VARCHAR(3000),
    page_urlquery VARCHAR(6000),
    page_urlfragment VARCHAR(3000),

    -- Referrer URL components
    refr_urlscheme VARCHAR(16),
    refr_urlhost VARCHAR(255),
    refr_urlport INTEGER,
    refr_urlpath VARCHAR(6000),
    refr_urlquery VARCHAR(6000),
    refr_urlfragment VARCHAR(3000),
    refr_medium VARCHAR(25),
    refr_source VARCHAR(50),
    refr_term VARCHAR(255),

    -- Marketing parameters
    mkt_medium VARCHAR(255),
    mkt_source VARCHAR(255),
    mkt_term VARCHAR(255),
    mkt_content VARCHAR(500),
    mkt_campaign VARCHAR(255),

    -- Structured event fields
    se_category VARCHAR(1000),
    se_action VARCHAR(1000),
    se_label VARCHAR(4096),
    se_property VARCHAR(1000),
    se_value DOUBLE PRECISION,

    -- Ecommerce transaction
    tr_orderid VARCHAR(255),
    tr_affiliation VARCHAR(255),
    tr_total DOUBLE PRECISION,
    tr_tax DOUBLE PRECISION,
    tr_shipping DOUBLE PRECISION,
    tr_city VARCHAR(255),
    tr_state VARCHAR(255),
    tr_country VARCHAR(255),

    -- Ecommerce transaction item
    ti_orderid VARCHAR(255),
    ti_sku VARCHAR(255),
    ti_name VARCHAR(255),
    ti_category VARCHAR(255),
    ti_price DOUBLE PRECISION,
    ti_quantity INTEGER,

    -- Page ping
    pp_xoffset_min INTEGER,
    pp_xoffset_max INTEGER,
    pp_yoffset_min INTEGER,
    pp_yoffset_max INTEGER,

    -- Browser information
    useragent VARCHAR(1000),
    br_name VARCHAR(50),
    br_family VARCHAR(50),
    br_version VARCHAR(50),
    br_type VARCHAR(50),
    br_renderengine VARCHAR(50),
    br_lang VARCHAR(255),
    br_features_pdf BOOLEAN,
    br_features_flash BOOLEAN,
    br_features_java BOOLEAN,
    br_features_director BOOLEAN,
    br_features_quicktime BOOLEAN,
    br_features_realplayer BOOLEAN,
    br_features_windowsmedia BOOLEAN,
    br_features_gears BOOLEAN,
    br_features_silverlight BOOLEAN,
    br_cookies BOOLEAN,
    br_colordepth VARCHAR(12),
    br_viewwidth INTEGER,
    br_viewheight INTEGER,

    -- Operating system
    os_name VARCHAR(50),
    os_family VARCHAR(50),
    os_manufacturer VARCHAR(50),
    os_timezone VARCHAR(255),

    -- Device information
    dvce_type VARCHAR(50),
    dvce_ismobile BOOLEAN,
    dvce_screenwidth INTEGER,
    dvce_screenheight INTEGER,

    -- Document
    doc_charset VARCHAR(128),
    doc_width INTEGER,
    doc_height INTEGER,

    -- Ecommerce currency fields
    tr_currency VARCHAR(3),
    tr_total_base DOUBLE PRECISION,
    tr_tax_base DOUBLE PRECISION,
    tr_shipping_base DOUBLE PRECISION,
    ti_currency VARCHAR(3),
    ti_price_base DOUBLE PRECISION,

    -- Base currency
    base_currency VARCHAR(3),

    -- Geo timezone (different from os_timezone)
    geo_timezone VARCHAR(64),

    -- Marketing additional fields
    mkt_clickid VARCHAR(255),
    mkt_network VARCHAR(64),

    -- ETL
    etl_tags VARCHAR(500),

    -- Device sent timestamp
    dvce_sent_tstamp TIMESTAMP,

    -- Referrer additional fields
    refr_domain_userid VARCHAR(128),
    refr_dvce_tstamp TIMESTAMP,

    -- Session
    domain_sessionid VARCHAR(128),

    -- Derived timestamp
    derived_tstamp TIMESTAMP,

    -- Event schema
    event_vendor VARCHAR(1000),
    event_name VARCHAR(1000),
    event_format VARCHAR(128),
    event_version VARCHAR(20),
    event_fingerprint VARCHAR(128),

    -- True timestamp
    true_tstamp TIMESTAMP,

    -- Load timestamp
    load_tstamp TIMESTAMP,

    -- Context columns (JSON/TEXT) - order matters!
    contexts_com_snowplowanalytics_snowplow_web_page_1_0_0 TEXT,
    unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1_0_0 TEXT,
    unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1_0_0 TEXT,
    contexts_com_iab_snowplow_spiders_and_robots_1_0_0 TEXT,
    contexts_com_snowplowanalytics_snowplow_ua_parser_context_1_0_0 TEXT,
    contexts_nl_basjes_yauaa_context_1_0_0 TEXT
  );"
}

sp_copy_into_events1() {
  snow sql -q "COPY INTO demo.embucket.events FROM 'file:///storage/snowplow/source/snowplow_web_events1.csv' STORAGE_INTEGRATION = local FILE_FORMAT = (TYPE = CSV, SKIP_HEADER = 1);"
}

sp_copy_into_events2() {
  snow sql -q "COPY INTO demo.embucket.events FROM 'file:///storage/snowplow/source/snowplow_web_events2.csv' STORAGE_INTEGRATION = local FILE_FORMAT = (TYPE = CSV, SKIP_HEADER = 1);"
}

sp_create_incremental_manifest() {
  snow sql -q "CREATE TABLE demo.embucket.snowplow_web_incremental_manifest (
    model TEXT,
    last_success TIMESTAMP
  );"
}

sp_create_quarantined_sessions() {
  snow sql -q "CREATE TABLE demo.embucket.snowplow_web_base_quarantined_sessions (
    session_identifier TEXT
  );"
}

sp_create_new_event_limits() {
  snow sql -q "CREATE TABLE demo.embucket.snowplow_web_base_new_event_limits (
    lower_limit TIMESTAMP,
    upper_limit TIMESTAMP
  );"
}

sp_create_sessions_lifecycle_manifest() {
  snow sql -q "CREATE TABLE demo.embucket.snowplow_web_base_sessions_lifecycle_manifest (
    session_identifier TEXT,
    user_identifier TEXT,
    start_tstamp TIMESTAMP,
    end_tstamp TIMESTAMP
  );"
}

sp_populate_new_event_limits() {
  snow sql -q "
    -- Clear existing limits
    DELETE FROM demo.embucket.snowplow_web_base_new_event_limits;

    -- Calculate time window for this run
    INSERT INTO demo.embucket.snowplow_web_base_new_event_limits
    SELECT
      CASE
        -- First run: use earliest event timestamp
        WHEN (SELECT COUNT(*) FROM demo.embucket.snowplow_web_incremental_manifest
              WHERE model = 'snowplow_web_base_sessions_lifecycle_manifest') = 0
        THEN (SELECT MIN(collector_tstamp) FROM demo.embucket.events)
        -- Incremental run: use last_success - 6 hours lookback
        ELSE DATEADD(hour, -6,
          (SELECT last_success FROM demo.embucket.snowplow_web_incremental_manifest
           WHERE model = 'snowplow_web_base_sessions_lifecycle_manifest'))
      END as lower_limit,
      -- upper_limit is always the latest event timestamp
      (SELECT MAX(collector_tstamp) FROM demo.embucket.events) as upper_limit;
  "
}

sp_merge_sessions_lifecycle_manifest() {
  snow sql -q "
    MERGE INTO demo.embucket.snowplow_web_base_sessions_lifecycle_manifest AS target
    USING (
      SELECT
        COALESCE(e.domain_sessionid, NULL) as session_identifier,
        MAX(COALESCE(e.domain_userid, NULL)) as user_identifier,
        MIN(e.collector_tstamp) as start_tstamp,
        MAX(e.collector_tstamp) as end_tstamp
      FROM demo.embucket.events e
      CROSS JOIN demo.embucket.snowplow_web_base_new_event_limits limits
      WHERE e.domain_sessionid IS NOT NULL
        -- Time window filter: only process events within the calculated window
        AND e.collector_tstamp >= limits.lower_limit
        AND e.collector_tstamp <= limits.upper_limit
        -- Exclude quarantined sessions
        AND NOT EXISTS (
          SELECT 1 FROM demo.embucket.snowplow_web_base_quarantined_sessions q
          WHERE q.session_identifier = e.domain_sessionid
        )
      GROUP BY e.domain_sessionid
    ) AS source
    ON target.session_identifier = source.session_identifier
    -- Only update sessions that haven't exceeded max_session_days (3 days)
    WHEN MATCHED AND target.end_tstamp < DATEADD(day, 3, target.start_tstamp) THEN
      UPDATE SET
        -- Keep existing user_identifier if available, otherwise use new one
        user_identifier = COALESCE(target.user_identifier, source.user_identifier),
        -- Extend session backwards if late events arrive with earlier timestamps
        start_tstamp = LEAST(target.start_tstamp, source.start_tstamp),
        -- Extend session forwards with new events, but cap at max_session_days
        end_tstamp = LEAST(
          DATEADD(day, 3, target.start_tstamp),
          GREATEST(target.end_tstamp, source.end_tstamp)
        )
    WHEN NOT MATCHED THEN
      INSERT (session_identifier, user_identifier, start_tstamp, end_tstamp)
      VALUES (
        source.session_identifier,
        source.user_identifier,
        source.start_tstamp,
        -- Cap new sessions at max_session_days from the start
        LEAST(source.end_tstamp, DATEADD(day, 3, source.start_tstamp))
      );
  "
}

sp_update_incremental_manifest() {
  snow sql -q "
    MERGE INTO demo.embucket.snowplow_web_incremental_manifest AS target
    USING (
      SELECT
        'snowplow_web_base_sessions_lifecycle_manifest' as model,
        (SELECT upper_limit FROM demo.embucket.snowplow_web_base_new_event_limits) as last_success
    ) AS source
    ON target.model = source.model
    WHEN MATCHED THEN
      UPDATE SET last_success = source.last_success
    WHEN NOT MATCHED THEN
      INSERT (model, last_success)
      VALUES (source.model, source.last_success);
  "
}

sp_detect_quarantined_sessions() {
  snow sql -q "
    MERGE INTO demo.embucket.snowplow_web_base_quarantined_sessions AS target
    USING (
      -- Find sessions that have hit the max_session_days limit (3 days)
      SELECT session_identifier
      FROM demo.embucket.snowplow_web_base_sessions_lifecycle_manifest
      WHERE end_tstamp >= DATEADD(day, 3, start_tstamp)
    ) AS source
    ON target.session_identifier = source.session_identifier
    WHEN NOT MATCHED THEN
      INSERT (session_identifier)
      VALUES (source.session_identifier);
  "
}
