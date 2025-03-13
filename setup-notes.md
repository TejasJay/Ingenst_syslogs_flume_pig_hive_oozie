# Installation, Setup & Notes 


---

## **🔹 What is Apache HBase?**
Apache HBase is a **distributed, scalable, and NoSQL database** built on top of **Hadoop and HDFS**. It provides **real-time read/write access** to large amounts of sparse data.

### **🔹 Why Use HBase?**
- **Handles Big Data** – Stores billions of rows and columns.
- **Random Read/Write** – Unlike HDFS (which supports batch processing), HBase allows **low-latency access** to data.
- **Column-Oriented Storage** – Unlike relational databases (which are row-based), HBase stores data in **columns**, making it efficient for querying large datasets.
- **Built on HDFS** – It inherits the fault-tolerant and distributed nature of Hadoop.
- **Horizontal Scalability** – You can **add more nodes** to scale up without downtime.

---

## **🔹 HBase vs. Traditional Relational Databases**
| Feature | HBase (NoSQL) | Relational Databases (SQL) |
|---------|--------------|-------------------------|
| **Data Model** | Column-Family Based | Table-Based |
| **Schema** | Flexible (Schema-less) | Rigid Schema |
| **Query Language** | NoSQL API (Java, REST, Thrift) | SQL |
| **Scaling** | Horizontal (Add nodes) | Vertical (More CPU/RAM) |
| **ACID Compliance** | Limited (Only Atomicity per row) | Fully ACID Compliant |
| **Read/Write Speed** | Fast (for large datasets) | Slower for huge data |

---

## **🔹 HBase Architecture**
HBase has a **Master-Slave** architecture, consisting of the following components:

### **1️⃣ HMaster (Master Server)**
- **Coordinates all RegionServers**.
- **Handles metadata** about tables and regions.
- **Manages failover and load balancing**.

### **2️⃣ RegionServer (Worker Nodes)**
- **Manages data read/write requests**.
- **Hosts multiple "Regions"** (HBase partitions the data into smaller chunks).
- **Handles client requests** for reading and writing.

### **3️⃣ ZooKeeper**
- **Manages distributed coordination** (e.g., leader election, metadata).
- **Ensures only one HMaster is active** at a time.
- **Tracks RegionServers**.

### **4️⃣ HDFS (Hadoop Distributed File System)**
- **Stores actual HBase data**.
- **Ensures high availability and fault tolerance**.

🔹 **📌 Flow of a Read/Write Request:**
1. A client **writes data** → HBase writes it to the **Write-Ahead Log (WAL)** first.
2. Data is stored in **MemStore (RAM)** temporarily.
3. When MemStore fills up, it **flushes data to HDFS** as immutable **HFiles**.
4. During a **read request**, HBase first checks **MemStore** → If not found, it reads from **HFiles in HDFS**.

---

## **🔹 HBase Data Model**
HBase organizes data in a **Column-Family Model** instead of the **Table-Row Model** used in SQL databases.

### **HBase Data Structure**
📌 **Table → Column Families → Columns → Rows → Cells**

```
Table: users
├── Column Family: personal_info
│   ├── Column: name
│   ├── Column: age
├── Column Family: contact_details
│   ├── Column: email
│   ├── Column: phone
```

