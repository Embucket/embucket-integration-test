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

sp_copy_into_events_n() {
  local n=$1
  snow sql -q "COPY INTO demo.embucket.events FROM 'file:///storage/snowplow/source/snowplow_web_events$n.csv' STORAGE_INTEGRATION = local FILE_FORMAT = (TYPE = CSV, SKIP_HEADER = 1);"
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

sp_create_sessions() {
  snow sql -q "CREATE TABLE demo.embucket.snowplow_web_sessions (
    -- Core identifiers
    app_id VARCHAR(255),
    platform VARCHAR(255),
    domain_sessionid VARCHAR(128) PRIMARY KEY,
    original_domain_sessionid VARCHAR(128),
    domain_sessionidx INTEGER,

    -- Timestamps
    start_tstamp TIMESTAMP,
    end_tstamp TIMESTAMP,

    -- User identifiers
    user_id VARCHAR(255),
    domain_userid VARCHAR(128),
    original_domain_userid VARCHAR(128),
    stitched_user_id VARCHAR(255),
    network_userid VARCHAR(128),

    -- Engagement metrics
    page_views INTEGER,
    engaged_time_in_s INTEGER,
    total_events INTEGER,
    is_engaged BOOLEAN,
    absolute_time_in_s INTEGER,

    -- First page attributes
    first_page_title VARCHAR(2000),
    first_page_url TEXT,
    first_page_urlscheme VARCHAR(16),
    first_page_urlhost VARCHAR(255),
    first_page_urlpath VARCHAR(3000),
    first_page_urlquery VARCHAR(6000),
    first_page_urlfragment VARCHAR(3000),

    -- Last page attributes
    last_page_title VARCHAR(2000),
    last_page_url TEXT,
    last_page_urlscheme VARCHAR(16),
    last_page_urlhost VARCHAR(255),
    last_page_urlpath VARCHAR(3000),
    last_page_urlquery VARCHAR(6000),
    last_page_urlfragment VARCHAR(3000),

    -- Referrer attributes
    referrer TEXT,
    refr_urlscheme VARCHAR(16),
    refr_urlhost VARCHAR(255),
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
    mkt_clickid VARCHAR(255),
    mkt_network VARCHAR(64),
    mkt_source_platform VARCHAR(255),
    default_channel_group VARCHAR(255),

    -- Geo attributes (first event)
    geo_country VARCHAR(2),
    geo_region VARCHAR(3),
    geo_region_name VARCHAR(100),
    geo_city VARCHAR(75),
    geo_zipcode VARCHAR(15),
    geo_latitude DOUBLE PRECISION,
    geo_longitude DOUBLE PRECISION,
    geo_timezone VARCHAR(64),

    -- Geo attributes (last event)
    last_geo_country VARCHAR(2),
    last_geo_region_name VARCHAR(100),
    last_geo_city VARCHAR(75),

    -- Device/Browser attributes
    user_ipaddress VARCHAR(128),
    useragent VARCHAR(1000),
    br_renderengine VARCHAR(50),
    br_lang VARCHAR(255),
    os_timezone VARCHAR(255),
    screen_resolution VARCHAR(50)
  );"
}

