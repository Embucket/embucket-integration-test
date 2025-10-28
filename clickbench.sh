#!/bin/bash

export SNOWFLAKE_HOME=$(pwd)

source ./venv.sh

if [ ! -d "clickbench" ]; then
  mkdir clickbench
  mkdir -p clickbench/partitioned
  mkdir -p clickbench/single
fi

volume_local_file() {
  snow sql -q "CREATE EXTERNAL VOLUME 'local'
  STORAGE_LOCATIONS = 
  (
    (
      NAME = 'local'
      STORAGE_PROVIDER = 'file'
      STORAGE_BASE_URL = '$(pwd)/clickbench'
    )
  )"
}

cp_download_partitioned() {
  seq 0 99 | xargs -P100 -I{} bash -c 'wget --directory-prefix clickbench/partitioned --continue --progress=dot:giga https://datasets.clickhouse.com/hits_compatible/athena_partitioned/hits_{}.parquet'
}

cb_download_single() {
  wget --directory-prefix clickbench/single --continue --progress=dot:giga https://datasets.clickhouse.com/hits_compatible/hits.parquet
}

cb_create_table() {
  snow sql -q "CREATE TABLE demo.embucket.hits
(
    WatchID BIGINT NOT NULL,
    JavaEnable SMALLINT NOT NULL,
    Title TEXT NOT NULL,
    GoodEvent SMALLINT NOT NULL,
    EventTime TIMESTAMP NOT NULL,
    EventDate INT NOT NULL,
    CounterID INTEGER NOT NULL,
    ClientIP INTEGER NOT NULL,
    RegionID INTEGER NOT NULL,
    UserID BIGINT NOT NULL,
    CounterClass SMALLINT NOT NULL,
    OS SMALLINT NOT NULL,
    UserAgent SMALLINT NOT NULL,
    URL TEXT NOT NULL,
    Referer TEXT NOT NULL,
    IsRefresh SMALLINT NOT NULL,
    RefererCategoryID SMALLINT NOT NULL,
    RefererRegionID INTEGER NOT NULL,
    URLCategoryID SMALLINT NOT NULL,
    URLRegionID INTEGER NOT NULL,
    ResolutionWidth SMALLINT NOT NULL,
    ResolutionHeight SMALLINT NOT NULL,
    ResolutionDepth SMALLINT NOT NULL,
    FlashMajor SMALLINT NOT NULL,
    FlashMinor SMALLINT NOT NULL,
    FlashMinor2 TEXT NOT NULL,
    NetMajor SMALLINT NOT NULL,
    NetMinor SMALLINT NOT NULL,
    UserAgentMajor SMALLINT NOT NULL,
    UserAgentMinor VARCHAR(255) NOT NULL,
    CookieEnable SMALLINT NOT NULL,
    JavascriptEnable SMALLINT NOT NULL,
    IsMobile SMALLINT NOT NULL,
    MobilePhone SMALLINT NOT NULL,
    MobilePhoneModel TEXT NOT NULL,
    Params TEXT NOT NULL,
    IPNetworkID INTEGER NOT NULL,
    TraficSourceID SMALLINT NOT NULL,
    SearchEngineID SMALLINT NOT NULL,
    SearchPhrase TEXT NOT NULL,
    AdvEngineID SMALLINT NOT NULL,
    IsArtifical SMALLINT NOT NULL,
    WindowClientWidth SMALLINT NOT NULL,
    WindowClientHeight SMALLINT NOT NULL,
    ClientTimeZone SMALLINT NOT NULL,
    ClientEventTime TIMESTAMP NOT NULL,
    SilverlightVersion1 SMALLINT NOT NULL,
    SilverlightVersion2 SMALLINT NOT NULL,
    SilverlightVersion3 INTEGER NOT NULL,
    SilverlightVersion4 SMALLINT NOT NULL,
    PageCharset TEXT NOT NULL,
    CodeVersion INTEGER NOT NULL,
    IsLink SMALLINT NOT NULL,
    IsDownload SMALLINT NOT NULL,
    IsNotBounce SMALLINT NOT NULL,
    FUniqID BIGINT NOT NULL,
    OriginalURL TEXT NOT NULL,
    HID INTEGER NOT NULL,
    IsOldCounter SMALLINT NOT NULL,
    IsEvent SMALLINT NOT NULL,
    IsParameter SMALLINT NOT NULL,
    DontCountHits SMALLINT NOT NULL,
    WithHash SMALLINT NOT NULL,
    HitColor CHAR NOT NULL,
    LocalEventTime TIMESTAMP NOT NULL,
    Age SMALLINT NOT NULL,
    Sex SMALLINT NOT NULL,
    Income SMALLINT NOT NULL,
    Interests SMALLINT NOT NULL,
    Robotness SMALLINT NOT NULL,
    RemoteIP INTEGER NOT NULL,
    WindowName INTEGER NOT NULL,
    OpenerName INTEGER NOT NULL,
    HistoryLength SMALLINT NOT NULL,
    BrowserLanguage TEXT NOT NULL,
    BrowserCountry TEXT NOT NULL,
    SocialNetwork TEXT NOT NULL,
    SocialAction TEXT NOT NULL,
    HTTPError SMALLINT NOT NULL,
    SendTiming INTEGER NOT NULL,
    DNSTiming INTEGER NOT NULL,
    ConnectTiming INTEGER NOT NULL,
    ResponseStartTiming INTEGER NOT NULL,
    ResponseEndTiming INTEGER NOT NULL,
    FetchTiming INTEGER NOT NULL,
    SocialSourceNetworkID SMALLINT NOT NULL,
    SocialSourcePage TEXT NOT NULL,
    ParamPrice BIGINT NOT NULL,
    ParamOrderID TEXT NOT NULL,
    ParamCurrency TEXT NOT NULL,
    ParamCurrencyID SMALLINT NOT NULL,
    OpenstatServiceName TEXT NOT NULL,
    OpenstatCampaignID TEXT NOT NULL,
    OpenstatAdID TEXT NOT NULL,
    OpenstatSourceID TEXT NOT NULL,
    UTMSource TEXT NOT NULL,
    UTMMedium TEXT NOT NULL,
    UTMCampaign TEXT NOT NULL,
    UTMContent TEXT NOT NULL,
    UTMTerm TEXT NOT NULL,
    FromTag TEXT NOT NULL,
    HasGCLID SMALLINT NOT NULL,
    RefererHash BIGINT NOT NULL,
    URLHash BIGINT NOT NULL,
    CLID INTEGER NOT NULL
);"
}

