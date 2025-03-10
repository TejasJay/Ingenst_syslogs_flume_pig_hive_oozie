REGISTER /usr/local/pig/lib/piggybank.jar;

-- Load raw logs
logs = LOAD '/user/flume/logs/' USING PigStorage(' ') AS (timestamp:chararray, loglevel:chararray, message:chararray);

-- Filter warnings and errors
filtered_logs = FILTER logs BY loglevel MATCHES 'ERROR|WARN';

-- Store processed logs in HDFS
STORE filtered_logs INTO '/user/hive/warehouse/processed_logs/' USING PigStorage(',');

-- Run this 
-- pig -x mapreduce /usr/local/pig/scripts/process_logs.pig
