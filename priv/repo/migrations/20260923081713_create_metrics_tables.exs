defmodule Hakkawine.Repo.Migrations.CreateMetricsTables do
  use Ecto.Migration

  def up do
    # execute "CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;"

    create table(:node_traffic_logs, primary_key: false) do
      add :recorded_at, :timestamptz, null: false
      add :node_id, :bigint, null: false
      add :user_id, :bigint, null: false
      add :subscription_id, :bigint, null: false
      add :upload_bytes, :bigint, null: false, default: 0
      add :download_bytes, :bigint, null: false, default: 0
      add :rate, :decimal, precision: 5, scale: 4, null: false, default: 1.0
    end

    execute """
    ALTER TABLE node_traffic_logs
    ADD CONSTRAINT pk_node_traffic_logs
    PRIMARY KEY (recorded_at, node_id, subscription_id);
    """

    execute "SELECT create_hypertable('node_traffic_logs', 'recorded_at');"

    execute """
    ALTER TABLE node_traffic_logs SET (
      timescaledb.compress,
      timescaledb.compress_segmentby = 'node_id, subscription_id, user_id',
      timescaledb.compress_orderby = 'recorded_at DESC'
    );
    """

    execute "SELECT add_compression_policy('node_traffic_logs', INTERVAL '7 days');"

    execute "SELECT add_retention_policy('node_traffic_logs', INTERVAL '14 days');"

    execute """
    CREATE MATERIALIZED VIEW node_traffic_logs_5m
    WITH (timescaledb.continuous) AS
    SELECT
        time_bucket('5 minutes', recorded_at)              AS bucket_5m,
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
    """

    execute """
    SELECT add_continuous_aggregate_policy(
        'node_traffic_logs_5m',
        start_offset => INTERVAL '3 hours',
        end_offset => INTERVAL '5 minutes',
        schedule_interval => INTERVAL '5 minutes'
    );
    """

    execute "SELECT add_retention_policy('node_traffic_logs_5m', INTERVAL '38 days');"

    execute """
    CREATE MATERIALIZED VIEW node_traffic_logs_daily
    WITH (timescaledb.continuous) AS
    SELECT
        time_bucket('1 day', recorded_at)                   AS bucket_day,
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
    """

    execute """
    SELECT add_continuous_aggregate_policy(
        'node_traffic_logs_daily',
        start_offset => INTERVAL '7 days',
        end_offset => INTERVAL '1 day',
        schedule_interval => INTERVAL '1 hour'
    );
    """

    execute "SELECT add_retention_policy('node_traffic_logs_daily', INTERVAL '395 days');"
  end

  def down do
    execute "SELECT remove_retention_policy('node_traffic_logs_daily', if_exists => true);"
    execute "SELECT remove_continuous_aggregate_policy('node_traffic_logs_daily', if_exists => true);"
    execute "DROP MATERIALIZED VIEW IF EXISTS node_traffic_logs_daily CASCADE;"

    execute "SELECT remove_retention_policy('node_traffic_logs_5m', if_exists => true);"
    execute "SELECT remove_continuous_aggregate_policy('node_traffic_logs_5m', if_exists => true);"
    execute "DROP MATERIALIZED VIEW IF EXISTS node_traffic_logs_5m CASCADE;"

    execute "SELECT remove_retention_policy('node_traffic_logs', if_exists => true);"
    execute "SELECT remove_compression_policy('node_traffic_logs', if_exists => true);"

    drop_if_exists table(:node_traffic_logs)
  end
end