🔹 **Key Features of HBase Data Model:**
- **Column Families** group related columns (must be defined during table creation).
- **Rows are uniquely identified** by a **Row Key**.
- **Timestamps are stored automatically**, keeping multiple versions of data.
- **Cells are sparse** (empty columns don't take up space).

📌 **Example Data in HBase:**
| Row Key | personal_info:name | personal_info:age | contact_details:email | contact_details:phone |
|---------|-------------------|------------------|---------------------|-------------------|
| `1001`  | Alice             | 25               | alice@example.com   | 1234567890       |
| `1002`  | Bob               | 30               | bob@example.com     | 9876543210       |

---

## **🔹 Installing and Setting Up HBase**
### **1️⃣ Download & Extract HBase**
```bash
wget https://archive.apache.org/dist/hbase/2.4.17/hbase-2.4.17-bin.tar.gz
tar -xvzf hbase-2.4.17-bin.tar.gz
mv hbase-2.4.17 /usr/local/hbase
```

### **2️⃣ Configure HBase (`hbase-site.xml`)**
Edit `/usr/local/hbase/conf/hbase-site.xml`:
```xml
<configuration>
    <property>
        <name>hbase.cluster.distributed</name>
        <value>false</value> <!-- Standalone Mode -->
    </property>
    <property>
        <name>hbase.rootdir</name>
        <value>file:///usr/local/hbase/data</value> <!-- Local Storage -->
    </property>
    <property>
        <name>hbase.zookeeper.property.dataDir</name>
        <value>/usr/local/hbase/zookeeper</value>
    </property>
</configuration>
```

### **3️⃣ Set Environment Variables**
Edit `~/.bashrc`:
```bash
export HBASE_HOME=/usr/local/hbase
export PATH=$HBASE_HOME/bin:$PATH
```
Apply changes:
```bash
source ~/.bashrc
```

### **4️⃣ Start HBase**
```bash
start-hbase.sh
```

### **5️⃣ Check Running Services**
```bash
jps
```
Expected output:
```
1234 HMaster
5678 HRegionServer
9101 HQuorumPeer
```

---

## **🔹 Working with HBase Shell**
HBase provides an **interactive shell** for managing tables.

### **1️⃣ Start HBase Shell**
```bash
hbase shell
```

### **2️⃣ Create a Table**
```bash
create 'users', 'personal_info', 'contact_details'
```
- `users` = Table Name
- `personal_info`, `contact_details` = Column Families

### **3️⃣ Insert Data**
```bash
put 'users', '1001', 'personal_info:name', 'Alice'
put 'users', '1001', 'personal_info:age', '25'
put 'users', '1001', 'contact_details:email', 'alice@example.com'
```

### **4️⃣ Retrieve Data**
```bash
get 'users', '1001'
```

### **5️⃣ Scan Table**
```bash
scan 'users'
```

### **6️⃣ Delete a Record**
```bash
delete 'users', '1001', 'contact_details:email'
```

### **7️⃣ Drop a Table**
```bash
disable 'users'
drop 'users'
```

---

## **🔹 Common HBase Errors & Fixes**
### **1️⃣ Error: `Server is not running yet`**
📌 **Fix:** Restart HBase properly.
```bash
stop-hbase.sh
start-hbase.sh
```

### **2️⃣ Error: `Could not start ZK at requested port of 2181`**
📌 **Fix:** Check if ZooKeeper is already running on another port.
```bash
netstat -tulnp | grep 2181
```
If needed, change `hbase.zookeeper.property.clientPort` in `hbase-site.xml`.

### **3️⃣ Error: `NoNode for /hbase/master`**
📌 **Fix:** ZooKeeper might be misconfigured. Restart ZooKeeper and HBase.
```bash
zkServer.sh start
start-hbase.sh
```

---

## **🚀 Summary**
| **Feature** | **HBase** |
|------------|----------|
| **Storage** | Column-Oriented, NoSQL |
| **Scalability** | Horizontal Scaling (Add Nodes) |
| **Data Retrieval** | Real-time, Low-Latency |
| **Query Language** | HBase Shell, Java API |
| **Integration** | Works with Hadoop, Pig, Hive |

---

# **📒 In-Depth Notes on Apache Pig**

* * *

## **🔹 What is Apache Pig?**

Apache Pig is a **high-level scripting platform** for processing large datasets in **Hadoop**. It provides an abstraction over **MapReduce**, allowing users to **write data transformation scripts** using **Pig Latin**.

### **🔹 Why Use Pig?**

✅ **Simplifies Complex Data Processing** – Instead of writing long MapReduce programs, you can write simple scripts.
✅ **Handles Structured & Semi-Structured Data** – Works with logs, XML, JSON, CSV, etc.
✅ **Optimized Execution** – Pig automatically converts scripts into **optimized MapReduce jobs**.
✅ **Extensible** – You can **extend Pig** with **UDFs (User Defined Functions)** in **Python or Java**.
✅ **Schema Flexibility** – Unlike Hive (which requires structured tables), Pig allows **schema-less data processing**.

* * *

## **🔹 Pig vs. Hive vs. MapReduce**

| Feature | Pig | Hive | MapReduce |
| --- | --- | --- | --- |
| **Language** | Pig Latin | SQL-like (HiveQL) | Java |
| **Ease of Use** | Easy | Easy | Complex |
| **Schema Requirement** | Optional | Required | Not Required |
| **Optimization** | Automatic | Automatic | Manual |
| **Best For** | ETL, Data Processing | Data Warehousing, Analytics | Complex Custom Processing |

* * *

## **🔹 Pig Architecture**

Pig processes data in multiple steps before executing **MapReduce jobs**.

### **1️⃣ Pig Components**

📌 **Pig Latin** – The scripting language used to write **ETL transformations**.
📌 **Parser** – Converts the Pig script into a logical execution plan.
📌 **Optimizer** – Optimizes the execution plan for efficiency.
📌 **Compiler** – Converts the optimized plan into **MapReduce jobs**.
📌 **Execution Engine** – Executes the generated **MapReduce** tasks.

### **2️⃣ Pig Execution Modes**

Pig can run in two modes:

1️⃣ **Local Mode** – Runs Pig on a **single machine**, using the local file system (no Hadoop required).

```bash
pig -x local
```

2️⃣ **MapReduce Mode (Distributed Mode)** – Runs Pig on **Hadoop clusters**, processing large datasets.

```bash
pig -x mapreduce
```

* * *

## **🔹 Installing and Running Pig**

### **1️⃣ Download and Install Pig**

```bash
wget https://archive.apache.org/dist/pig/pig-0.17.0/pig-0.17.0.tar.gz
tar -xvzf pig-0.17.0.tar.gz
mv pig-0.17.0 /usr/local/pig
```

### **2️⃣ Configure Pig Environment**

Edit `~/.bashrc`:

```bash
export PIG_HOME=/usr/local/pig
export PATH=$PIG_HOME/bin:$PATH
```

Apply changes:

```bash
source ~/.bashrc
```

### **3️⃣ Start Pig in Interactive Mode**

```bash
pig -x mapreduce
```

Expected output:

```
grunt>
```

* * *

## **🔹 Pig Latin Basics**

Pig Latin follows a **step-by-step** approach for **data transformation**.

### **1️⃣ Load Data**

To process data, we first **load it into a variable**.

```pig
A = LOAD 'sample_data.csv' USING PigStorage(',') AS (id:int, name:chararray, age:int);
```

-   `PigStorage(',')` → Uses a **comma (',')** as a delimiter.
-   `AS (id:int, name:chararray, age:int)` → Defines column names and types.

### **2️⃣ View Data**

Check **first few records**:

```pig
DUMP A;
```

### **3️⃣ Filter Data**

Extract only records where **age > 30**:

```pig
B = FILTER A BY age > 30;
DUMP B;
```

### **4️⃣ Group Data**

Group records **by age**:

```pig
C = GROUP A BY age;
DUMP C;
```

### **5️⃣ Sort Data**

Sort records **by name**:

```pig
D = ORDER A BY name;
DUMP D;
```

### **6️⃣ Store Data**

Store processed data **in HDFS**:

```pig
STORE B INTO '/user/pig/output' USING PigStorage(',');
```

* * *

## **🔹 Joins in Pig**

Like SQL, Pig allows **joins** to combine datasets.

### **Example: Joining Two Datasets**

We have two datasets:

📌 **Employees Data (`employees.csv`)**

```
1, Alice, HR
2, Bob, IT
3, Charlie, Sales
```

📌 **Departments Data (`departments.csv`)**

```
HR, Human Resources
IT, Information Technology
Sales, Sales & Marketing
```

### **1️⃣ Load Datasets**

```pig
emp = LOAD 'employees.csv' USING PigStorage(',') AS (id:int, name:chararray, dept:chararray);
dept = LOAD 'departments.csv' USING PigStorage(',') AS (dept:chararray, dept_name:chararray);
```

### **2️⃣ Perform Join**

```pig
joined = JOIN emp BY dept, dept BY dept;
DUMP joined;
```

📌 **Output:**

```
1, Alice, HR, HR, Human Resources
2, Bob, IT, IT, Information Technology
3, Charlie, Sales, Sales, Sales & Marketing
```

* * *

## **🔹 Storing Processed Data in Hive**

We can **ETL data in Pig and store it in Hive**.

### **1️⃣ Create Hive Table**

```sql
CREATE TABLE processed_logs (
    id INT,
    message STRING,
    timestamp STRING
) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',';
```

### **2️⃣ Process Data in Pig**

```pig
A = LOAD '/user/flume/logs/custom_logs' USING PigStorage(',') AS (id:int, message:chararray, timestamp:chararray);
B = FILTER A BY message MATCHES 'ERROR.*';
STORE B INTO '/user/hive/warehouse/processed_logs/' USING PigStorage(',');
```

### **3️⃣ Load Data into Hive**

```sql
LOAD DATA INPATH '/user/hive/warehouse/processed_logs/' INTO TABLE processed_logs;
```

* * *

## **🔹 Automating ETL with Oozie**

We can **schedule the Pig script** using **Oozie workflows**.

### **1️⃣ Create Oozie Workflow XML**

📌 **`workflow.xml`**

```xml
<workflow-app name="pig_etl_workflow" xmlns="uri:oozie:workflow:0.5">
    <start to="pig-node"/>

    <action name="pig-node">
        <pig>
            <script>/user/pig/scripts/etl_script.pig</script>
        </pig>
        <ok to="end"/>
        <error to="fail"/>
    </action>

    <kill name="fail">
        <message>ETL Job Failed</message>
    </kill>

    <end name="end"/>
</workflow-app>
```

### **2️⃣ Run Oozie Workflow**

```bash
oozie job -config job.properties -run
```

* * *

## **🚀 Summary**

| **Feature** | **Apache Pig** |
| --- | --- |
| **Processing** | Large Datasets on Hadoop |
| **Ease of Use** | Simple, Scripting-Based |
| **Query Language** | Pig Latin |
| **Data Handling** | Structured & Semi-Structured |
| **Best For** | ETL, Data Transformation |

* * *

# **📒 In-Depth Notes on Apache Flume**

## **🚀 What is Apache Flume?**

Apache Flume is a **distributed data ingestion tool** designed for efficiently collecting, aggregating, and moving **large volumes of streaming data** (e.g., logs, events) from **various sources** to **HDFS, HBase, or Kafka**.

* * *

## **🔹 Why Use Flume?**

✅ **Reliable Streaming Data Pipeline** – Flume ensures **fault-tolerant** data transfer.
✅ **Handles Huge Data Volumes** – Ideal for **log aggregation** (e.g., web servers, application logs).
✅ **Flexible & Scalable** – Supports **multiple sources & destinations** (HDFS, HBase, Kafka).
✅ **Event-Driven Processing** – Uses a **push-pull model** to transfer data.
✅ **Easy to Configure & Extend** – Simple **configuration-based** setup using **Flume agents**.

* * *

## **🔹 Flume Architecture**

### **1️⃣ Core Concepts**

| **Component** | **Description** |
| --- | --- |
| **Source** | Ingests data from logs, files, Twitter, Kafka, etc. |
| **Channel** | Acts as a buffer between source and sink. Stores data temporarily. |
| **Sink** | Sends data to destinations like HDFS, HBase, or Kafka. |
| **Agent** | A JVM process running source, channel, and sink components. |
| **Event** | A unit of data transported in Flume (usually log lines or records). |

### **2️⃣ Flume Workflow**

1.  **Source** reads data (e.g., from logs, Twitter, syslog).
2.  Data is **stored temporarily in a Channel** (memory, file, or database).
3.  **Sink** writes data to HDFS, HBase, or another target.

📌 **Example:** Streaming logs from `/var/log/syslog` to HDFS

```
Syslog → Flume Source → Flume Channel → Flume Sink → HDFS
```

* * *

## **🔹 Flume Installation & Setup**

### **1️⃣ Download & Install Flume**

```bash
wget https://dlcdn.apache.org/flume/1.9.0/apache-flume-1.9.0-bin.tar.gz
tar -xvzf apache-flume-1.9.0-bin.tar.gz
mv apache-flume-1.9.0 /usr/local/flume
```

### **2️⃣ Configure Environment Variables**

Edit `~/.bashrc`:

```bash
export FLUME_HOME=/usr/local/flume
export PATH=$FLUME_HOME/bin:$PATH
```

Apply changes:

```bash
source ~/.bashrc
```

### **3️⃣ Verify Flume Installation**

Check version:

```bash
flume-ng version
```

* * *

## **🔹 Flume Configuration File**

Flume is **configured using `.conf` files**.

### **Example: Streaming Logs to HDFS**

📌 **Configuration File: `flume-hdfs.conf`**

```properties
# Define the agent name
agent.sources = log_source
agent.channels = memory_channel
agent.sinks = hdfs_sink

# Source: Monitor logs in /var/log/syslog
agent.sources.log_source.type = exec
agent.sources.log_source.command = tail -F /var/log/syslog

# Channel: Memory buffer
agent.channels.memory_channel.type = memory
agent.channels.memory_channel.capacity = 1000
agent.channels.memory_channel.transactionCapacity = 100

# Sink: Store data in HDFS
agent.sinks.hdfs_sink.type = hdfs
agent.sinks.hdfs_sink.hdfs.path = hdfs://hadoop-master:9000/user/flume/logs/
agent.sinks.hdfs_sink.hdfs.fileType = DataStream
agent.sinks.hdfs_sink.hdfs.writeFormat = Text
agent.sinks.hdfs_sink.hdfs.rollInterval = 10

# Link Source, Channel, and Sink
agent.sources.log_source.channels = memory_channel
agent.sinks.hdfs_sink.channel = memory_channel
```

* * *

## **🔹 Running Flume**

### **1️⃣ Start Flume Agent**

```bash
flume-ng agent --conf /usr/local/flume/conf/ --conf-file /usr/local/flume/conf/flume-hdfs.conf --name agent -Dflume.root.logger=INFO,console
```

### **2️⃣ Verify Data in HDFS**

```bash
hdfs dfs -ls /user/flume/logs/
```

```bash
hdfs dfs -cat /user/flume/logs/flume-logs.123456789
```

* * *

## **🔹 Advanced Flume Use Cases**

### **1️⃣ Streaming Twitter Data into HDFS**

📌 **Configuration File: `flume-twitter.conf`**

```properties
agent.sources = twitter_source
agent.channels = memory_channel
agent.sinks = hdfs_sink

# Twitter Source
agent.sources.twitter_source.type = org.apache.flume.source.twitter.TwitterSource
agent.sources.twitter_source.consumerKey = YOUR_CONSUMER_KEY
agent.sources.twitter_source.consumerSecret = YOUR_CONSUMER_SECRET
agent.sources.twitter_source.accessToken = YOUR_ACCESS_TOKEN
agent.sources.twitter_source.accessTokenSecret = YOUR_ACCESS_SECRET
agent.sources.twitter_source.keywords = Hadoop, BigData, Flume

# Channel
agent.channels.memory_channel.type = memory

# Sink: Store data in HDFS
agent.sinks.hdfs_sink.type = hdfs
agent.sinks.hdfs_sink.hdfs.path = hdfs://hadoop-master:9000/user/flume/twitter/
agent.sinks.hdfs_sink.hdfs.writeFormat = Text
agent.sinks.hdfs_sink.hdfs.rollInterval = 60

# Link Source, Channel, and Sink
agent.sources.twitter_source.channels = memory_channel
agent.sinks.hdfs_sink.channel = memory_channel
```

* * *

## **🔹 Automating Flume with Oozie**

Flume can be scheduled **using Oozie workflows**.

📌 **Workflow: `flume-workflow.xml`**

```xml
<workflow-app name="flume-ingest" xmlns="uri:oozie:workflow:0.5">
    <start to="flume-node"/>

    <action name="flume-node">
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
        <ok to="end"/>
        <error to="fail"/>
    </action>

    <kill name="fail">
        <message>Flume Job Failed</message>
    </kill>

    <end name="end"/>
</workflow-app>
```

📌 **Run the Oozie Job**

```bash
oozie job -config job.properties -run
```

* * *

## **🚀 Summary**

| **Feature** | **Apache Flume** |
| --- | --- |
| **Purpose** | Real-time data ingestion |
| **Data Sources** | Logs, Twitter, Kafka, Syslog, Files |
| **Destinations** | HDFS, HBase, Kafka, Solr |
| **Reliability** | Guaranteed delivery with channels |
| **Best For** | Streaming log processing |

* * *

# **📒 In-Depth Notes on Apache Oozie**

Apache Oozie is a **workflow scheduler system** for managing **Hadoop jobs**. It helps automate **data ingestion (Flume), processing (Pig, Hive), and storage (HDFS, HBase)** using a **time-based** or **event-based** scheduling system.

* * *

## **🚀 Why Use Apache Oozie?**

✅ **Automates Data Pipelines** – Schedule workflows for **Flume (ingestion), Pig (processing), Hive (storage)**.
✅ **Supports Multiple Job Types** – Works with **MapReduce, Spark, Hive, Pig, Sqoop, Flume, and Shell scripts**.
✅ **Handles Dependencies** – Ensures jobs **run in order** and retries on failure.
✅ **Time-Based or Event-Based Scheduling** – Run jobs at **specific times** or when **data arrives**.
✅ **Error Handling & Notifications** – Supports **email alerts and error recovery**.

* * *

## **🔹 Oozie Architecture**

Oozie uses **XML-based workflows** to define the execution sequence.

### **1️⃣ Core Components**

| **Component** | **Description** |
| --- | --- |
| **Workflow** | Defines job steps using **XML**. |
| **Coordinator** | Schedules workflows at **time intervals** or when **new data arrives**. |
| **Bundle** | Groups multiple workflows to run together. |
| **Action** | Represents a **task** (MapReduce, Pig, Hive, Shell, Flume, Sqoop). |
| **Control Nodes** | `start`, `end`, `kill`, and `decision` control workflow execution. |

* * *

## **🔹 Oozie Installation & Setup**

### **1️⃣ Download & Install Oozie**

```bash
wget https://dlcdn.apache.org/oozie/5.2.1/oozie-5.2.1.tar.gz
tar -xvzf oozie-5.2.1.tar.gz
mv oozie-5.2.1 /usr/local/oozie
```

### **2️⃣ Set Environment Variables**

Edit `~/.bashrc`:

```bash
export OOZIE_HOME=/usr/local/oozie
export PATH=$OOZIE_HOME/bin:$PATH
```

Apply changes:

```bash
source ~/.bashrc
```

### **3️⃣ Configure Oozie**

```bash
cd /usr/local/oozie
mkdir -p conf
cp oozie-site.xml.template conf/oozie-site.xml
```

📌 **Edit `oozie-site.xml`**

```xml
<configuration>
    <property>
        <name>oozie.base.url</name>
        <value>http://localhost:11000/oozie</value>
    </property>
    <property>
        <name>oozie.service.JPAService.create.db.schema</name>
        <value>true</value>
    </property>
</configuration>
```

### **4️⃣ Setup Oozie Database**

```bash
bin/oozie-setup.sh db create -run
```

### **5️⃣ Start Oozie Server**

```bash
bin/oozied.sh start
```

Verify Oozie is running:

```bash
oozie admin -oozie http://localhost:11000/oozie -status
```

* * *

## **🔹 Oozie Workflow for Automating ETL**

We will define an **ETL workflow** that:

1.  **Ingests logs with Flume**
2.  **Processes data with Pig**
3.  **Stores data in Hive**
4.  **Runs on a schedule**

📌 **Workflow File: `workflow.xml`**

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
            <script>/user/hadoop/scripts/process_logs.pig</script>
        </pig>
        <ok to="hive-action"/>
        <error to="fail"/>
    </action>

    <action name="hive-action">
        <hive>
            <job-tracker>${jobTracker}</job-tracker>
            <name-node>${nameNode}</name-node>
            <script>/user/hadoop/scripts/store_logs.hql</script>
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

* * *

## **🔹 Scheduling Oozie Workflows**

We can run this workflow **on a schedule** using a **Coordinator Job**.

📌 **Coordinator File: `coordinator.xml`**

```xml
<coordinator-app name="etl-coordinator" frequency="60 * * * *" timezone="UTC" xmlns="uri:oozie:coordinator:0.2">
    <start>2025-03-10T00:00Z</start>
    <end>2025-04-10T00:00Z</end>
    <action>
        <workflow>
            <app-path>/user/hadoop/workflows/etl-workflow</app-path>
        </workflow>
    </action>
</coordinator-app>
```

📌 **Run the Oozie Coordinator Job**

```bash
oozie job -oozie http://localhost:11000/oozie -config job.properties -run
```

* * *

## **🔹 Automating Oozie Jobs with Cron**

If you don’t want to use Oozie Coordinators, you can use **Cron Jobs** to trigger Oozie workflows.

📌 **Edit Cron Job**

```bash
crontab -e
```

Add:

```bash
0 * * * * oozie job -oozie http://localhost:11000/oozie -config /usr/local/oozie/conf/job.properties -run
```

This **runs the job every hour**.

* * *

## **🔹 Monitoring Oozie Jobs**

### **1️⃣ Check Running Jobs**

```bash
oozie jobs -oozie http://localhost:11000/oozie -jobtype coordinator
```

### **2️⃣ View Job Status**

```bash
oozie job -oozie http://localhost:11000/oozie -info <job-id>
```

### **3️⃣ Kill a Job**

```bash
oozie job -oozie http://localhost:11000/oozie -kill <job-id>
```

* * *

## **🚀 Summary**

| **Feature** | **Apache Oozie** |
| --- | --- |
| **Purpose** | Automates workflows in Hadoop |
| **Works With** | Flume, Pig, Hive, Spark, Sqoop |
| **Scheduling** | Time-based or event-based |
| **Error Handling** | Automatic retries, alerts |
| **Best For** | ETL, Data Pipelines |

* * *



