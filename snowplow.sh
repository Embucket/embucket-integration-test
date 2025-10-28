#!/bin/bash

export SNOWFLAKE_HOME=$(pwd)

source ./venv.sh

sp_create_events() {
  snow sql -q "CREATE TABLE demo.embucket.events (
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
    geo_timezone VARCHAR(64),

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
    refr_domain_userid VARCHAR(128),
    refr_dvce_tstamp TIMESTAMP,

    -- Marketing parameters
    mkt_medium VARCHAR(255),
    mkt_source VARCHAR(255),
    mkt_term VARCHAR(255),
    mkt_content VARCHAR(500),
    mkt_campaign VARCHAR(255),
    mkt_clickid VARCHAR(255),
    mkt_network VARCHAR(64),

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
    tr_currency VARCHAR(3),
    tr_total_base DOUBLE PRECISION,
    tr_tax_base DOUBLE PRECISION,
    tr_shipping_base DOUBLE PRECISION,

    -- Ecommerce transaction item
    ti_orderid VARCHAR(255),
    ti_sku VARCHAR(255),
    ti_name VARCHAR(255),
    ti_category VARCHAR(255),
    ti_price DOUBLE PRECISION,
    ti_quantity INTEGER,
    ti_currency VARCHAR(3),
    ti_price_base DOUBLE PRECISION,

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
    dvce_sent_tstamp TIMESTAMP,

    -- Document
    doc_charset VARCHAR(128),
    doc_width INTEGER,
    doc_height INTEGER,

    -- Currency
    base_currency VARCHAR(3),

    -- ETL
    etl_tags VARCHAR(500),

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

    -- Context columns (JSON/TEXT)
    contexts_com_snowplowanalytics_snowplow_web_page_1_0_0 TEXT,
    contexts_com_iab_snowplow_spiders_and_robots_1_0_0 TEXT,
    contexts_com_snowplowanalytics_snowplow_ua_parser_context_1_0_0 TEXT,
    contexts_nl_basjes_yauaa_context_1_0_0 TEXT,
    unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1_0_0 TEXT,
    unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1_0_0 TEXT
  );"
}

sp_copy_into_events1() {
  snow sql -q "COPY INTO demo.embucket.events FROM 'file:///storage/snowplow/source/snowplow_web_events1.csv' STORAGE_INTEGRATION = local FILE_FORMAT = (TYPE = CSV);"
}

sp_copy_into_events2() {
  snow sql -q "COPY INTO demo.embucket.events FROM 'file:///storage/snowplow/source/snowplow_web_events2.csv' STORAGE_INTEGRATION = local FILE_FORMAT = (TYPE = CSV);"
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
      WHERE e.domain_sessionid IS NOT NULL
        AND NOT EXISTS (
          SELECT 1 FROM demo.embucket.snowplow_web_base_quarantined_sessions q
          WHERE q.session_identifier = e.domain_sessionid
        )
      GROUP BY e.domain_sessionid
    ) AS source
    ON target.session_identifier = source.session_identifier
    WHEN MATCHED THEN
      UPDATE SET
        end_tstamp = GREATEST(target.end_tstamp, source.end_tstamp),
        user_identifier = source.user_identifier
    WHEN NOT MATCHED THEN
      INSERT (session_identifier, user_identifier, start_tstamp, end_tstamp)
      VALUES (source.session_identifier, source.user_identifier, source.start_tstamp, source.end_tstamp);
  "
}
