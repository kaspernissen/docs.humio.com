---
title: "Beats"
---

The [Elastic Beats](https://www.elastic.co/products/beats) are a
great group of data shippers. They are cross-platform, lightweight, and can ship data to a number of tools **including Humio**.

All Beats are built using the [libbeat library](https://github.com/elastic/beats). Along with the official Beats, there are a growing number of
[community Beats](https://www.elastic.co/guide/en/beats/libbeat/current/community-beats.html).


## Available Beats

There are currently five official Beats. The Elastic documentation site and Humio's documentation offer resources that describe how to use each of them:

* **[Filebeat](https://www.elastic.co/guide/en/beats/filebeat/current/index.html)** - Ships regular log files.
    * [Get Started](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-getting-started.html)
    * [Humio's Filebeat documentation](/sending_logs_to_humio/log_shippers/beats/filebeat/)

* **[Metricbeat](https://www.elastic.co/guide/en/beats/metricbeat/current/index.html)** - Ships metrics from your OS and common services.
    * [Get Started](https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-getting-started.html)
    * [Humio's Metricbeat documentation](/sending_logs_to_humio/log_shippers/beats/metricbeat/)

* **[Packetbeat](https://www.elastic.co/guide/en/beats/packetbeat/current/index.html)** - Analyzes network packets and common protocols like HTTP
    * [Get Started](https://www.elastic.co/guide/en/beats/packetbeat/current/packetbeat-getting-started.html)

* **[Winlogbeat](https://www.elastic.co/guide/en/beats/winlogbeat/current/index.html)** - Ships Windows event logs
    * [Get Started](https://www.elastic.co/guide/en/beats/winlogbeat/current/winlogbeat-getting-started.html)

* **[Heartbeat](https://www.elastic.co/guide/en/beats/heartbeat/current/index.html)** - Checks system status and availability
    * [Get Started](https://www.elastic.co/guide/en/beats/heartbeat/current/heartbeat-getting-started.html)

{{% notice note %}}
***Community Beats***

In addition, the Elastic community has created many other Beats that you can download and use.

These [Community Beats](https://www.elastic.co/guide/en/beats/libbeat/current/community-beats.html) cover many less common use cases.
{{% /notice %}}

## General Output Configuration

All beats are built using the [libbeat library](https://github.com/elastic/beats) and
share output configuration.  Humio supports parts of the Elasticsearch
ingest API, so to send data from Beats to Humio, you just use the
[Elasticsearch output](https://www.elastic.co/guide/en/beats/filebeat/current/elasticsearch-output.html)
(the documentation is identical for all Beats).

You can use the following `elasticsearch` output configuration template:

``` yaml
output:
  elasticsearch:
    hosts: ["https://<humio-host>/"]
    username: <ingest-token>
```
Where:

* `<humio-host>` - is the name of your Humio server
* `<ingest-token>` - is the [ingest token](/sending_logs_to_humio/ingest_tokens/) for your dataspace

{{% notice note %}}
To optimize performance for the data volumes you want to send, and to keep shipping latency down, change the default settings for `compression_level`, `bulk_max_size` and `flush_interval`.
{{% /notice %}}

## Adding fields

All Beats also have a `fields` section in their configuration. You can add fields to all events by specifying them in the `fields` section:

``` yaml
fields:
    service: user-service
    datacenter: dc-a
```
