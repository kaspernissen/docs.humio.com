---
title: "Humio environment variables"
---

This describes the configuration parameters for Humio, and their default values.
Please see [the installation instructions](installation.md) on where to place the configuration file.

```
# JVM arguments. Make sure to increase stac size to at least 2M (-Xss2M) and allow XX:MaxDirectMemorySize to be at least half of available RAM.
# You may also need to add -Xmx4 to allow 4G of heap space, but on systems with plenty of memory and JDK8 or newer, the JRE defaults are okay.
# You can tune "Akka" configurations using -Dconfig.file=/home/humio/akka.conf and -Dakka.log-config-on-start=on. notably akka.http.server, through the file referred by config.file. (Remember to mount using -v on docker)
HUMIO_JVM_ARGS=-Xss2M -XX:MaxDirectMemorySize=4G

# License key. Required if you are not running Humio as a trial version. Set one of these.
#LICENSE_KEYSTRING=SomeLongStringYouHaveFromHumioSales
# - or -
#LICENSE_FILE=PAthToFileHoldingKeyString


# Make Humio write a backup of the data files. The BACKUP_KEY is user fdor encryption.
#BACKUP_NAME=
#BACKUP_KEY=

# ID to choose for this server when starting up the first time.
# Leave commented out to autoselect the next available ID.
# If set, the server refuses to run unless the ID matches the state in data.
# If set, must be a (small) positive integer.
#BOOTSTRAP_HOST_ID=1

# The URL that other hosts can use to reach this server. Required.
# Examples: https://humio01.example.com  or  http://humio01:8080
# Security: We recommend using a TLS endpoint.
# If all servers in the Humio cluster share a closed LAN, using those endpoints may be okay.
#EXTERNAL_URL=https://humio01.example.com

# Kafka bootstrap servers list. Used as `bootstrap.servers` towards kafka.
# should be set to a comma separated host:port pairs string.
# Example: `my-kafka01:9092` or `kafkahost01:9092,kafkahost02:9092`
#KAFKA_SERVERS=kafkahost01:9092,kafkahost02:9092

# Zookeeper servers.
# Defaults to "localhost:2181", which is okay for a single server system, but
# should be set to a comma separated host:port pairs string.
# Example: zoohost01:2181,zoohost02:2181,zoohost03:2181
# Note, there is NO security on the zookeeper connections. Keep inside trusted LAN.
#ZOOKEEPER_URL=localhost:2181

# Possible to use this if Humio is behind a proxy.
# Add a subpath to the url where Humio is hosted
# For examplea proxy at `http://myorg.com/` could expose Humio at `http://myorg.com/internal/humio/`. Then PROXY_PREFIX_URL=/internal/humio 
#PROXY_PREFIX_URL=/internal/humio

# Humio limits the allowed memory one query can use. It is possible to disable this at on-premises installations
ALLOW_UNLIMITED_STATE_SIZE=false

# Settings controlling auto-sharding.
MAX_DISTINCT_TAG_VALUES=5000
TAG_HASHING_BUCKETS=16

# Setting controlling auto-tagging of datasources with too much data for one stream. Defaults to 6MB/s.
AUTOSHARDING_TRIGGER_SPEED=6291456

# Number of blocks of 1MB stored in each segment. You can raise this to e.g 1000 or perhaps 4000 to get fewer, larger segments files. Minimum is 100.
BLOCKS_PER_SEGMENT=1000

# If a query is not used (polled) - how long should Humio wait until it does not keep the query running 
IDLE_POLL_TIME_BEFORE_LIVE_QUERY_IS_CANCELLED_MINUTES=60

# Limit size of internal state of each query internally in the cluster in bytes. Defaults to MaxHeapSize/128
# When a query results in larger results, the query is aborted, and gets a warning of "State too large. Lower your limits to get results."
# If you have few but large queries, you may increase this to e.g. MaxHeapSize/32 or even MaxHeapSize/16, but with a high risk of OOM.
#MAX_INTERNAL_STATESIZE=...

# How long should the `sensitive` part of the audit log be kept. Default to 200 years.
# Set as number of days. Example: 10 years = 3653 days.
#AUDITLOG_SENSITIVE_RETENTION_DAYS=3653


```