sp_populate_new_event_limits() {
  snow sql -q "
    CREATE OR REPLACE TABLE demo.embucket.snowplow_web_base_new_event_limits AS
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

sp_create_sessions_this_run() {
  snow sql -q "
    CREATE OR REPLACE TABLE demo.embucket.snowplow_web_sessions_this_run AS
    WITH session_firsts AS (
      -- Get first event attributes for each session
      SELECT
        domain_sessionid,
        app_id,
        platform,
        domain_sessionidx,
        user_id,
        domain_userid,
        network_userid,

        -- First page attributes
        page_title AS first_page_title,
        page_url AS first_page_url,
        page_urlscheme AS first_page_urlscheme,
        page_urlhost AS first_page_urlhost,
        page_urlpath AS first_page_urlpath,
        page_urlquery AS first_page_urlquery,
        page_urlfragment AS first_page_urlfragment,

        -- Referrer attributes (from first event)
        page_referrer AS referrer,
        refr_urlscheme,
        refr_urlhost,
        refr_urlpath,
        refr_urlquery,
        refr_urlfragment,
        refr_medium,
        refr_source,
        refr_term,

        -- Marketing parameters (from first event)
        mkt_medium,
        mkt_source,
        mkt_term,
        mkt_content,
        mkt_campaign,
        mkt_clickid,
        mkt_network,

        -- Extract mkt_source_platform from URL query
        REGEXP_SUBSTR(page_urlquery, 'utm_source_platform=([^?&#]*)', 1, 1, 'e', 1) AS mkt_source_platform,

        -- Geo attributes (first event)
        geo_country,
        geo_region,
        geo_region_name,
        geo_city,
        geo_zipcode,
        geo_latitude,
        geo_longitude,
        geo_timezone,

        -- Device/Browser attributes (first event)
        user_ipaddress,
        useragent,
        br_renderengine,
        br_lang,
        os_timezone,
        CONCAT(COALESCE(dvce_screenwidth, ''), 'x', COALESCE(dvce_screenheight, '')) AS screen_resolution
      FROM demo.embucket.events
      WHERE domain_sessionid IS NOT NULL
      QUALIFY ROW_NUMBER() OVER (
        PARTITION BY domain_sessionid
        ORDER BY collector_tstamp, dvce_created_tstamp, event_id
      ) = 1
    ),
    session_lasts AS (
      -- Get last page view attributes for each session
      SELECT
        domain_sessionid,

        -- Last page attributes
        page_title AS last_page_title,
        page_url AS last_page_url,
        page_urlscheme AS last_page_urlscheme,
        page_urlhost AS last_page_urlhost,
        page_urlpath AS last_page_urlpath,
        page_urlquery AS last_page_urlquery,
        page_urlfragment AS last_page_urlfragment,

        -- Last geo attributes
        geo_country AS last_geo_country,
        geo_region_name AS last_geo_region_name,
        geo_city AS last_geo_city
      FROM demo.embucket.events
      WHERE domain_sessionid IS NOT NULL
        AND event = 'page_view'
      QUALIFY ROW_NUMBER() OVER (
        PARTITION BY domain_sessionid
        ORDER BY collector_tstamp DESC, dvce_created_tstamp DESC, event_id DESC
      ) = 1
    ),
    session_aggs AS (
      -- Aggregate metrics for each session
      SELECT
        domain_sessionid,
        MIN(collector_tstamp) AS start_tstamp,
        MAX(collector_tstamp) AS end_tstamp,
        COUNT(*) AS total_events,
        COUNT(DISTINCT CASE WHEN event = 'page_view' THEN event_id END) AS page_views,
        TIMESTAMPDIFF(SECOND, MIN(collector_tstamp), MAX(collector_tstamp)) AS absolute_time_in_s
      FROM demo.embucket.events
      WHERE domain_sessionid IS NOT NULL
      GROUP BY domain_sessionid
    )
    SELECT
      -- Core identifiers
      f.app_id,
      f.platform,
      f.domain_sessionid,
      f.domain_sessionid AS original_domain_sessionid,
      f.domain_sessionidx,

      -- Timestamps
      a.start_tstamp,
      a.end_tstamp,

      -- User identifiers
      f.user_id,
      f.domain_userid,
      f.domain_userid AS original_domain_userid,
      f.user_id AS stitched_user_id,
      f.network_userid,

      -- Engagement metrics
      a.page_views,
      0 AS engaged_time_in_s,  -- Simplified: requires page_ping calculation
      a.total_events,
      (a.page_views >= 2 OR a.absolute_time_in_s >= 10) AS is_engaged,
      a.absolute_time_in_s,

      -- First page attributes
      f.first_page_title,
      f.first_page_url,
      f.first_page_urlscheme,
      f.first_page_urlhost,
      f.first_page_urlpath,
      f.first_page_urlquery,
      f.first_page_urlfragment,

      -- Last page attributes (fallback to first if no last)
      COALESCE(l.last_page_title, f.first_page_title) AS last_page_title,
      COALESCE(l.last_page_url, f.first_page_url) AS last_page_url,
      COALESCE(l.last_page_urlscheme, f.first_page_urlscheme) AS last_page_urlscheme,
      COALESCE(l.last_page_urlhost, f.first_page_urlhost) AS last_page_urlhost,
      COALESCE(l.last_page_urlpath, f.first_page_urlpath) AS last_page_urlpath,
      COALESCE(l.last_page_urlquery, f.first_page_urlquery) AS last_page_urlquery,
      COALESCE(l.last_page_urlfragment, f.first_page_urlfragment) AS last_page_urlfragment,

      -- Referrer attributes
      f.referrer,
      f.refr_urlscheme,
      f.refr_urlhost,
      f.refr_urlpath,
      f.refr_urlquery,
      f.refr_urlfragment,
      f.refr_medium,
      f.refr_source,
      f.refr_term,

      -- Marketing parameters
      f.mkt_medium,
      f.mkt_source,
      f.mkt_term,
      f.mkt_content,
      f.mkt_campaign,
      f.mkt_clickid,
      f.mkt_network,
      f.mkt_source_platform,
      'Unassigned' AS default_channel_group,  -- Simplified: requires complex GA4 logic

      -- Geo attributes (first event)
      f.geo_country,
      f.geo_region,
      f.geo_region_name,
      f.geo_city,
      f.geo_zipcode,
      f.geo_latitude,
      f.geo_longitude,
      f.geo_timezone,

      -- Geo attributes (last event)
      COALESCE(l.last_geo_country, f.geo_country) AS last_geo_country,
      COALESCE(l.last_geo_region_name, f.geo_region_name) AS last_geo_region_name,
      COALESCE(l.last_geo_city, f.geo_city) AS last_geo_city,

      -- Device/Browser attributes
      f.user_ipaddress,
      f.useragent,
      f.br_renderengine,
      f.br_lang,
      f.os_timezone,
      f.screen_resolution
    FROM session_firsts f
    LEFT JOIN session_lasts l ON f.domain_sessionid = l.domain_sessionid
    LEFT JOIN session_aggs a ON f.domain_sessionid = a.domain_sessionid;
  "
}

sp_create_sessions_expected() {
  snow sql -q "CREATE TABLE demo.embucket.snowplow_web_sessions_expected (
    -- Core identifiers (1-5)
    app_id VARCHAR(255),
    platform VARCHAR(255),
    domain_sessionid VARCHAR(128) PRIMARY KEY,
    original_domain_sessionid VARCHAR(128),
    domain_sessionidx INTEGER,

    -- Timestamps (6-7)
    start_tstamp TIMESTAMP,
    end_tstamp TIMESTAMP,

    -- User identifiers (8-12)
    user_id VARCHAR(255),
    domain_userid VARCHAR(128),
    original_domain_userid VARCHAR(128),
    stitched_user_id VARCHAR(255),
    network_userid VARCHAR(128),

    -- Engagement metrics (13-18)
    page_views INTEGER,
    engaged_time_in_s INTEGER,
    event_counts VARCHAR(10000),
    total_events INTEGER,
    is_engaged BOOLEAN,
    absolute_time_in_s INTEGER,

    -- First page attributes (19-25)
    first_page_title VARCHAR(2000),
    first_page_url TEXT,
    first_page_urlscheme VARCHAR(16),
    first_page_urlhost VARCHAR(255),
    first_page_urlpath VARCHAR(3000),
    first_page_urlquery VARCHAR(6000),
    first_page_urlfragment VARCHAR(3000),

    -- Last page attributes (26-32)
    last_page_title VARCHAR(2000),
    last_page_url TEXT,
    last_page_urlscheme VARCHAR(16),
    last_page_urlhost VARCHAR(255),
    last_page_urlpath VARCHAR(3000),
    last_page_urlquery VARCHAR(6000),
    last_page_urlfragment VARCHAR(3000),

    -- Referrer attributes (33-41)
    referrer TEXT,
    refr_urlscheme VARCHAR(16),
    refr_urlhost VARCHAR(255),
    refr_urlpath VARCHAR(6000),
    refr_urlquery VARCHAR(6000),
    refr_urlfragment VARCHAR(3000),
    refr_medium VARCHAR(25),
    refr_source VARCHAR(50),
    refr_term VARCHAR(255),

    -- Marketing parameters (42-50)
    mkt_medium VARCHAR(255),
    mkt_source VARCHAR(255),
    mkt_term VARCHAR(255),
    mkt_content VARCHAR(500),
    mkt_campaign VARCHAR(255),
    mkt_clickid VARCHAR(255),
    mkt_network VARCHAR(64),
    mkt_source_platform VARCHAR(255),
    default_channel_group VARCHAR(255),

    -- Geo attributes (51-65)
    geo_country VARCHAR(2),
    geo_region VARCHAR(3),
    geo_region_name VARCHAR(100),
    geo_city VARCHAR(75),
    geo_zipcode VARCHAR(15),
    geo_latitude DOUBLE PRECISION,
    geo_longitude DOUBLE PRECISION,
    geo_timezone VARCHAR(64),
    geo_country_name VARCHAR(255),
    geo_continent VARCHAR(255),
    last_geo_country VARCHAR(2),
    last_geo_region_name VARCHAR(100),
    last_geo_city VARCHAR(75),
    last_geo_country_name VARCHAR(255),
    last_geo_continent VARCHAR(255),

    -- Device/Browser attributes (66-73)
    user_ipaddress VARCHAR(128),
    useragent VARCHAR(1000),
    br_renderengine VARCHAR(50),
    br_lang VARCHAR(255),
    br_lang_name VARCHAR(255),
    last_br_lang VARCHAR(255),
    last_br_lang_name VARCHAR(255),
    os_timezone VARCHAR(255),

    -- IAB enrichment (74-77)
    category VARCHAR(255),
    primary_impact VARCHAR(255),
    reason VARCHAR(255),
    spider_or_robot BOOLEAN,

    -- UA Parser enrichment (78-89)
    useragent_family VARCHAR(255),
    useragent_major VARCHAR(50),
    useragent_minor VARCHAR(50),
    useragent_patch VARCHAR(50),
    useragent_version VARCHAR(255),
    os_family VARCHAR(255),
    os_major VARCHAR(50),
    os_minor VARCHAR(50),
    os_patch VARCHAR(50),
    os_patch_minor VARCHAR(50),
    os_version VARCHAR(255),
    device_family VARCHAR(255),

    -- YAUAA enrichment (90-111)
    device_class VARCHAR(255),
    device_category VARCHAR(255),
    screen_resolution VARCHAR(50),
    agent_class VARCHAR(255),
    agent_name VARCHAR(255),
    agent_name_version VARCHAR(255),
    agent_name_version_major VARCHAR(255),
    agent_version VARCHAR(255),
    agent_version_major VARCHAR(255),
    device_brand VARCHAR(255),
    device_name VARCHAR(255),
    device_version VARCHAR(255),
    layout_engine_class VARCHAR(255),
    layout_engine_name VARCHAR(255),
    layout_engine_name_version VARCHAR(255),
    layout_engine_name_version_major VARCHAR(255),
    layout_engine_version VARCHAR(255),
    layout_engine_version_major VARCHAR(255),
    operating_system_class VARCHAR(255),
    operating_system_name VARCHAR(255),
    operating_system_name_version VARCHAR(255),
    operating_system_version VARCHAR(255),

    -- Conversion metrics (112-119)
    cv_view_page_volume INTEGER,
    cv_view_page_events VARCHAR(10000),
    cv_view_page_values VARCHAR(10000),
    cv_view_page_total DOUBLE PRECISION,
    cv_view_page_first_conversion TIMESTAMP,
    cv_view_page_converted BOOLEAN,
    cv__all_volume INTEGER,
    cv__all_total DOUBLE PRECISION,

    -- Passthrough fields (120-121)
    event_id VARCHAR(36),
    event_id2 VARCHAR(36)
  );"
}

