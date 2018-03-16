---
title: "Metricbeat"
---

[Metricbeat](https://www.elastic.co/products/beats/metricbeat) is a lightweight tool for collecting and shipping metrics.

Metricbeat collects a large set of valuable system metrics, including:

* CPU usage statistics
* Memory statistics
* File and disk IO statistics
* Per-process statistics
* Network and socket statistics

On top of the system-level statistics, Metricbeat comes with modules that offer integrations to many well-known services like `Docker`, `MongoDB`, and `MySQL`.
Check out [the Modules page at the official Metricbeat documentation](https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-modules.html) for more details on these integrations and how they work.


!!! Note "Official documentation"
    You can read all the official documentation on Metricbeats [at the Metricbeat website](https://www.elastic.co/guide/en/beats/metricbeat/current/index.html).

## Installation

To download Metricbeat, visit the [Metricbeat downloads page](https://www.elastic.co/downloads/beats/metricbeat).

!!! Note "Installation documentation"
    You can find installation documentation for Metricbeat at [the Installation page of the official Metricbeat website](https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-installation.html).


## Configuration


Because Humio supports parts of the Elasticsearch insertion API, you can send data from Metricbeat to Humio by configuring Metricbeat to use the built-in Elasticsearch output.

!!! Note "Configuration documentation"
    You can find configuration documentation for Metricbeat at [the Metricbeat configuration page of the official Metricbeat website](https://www.elastic.co/guide/en/beats/metricbeat/current/configuring-howto-metricbeat.html).


The following example shows a simple Metricbeat configuration collecting host metrics and sending them to Humio:

``` yaml
metricbeat.modules:
  - module: system
    enabled: true
    period: 10s
    metricsets:
      - cpu
      - load
      - filesystem
      - fsstat
      - memory
      - network
      - socket # linux only

output.elasticsearch:
  hosts: ["https://<humio-host>:443/api/v1/dataspaces/<dataspace>/ingest/elasticsearch"]
  username: <ingest-token>
```

Where:

* `<humio-host>` - is the name of your Humio server
* `<dataspace>` - is the name of your dataspace on your server
* `<ingest-token>` - is the [ingest token](/ingest-tokens.md) for your dataspace

!!! tip "Configuration file"
    The Metricbeat configuration file is located at `/etc/metricbeat/metricbeat.yml` on Linux.

## Running Metricbeat
Run Metricbeat as a service on Linux with the following commands
```
sudo systemctl enable metricbeat
sudo systemctl restart metricbeat 
```

## Adding fields
You can add fields with static values using the `fields` section. These fields will be added to the each event.

### Default fields
Metricbeat automatically sends the host name of the system along with the data. Humio adds the host name in the `@host` field to each event. It uses this field name to try not to collide with other fields in the event.


## Host metrics example queries

Once you have data from Metricbeat in Humio, you can run some interesting queries, such as the following examples:

* Show CPU load for each host:
 > `#type=beat | timechart(series=@host, function=max(system.load.1, as=load))`

* Show memory usage for each host:
 > `#type=beat | timechart(series=@host, function=max(system.memory.actual.used.bytes))`

* Show disk free space (in gigabytes):
 > `#type=beat @host=host1  system.filesystem.mount_point="/" | timechart(function=min(system.filesystem.free, as=free)) | eval(free=free/(1024*1024*1024))`

* Disk IO - show bytes read for each disk:
 > `#type=beat @host=host1 | system.diskio.read.bytes=* | timechart(series=system.diskio.name, function=counterrate(system.diskio.read.bytes), span=1m)`

* Network traffic - Show bytes sent on the `eth0` interface:
 > `#type=beat @host=host1 system.network.name=eth0 | timechart(function=count(system.network.out.bytes), span=1m)`

* Show the top 10 processes using the most CPU:
 > `#type=beat | system.process.name=* | groupby(system.process.name, function=avg(system.process.cpu.total.pct, as=cpu)) | sort(cpu, limit=10)`
