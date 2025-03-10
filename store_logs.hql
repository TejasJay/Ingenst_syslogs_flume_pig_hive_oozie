CREATE EXTERNAL TABLE IF NOT EXISTS processed_logs (
    timestamp STRING,
    loglevel STRING,
    message STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/hive/warehouse/processed_logs/';

# hive -f /usr/local/hive/scripts/store_logs.hql
