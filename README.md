# **🚀 Fully Automated Data Pipeline Project Using Flume, Pig, Hive, Oozie & Shell**

This project **automates data ingestion, transformation, storage, and scheduling** using: ✅ **Flume** – Ingests logs into **HDFS**
✅ **Pig** – Processes raw logs into structured format
✅ **Hive** – Stores structured logs for querying
✅ **Oozie** – Automates & schedules ETL workflow
✅ **Shell Scripts** – Manages pipeline execution

* * * 

## **📌 1️⃣ Project Setup**

### **1️⃣ Create HDFS Directories for Logs & Processed Data**

```bash
hdfs dfs -mkdir -p /user/flume/logs
hdfs dfs -mkdir -p /user/hive/warehouse/processed_logs
```

* * *

## **📌 2️⃣ Flume – Real-Time Log Ingestion**

We set up Flume to **monitor system logs** and stream them to **HDFS**.

### **1️⃣ Create Flume Configuration**

📌 **Flume Config: `/usr/local/flume/conf/flume-hdfs.conf`**

```properties
agent.sources = log_source
agent.sinks = hdfs_sink
agent.channels = memory_channel

# Define Source
agent.sources.log_source.type = exec
agent.sources.log_source.command = tail -F /var/log/syslog

# Define Channel
agent.channels.memory_channel.type = memory
agent.channels.memory_channel.capacity = 1000
agent.channels.memory_channel.transactionCapacity = 100

# Define Sink
agent.sinks.hdfs_sink.type = hdfs
agent.sinks.hdfs_sink.hdfs.path = hdfs://localhost:9000/user/flume/logs/
agent.sinks.hdfs_sink.hdfs.fileType = DataStream
agent.sinks.hdfs_sink.hdfs.writeFormat = Text
agent.sinks.hdfs_sink.channel = memory_channel
```

### **2️⃣ Start Flume Agent**

```bash
flume-ng agent --conf /usr/local/flume/conf/ --conf-file /usr/local/flume/conf/flume-hdfs.conf --name agent -Dflume.root.logger=INFO,console
```

✅ **Logs will now be stored in** `/user/flume/logs/`

* * *

## **📌 3️⃣ Pig – Process & Transform Logs**

Pig will **clean and format logs** before storing them in Hive.

### **1️⃣ Create Pig Script**

📌 **Pig Script: `/usr/local/pig/scripts/process_logs.pig`**

```pig
REGISTER /usr/local/pig/lib/piggybank.jar;

-- Load raw logs
logs = LOAD '/user/flume/logs/' USING PigStorage(' ') AS (timestamp:chararray, loglevel:chararray, message:chararray);

-- Filter warnings and errors
filtered_logs = FILTER logs BY loglevel MATCHES 'ERROR|WARN';

-- Store processed logs in HDFS
STORE filtered_logs INTO '/user/hive/warehouse/processed_logs/' USING PigStorage(',');
```

### **2️⃣ Run Pig Script**

```bash
pig -x mapreduce /usr/local/pig/scripts/process_logs.pig
```

✅ **Filtered logs are stored in HDFS for Hive**

* * *

## **📌 4️⃣ Hive – Store & Query Processed Logs**

We create a Hive table to **query structured logs**.

### **1️⃣ Create Hive Table**

📌 **Hive Script: `/usr/local/hive/scripts/store_logs.hql`**

```sql
CREATE EXTERNAL TABLE IF NOT EXISTS processed_logs (
    timestamp STRING,
    loglevel STRING,
    message STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/hive/warehouse/processed_logs/';
```

### **2️⃣ Run Hive Script**

```bash
hive -f /usr/local/hive/scripts/store_logs.hql
```

✅ **Logs are now queryable in Hive**

* * *

## **📌 5️⃣ Oozie – Automate the Workflow**

Oozie will **automate the Flume → Pig → Hive pipeline**.

### **1️⃣ Create Oozie Workflow**

📌 **Oozie Workflow: `/usr/local/oozie/workflows/etl-workflow.xml`**

```xml
<workflow-app name="etl-workflow" xmlns="uri:oozie:workflow:0.5">
    <start to="flume-action"/>

    <action name="flume-action">
        <shell>
            <job-tracker>${jobTracker}</job-tracker>
            <name-node>${nameNode}</name-node>
            <exec>/usr/local/flume/bin/flume-ng</exec>
            <arg>agent</arg>
            <arg>--conf-file</arg>
            <arg>/usr/local/flume/conf/flume-hdfs.conf</arg>
            <arg>--name</arg>
            <arg>agent</arg>
        </shell>
        <ok to="pig-action"/>
        <error to="fail"/>
    </action>

    <action name="pig-action">
        <pig>
            <job-tracker>${jobTracker}</job-tracker>
            <name-node>${nameNode}</name-node>
            <script>/usr/local/pig/scripts/process_logs.pig</script>
        </pig>
        <ok to="hive-action"/>
        <error to="fail"/>
    </action>

    <action name="hive-action">
        <hive>
            <job-tracker>${jobTracker}</job-tracker>
            <name-node>${nameNode}</name-node>
            <script>/usr/local/hive/scripts/store_logs.hql</script>
        </hive>
        <ok to="end"/>
        <error to="fail"/>
    </action>

    <kill name="fail">
        <message>ETL workflow failed</message>
    </kill>

    <end name="end"/>
</workflow-app>
```

### **2️⃣ Create Oozie Job Properties**

📌 **Oozie Properties: `/usr/local/oozie/conf/job.properties`**

```properties
nameNode=hdfs://localhost:9000
jobTracker=localhost:8032
queueName=default

oozie.use.system.libpath=true
oozie.wf.application.path=/user/oozie/workflows/etl-workflow.xml
```

### **3️⃣ Run Oozie Workflow**

```bash
oozie job -oozie http://localhost:11000/oozie -config /usr/local/oozie/conf/job.properties -run
```

✅ **The pipeline now runs end-to-end on Oozie!** 🚀

* * *

## **📌 6️⃣ Automate with Shell Script**

A shell script can **trigger the Oozie job** on a schedule.

📌 **Shell Script: `/usr/local/oozie/run_etl.sh`**

```bash
#!/bin/bash

echo "Starting ETL Workflow - $(date)"

oozie job -oozie http://localhost:11000/oozie -config /usr/local/oozie/conf/job.properties -run

echo "Workflow submitted!"
```

### **Schedule with Cron**

Run the job **every hour**:

```bash
crontab -e
```

Add:

```bash
0 * * * * /usr/local/oozie/run_etl.sh
```

✅ **Now the pipeline runs automatically every hour!**

* * *

## **🚀 Summary**

| **Component** | **Purpose** |
| --- | --- |
| **Flume** | Ingests system logs into **HDFS** |
| **Pig** | Cleans & transforms logs |
| **Hive** | Stores logs for querying |
| **Oozie** | Automates Flume → Pig → Hive |
| **Shell Script & Cron** | Runs the ETL pipeline **hourly** |

* * *