cb_copy_into_partitioned_small() {
  cb_copy_into_partitioned_n 0
}

cb_copy_into_partitioned_n() {
  local n=$1
  snow sql -q "COPY INTO demo.embucket.hits FROM 'file:///storage/clickbench/partitioned/hits_$n.parquet' STORAGE_INTEGRATION = local FILE_FORMAT = (TYPE = PARQUET);"
}

cb_copy_into_partitioned() {
  snow sql -q "COPY INTO demo.embucket.hits FROM 'file:///storage/clickbench/partitioned/' STORAGE_INTEGRATION = local FILE_FORMAT = (TYPE = PARQUET);"
}

cb_copy_into_single() {
  snow sql -q "COPY INTO demo.embucket.hits FROM 'file:///storage/clickbench/single/' STORAGE_INTEGRATION = local FILE_FORMAT = (TYPE = PARQUET);"
}

cb_copy_into_partitioned_file() {
  snow sql -q "COPY INTO demo.embucket.hits FROM 'file://$(pwd)/clickbench/partitioned/' STORAGE_INTEGRATION = local FILE_FORMAT = (TYPE = PARQUET);"
}

cb_copy_into_partitioned_n_file() {
  local n=$1
  snow sql -q "COPY INTO demo.embucket.hits FROM 'file://$(pwd)/clickbench/partitioned/hits_$n.parquet' STORAGE_INTEGRATION = local FILE_FORMAT = (TYPE = PARQUET);"
}

clickbench_setup_partitioned() {
  cb_create_table
  cb_copy_into_partitioned
}

clickbench_partitioned_small() {
  cb_create_table
  cb_copy_into_partitioned_small
}

clickbench_single() {
  cb_create_table
  cb_copy_into_single
}

clickbench_spark() {
  docker exec spark-iceberg spark-submit /home/iceberg/create_iceberg.py
}

clickbench_spark_partitioned() {
  docker exec spark-iceberg spark-submit /home/iceberg/create_iceberg_partitioned.py
}

activate

if [ -n "$1" ]; then "$1" "${2:0}"; fi