sp_load_sessions_expected() {
  snow sql -q "COPY INTO demo.embucket.snowplow_web_sessions_expected
    FROM 'file:///storage/snowplow/expected/snowflake/snowplow_web_sessions_expected.csv'
    STORAGE_INTEGRATION = local
    FILE_FORMAT = (TYPE = CSV, SKIP_HEADER = 1, FIELD_OPTIONALLY_ENCLOSED_BY = '\"');"
}

sp_merge_sessions() {
  snow sql -q "
    MERGE INTO demo.embucket.snowplow_web_sessions AS target
    USING demo.embucket.snowplow_web_sessions_this_run AS source
    ON target.domain_sessionid = source.domain_sessionid
    WHEN MATCHED THEN
      UPDATE SET
        app_id = source.app_id,
        platform = source.platform,
        original_domain_sessionid = source.original_domain_sessionid,
        domain_sessionidx = source.domain_sessionidx,
        start_tstamp = source.start_tstamp,
        end_tstamp = source.end_tstamp,
        user_id = source.user_id,
        domain_userid = source.domain_userid,
        original_domain_userid = source.original_domain_userid,
        stitched_user_id = source.stitched_user_id,
        network_userid = source.network_userid,
        page_views = source.page_views,
        engaged_time_in_s = source.engaged_time_in_s,
        total_events = source.total_events,
        is_engaged = source.is_engaged,
        absolute_time_in_s = source.absolute_time_in_s,
        first_page_title = source.first_page_title,
        first_page_url = source.first_page_url,
        first_page_urlscheme = source.first_page_urlscheme,
        first_page_urlhost = source.first_page_urlhost,
        first_page_urlpath = source.first_page_urlpath,
        first_page_urlquery = source.first_page_urlquery,
        first_page_urlfragment = source.first_page_urlfragment,
        last_page_title = source.last_page_title,
        last_page_url = source.last_page_url,
        last_page_urlscheme = source.last_page_urlscheme,
        last_page_urlhost = source.last_page_urlhost,
        last_page_urlpath = source.last_page_urlpath,
        last_page_urlquery = source.last_page_urlquery,
        last_page_urlfragment = source.last_page_urlfragment,
        referrer = source.referrer,
        refr_urlscheme = source.refr_urlscheme,
        refr_urlhost = source.refr_urlhost,
        refr_urlpath = source.refr_urlpath,
        refr_urlquery = source.refr_urlquery,
        refr_urlfragment = source.refr_urlfragment,
        refr_medium = source.refr_medium,
        refr_source = source.refr_source,
        refr_term = source.refr_term,
        mkt_medium = source.mkt_medium,
        mkt_source = source.mkt_source,
        mkt_term = source.mkt_term,
        mkt_content = source.mkt_content,
        mkt_campaign = source.mkt_campaign,
        mkt_clickid = source.mkt_clickid,
        mkt_network = source.mkt_network,
        mkt_source_platform = source.mkt_source_platform,
        default_channel_group = source.default_channel_group,
        geo_country = source.geo_country,
        geo_region = source.geo_region,
        geo_region_name = source.geo_region_name,
        geo_city = source.geo_city,
        geo_zipcode = source.geo_zipcode,
        geo_latitude = source.geo_latitude,
        geo_longitude = source.geo_longitude,
        geo_timezone = source.geo_timezone,
        last_geo_country = source.last_geo_country,
        last_geo_region_name = source.last_geo_region_name,
        last_geo_city = source.last_geo_city,
        user_ipaddress = source.user_ipaddress,
        useragent = source.useragent,
        br_renderengine = source.br_renderengine,
        br_lang = source.br_lang,
        os_timezone = source.os_timezone,
        screen_resolution = source.screen_resolution
    WHEN NOT MATCHED THEN
      INSERT (
        app_id, platform, domain_sessionid, original_domain_sessionid, domain_sessionidx,
        start_tstamp, end_tstamp,
        user_id, domain_userid, original_domain_userid, stitched_user_id, network_userid,
        page_views, engaged_time_in_s, total_events, is_engaged, absolute_time_in_s,
        first_page_title, first_page_url, first_page_urlscheme, first_page_urlhost,
        first_page_urlpath, first_page_urlquery, first_page_urlfragment,
        last_page_title, last_page_url, last_page_urlscheme, last_page_urlhost,
        last_page_urlpath, last_page_urlquery, last_page_urlfragment,
        referrer, refr_urlscheme, refr_urlhost, refr_urlpath, refr_urlquery, refr_urlfragment,
        refr_medium, refr_source, refr_term,
        mkt_medium, mkt_source, mkt_term, mkt_content, mkt_campaign, mkt_clickid, mkt_network,
        mkt_source_platform, default_channel_group,
        geo_country, geo_region, geo_region_name, geo_city, geo_zipcode,
        geo_latitude, geo_longitude, geo_timezone,
        last_geo_country, last_geo_region_name, last_geo_city,
        user_ipaddress, useragent, br_renderengine, br_lang, os_timezone, screen_resolution
      )
      VALUES (
        source.app_id, source.platform, source.domain_sessionid, source.original_domain_sessionid, source.domain_sessionidx,
        source.start_tstamp, source.end_tstamp,
        source.user_id, source.domain_userid, source.original_domain_userid, source.stitched_user_id, source.network_userid,
        source.page_views, source.engaged_time_in_s, source.total_events, source.is_engaged, source.absolute_time_in_s,
        source.first_page_title, source.first_page_url, source.first_page_urlscheme, source.first_page_urlhost,
        source.first_page_urlpath, source.first_page_urlquery, source.first_page_urlfragment,
        source.last_page_title, source.last_page_url, source.last_page_urlscheme, source.last_page_urlhost,
        source.last_page_urlpath, source.last_page_urlquery, source.last_page_urlfragment,
        source.referrer, source.refr_urlscheme, source.refr_urlhost, source.refr_urlpath, source.refr_urlquery, source.refr_urlfragment,
        source.refr_medium, source.refr_source, source.refr_term,
        source.mkt_medium, source.mkt_source, source.mkt_term, source.mkt_content, source.mkt_campaign, source.mkt_clickid, source.mkt_network,
        source.mkt_source_platform, source.default_channel_group,
        source.geo_country, source.geo_region, source.geo_region_name, source.geo_city, source.geo_zipcode,
        source.geo_latitude, source.geo_longitude, source.geo_timezone,
        source.last_geo_country, source.last_geo_region_name, source.last_geo_city,
        source.user_ipaddress, source.useragent, source.br_renderengine, source.br_lang, source.os_timezone, source.screen_resolution
      );
  "
}
