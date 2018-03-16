---
title: "Kafka configuration"
---

## Configuring Kafka

When running Humio in a cluster setup it uses Kafka as part of the infrastructure. 

In this section, we briefly describe how Humio uses Kafka. Then we discuss how to konfigure Kafka.


### Queues
Humio creates the following queues in Kafka:

* global-events
* global-snapshots
* humio-ingest
* transientChatter-events

You can set the environment variable "HUMIO_KAFKA_TOPIC_PREFIX" to add that prefix to the topic names in kafka.
Adding a prefix is recommended if you share the Kafka installation with applications other than Humio.
The default is not to add a prefix.

Humio configures default retention settings on the topics when it creates them.
If they exist already, Humio does not alter retention settings on the topics.

If you wish to inspect and change the topic configurations, such as the retention settings,
to match your disk space available for Kafka, please use the kafka-configs command.
See below for an example, modifying the retention on the ingest queue to keep burst of data for up to 1 hour only.


#### global-events 
This is Humios event sourced database queue. This queue will contain small events, and has a pretty low throughput.
No log data is saved to this queue. There should be high number of replicas for this queue.

Default retention configuration: retention.ms = 30 days

#### global-snapshots
This is Humios database snapshot queue. This queue will contain fairly large events, and has a pretty low throughput.
No log data is saved to this queue. There should be high number of replicas for this queue.

Default retention configuration: retention.ms = 30 days

#### humio-ingest
Ingested events are send to this queue, before they are stored in Humio. Humios frontends will accept ingest requests, parse them and put them on the queue.
The backends of Humio is processing events from the queue and storing them into Humios datastore.
This queue will have high throughput corresponding to the ingest load.
The number of replicas can be configured in accordance with datasize, latency and throughput requirements and how important it is not too lose in flight data.
When data is stored in Humios own datastore, we don't need it on the queue anymore.

Default retention configuration: retention.ms = 48 hours

#### transientChatter-events
This queue is used for chatter between Humio nodes.  It is only used for transient data.
The queue can have a short retention and it is not important to keep the data, as it gets stale very fast.

Default retention configuration: retention.ms = 1 hours

### Configuration

humio has some built in [API endpoints for controling kafka](/http-api-on-premises.md). Using the API it is possible to specify partition size, replication factor etc on the ingest queue.

It is also possible to use other Kafka tools, such as the command line tools included in the kafka distribution.


#### Setting retention on the ingest queue
Show ingest queue configuration. (This only shows properties set specifically for the topic - not the default ones specified in kafka.properties
```
<kafka_dir>/bin/kafka-configs.sh --zookeeper $HOST:2181 --entity-name humio-ingest --entity-type topics --describe 
```

Set retention on the ingest queue to 1 hour.

```
<kafka_dir>/bin/kafka-configs.sh --zookeeper $HOST:2181 --entity-name humio-ingest --entity-type topics --alter --add-config retention.ms=3600000
```

Set retention on the ingest queue to 1GB (per partition)

```
<kafka_dir>/bin/kafka-configs.sh --zookeeper $HOST:2181 --entity-name humio-ingest --entity-type topics --alter --add-config retention.bytes=1073741824
```

{{% notice note %}}
The setting `retention.bytes` is per partition. By default Humio has 24 partitions for ingest.
{{% /notice %}}

