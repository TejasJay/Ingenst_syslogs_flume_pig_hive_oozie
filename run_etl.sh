#!/bin/bash

echo "Starting ETL Workflow - $(date)"

oozie job -oozie http://localhost:11000/oozie -config /usr/local/oozie/conf/job.properties -run

echo "Workflow submitted!"

# cron run on terminal
# crontab -e
# 0 * * * * /usr/local/oozie/run_etl.sh
