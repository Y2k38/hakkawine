-- CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;

CREATE TABLE node_traffic_logs (
    recorded_at timestamptz NOT NULL,
    node_id bigint NOT NULL,
    user_id bigint NOT NULL,
    subscription_id bigint NOT NULL,
    upload_bytes bigint NOT NULL DEFAULT 0,
    download_bytes bigint NOT NULL DEFAULT 0,
    rate DECIMAL(5, 4) NOT NULL DEFAULT 1.0,
    PRIMARY KEY (recorded_at, node_id, subscription_id)
);

SELECT create_hypertable ('node_traffic_logs','recorded_at');

ALTER TABLE node_traffic_logs SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'node_id, subscription_id, user_id',
    timescaledb.compress_orderby = 'recorded_at DESC'
);

SELECT add_compression_policy ('node_traffic_logs', INTERVAL '7 days');

SELECT add_retention_policy ('node_traffic_logs', INTERVAL '14 days');

CREATE MATERIALIZED VIEW  node_traffic_logs_5m
WITH (timescaledb.continuous) AS
SELECT
    time_bucket ('5 minutes', recorded_at)              AS bucket_5m,
    node_id,
    user_id,
    subscription_id,
    SUM(upload_bytes)                                   AS upload_bytes,
    SUM(download_bytes)                                 AS download_bytes,
    SUM(upload_bytes * rate)::bigint                    AS rated_upload_bytes,
    SUM(download_bytes * rate)::bigint                  AS rated_download_bytes,
    SUM((upload_bytes + download_bytes) * rate)::bigint AS rated_total_bytes
FROM
    node_traffic_logs
GROUP BY
    bucket_5m,
    node_id,
    user_id,
    subscription_id
WITH NO DATA;

SELECT add_continuous_aggregate_policy (
    'node_traffic_logs_5m',
    start_offset => INTERVAL '3 hours',
    end_offset => INTERVAL '5 minutes',
    schedule_interval => INTERVAL '5 minutes'
);

SELECT add_retention_policy ('node_traffic_logs_5m', INTERVAL '38 days');

CREATE MATERIALIZED VIEW node_traffic_logs_daily
WITH (timescaledb.continuous) AS
SELECT
    time_bucket ('1 day', recorded_at)                  AS bucket_day,
    node_id,
    user_id,
    subscription_id,
    SUM(upload_bytes)                                   AS upload_bytes,
    SUM(download_bytes)                                 AS download_bytes,
    SUM(upload_bytes * rate)::bigint                    AS rated_upload_bytes,
    SUM(download_bytes * rate)::bigint                  AS rated_download_bytes,
    SUM((upload_bytes + download_bytes) * rate)::bigint AS rated_total_bytes
FROM
    node_traffic_logs
GROUP BY
    bucket_day,
    node_id,
    user_id,
    subscription_id
WITH NO DATA;

SELECT add_continuous_aggregate_policy (
    'node_traffic_logs_daily',
    start_offset => INTERVAL '7 days',
    end_offset => INTERVAL '1 day',
    schedule_interval => INTERVAL '1 hour'
);

SELECT add_retention_policy ('node_traffic_logs_daily', INTERVAL '395 days');