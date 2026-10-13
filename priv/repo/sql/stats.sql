-- CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;

CREATE TABLE agent_traffic_logs (
    recorded_at timestamptz NOT NULL,
    agent_id bigint NOT NULL,
    user_id bigint NOT NULL,
    subscription_id bigint NOT NULL,
    upload_bytes bigint NOT NULL DEFAULT 0,
    download_bytes bigint NOT NULL DEFAULT 0,
    rate DECIMAL(5, 4) NOT NULL DEFAULT 1.0,
    PRIMARY KEY (recorded_at, agent_id, subscription_id)
);

SELECT create_hypertable ('agent_traffic_logs','recorded_at');

ALTER TABLE agent_traffic_logs SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'agent_id, subscription_id, user_id',
    timescaledb.compress_orderby = 'recorded_at DESC'
);

SELECT add_compression_policy ('agent_traffic_logs', INTERVAL '7 days');

SELECT add_retention_policy ('agent_traffic_logs', INTERVAL '14 days');

CREATE MATERIALIZED VIEW  agent_traffic_logs_5m
WITH (timescaledb.continuous) AS
SELECT
    time_bucket ('5 minutes', recorded_at)              AS bucket_5m,
    agent_id,
    user_id,
    subscription_id,
    SUM(upload_bytes)                                   AS upload_bytes,
    SUM(download_bytes)                                 AS download_bytes,
    SUM(upload_bytes * rate)::bigint                    AS rated_upload_bytes,
    SUM(download_bytes * rate)::bigint                  AS rated_download_bytes,
    SUM((upload_bytes + download_bytes) * rate)::bigint AS rated_total_bytes
FROM
    agent_traffic_logs
GROUP BY
    bucket_5m,
    agent_id,
    user_id,
    subscription_id
WITH NO DATA;

SELECT add_continuous_aggregate_policy (
    'agent_traffic_logs_5m',
    start_offset => INTERVAL '3 hours',
    end_offset => INTERVAL '5 minutes',
    schedule_interval => INTERVAL '5 minutes'
);

SELECT add_retention_policy ('agent_traffic_logs_5m', INTERVAL '38 days');

CREATE MATERIALIZED VIEW agent_traffic_logs_daily
WITH (timescaledb.continuous) AS
SELECT
    time_bucket ('1 day', recorded_at)                  AS bucket_day,
    agent_id,
    user_id,
    subscription_id,
    SUM(upload_bytes)                                   AS upload_bytes,
    SUM(download_bytes)                                 AS download_bytes,
    SUM(upload_bytes * rate)::bigint                    AS rated_upload_bytes,
    SUM(download_bytes * rate)::bigint                  AS rated_download_bytes,
    SUM((upload_bytes + download_bytes) * rate)::bigint AS rated_total_bytes
FROM
    agent_traffic_logs
GROUP BY
    bucket_day,
    agent_id,
    user_id,
    subscription_id
WITH NO DATA;

SELECT add_continuous_aggregate_policy (
    'agent_traffic_logs_daily',
    start_offset => INTERVAL '7 days',
    end_offset => INTERVAL '1 day',
    schedule_interval => INTERVAL '1 hour'
);

SELECT add_retention_policy ('agent_traffic_logs_daily', INTERVAL '395 days');