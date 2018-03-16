
[Filebeat](https://www.elastic.co/products/beats/filebeat) is a lightweight, open source program that can monitor log files and send data to servers like Humio.

Filebeat has some properties that make it a great tool for sending file data to Humio:

* **It uses few resources.**

    This is important because the Filebeat agent must run on each server that you want to capture data from.

* **It is easy to install and run.**

    Filebeat is written in the Go programming language, and is built into one binary.

* **It handles network problems gracefully.**

    When Filebeat reads a file, it keeps track of the last point that it has read to. If there is no network connection, then Filebeat waits to retry data transmission. It continues data transmission when the connection is working again.


!!! Note "Official documentation"
    Check out Filebeat's [official documentation](https://www.elastic.co/guide/en/beats/filebeat/current/index.html).

## Installation

To download Filebeat, visit the [Filebeat downloads page](https://www.elastic.co/downloads/beats/filebeat)

!!! note "Installation documentation"
    You can find installation documentation for Filebeat at [the Filebeat Installation page of the official Filebeat website](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-installation.html).

## Configuration

Humio supports parts of the Elasticsearch bulk ingest API.
Data can be sent to Humio by configuring Filebeat to use the built in Elastic Search output.

!!! Note "Configuration documentation"
    You can find configuration documentation for Filebeat at [the Filebeat configuration page of the official Filebeat website](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-configuration-details.html).

The following example shows a simple Filebeat configuration that sends data to Humio:

``` yaml
filebeat.prospectors:
- paths:
    - <path-to-your-application-log>
  encoding: utf-8
  fields:
    "type": <name-of-your-application-log-parser>

output:
  elasticsearch:
    hosts: ["<host>/api/v1/dataspaces/<dataspace>/ingest/elasticsearch"]
    username: <ingest-token>
    compression_level: 5
    bulk_max_size: 50

```

!!! tip
    The Filebeat configuration file is located at `/etc/filebeat/filebeat.yml` on Linux.

You must make the following changes to the sample configuration:

* Insert a `path` section for each log file you want to monitor.
It is possible to insert a prospector configuration (with `paths` and `fields` etc) for each file that filebeat should monitor
* Specify the type of the events. Humio will use the type field to decide which parser it will use to parse the incoming events.
This is done by specifying the `type` field in the fields section. See the Parsing Data section below.
* Add other fields in the fields section. These fields, and their values, will be added to each event.
* Insert the URL containing the Humio host in the `hosts` field in the Elasticsearch output. For example `https://cloud.humio.com:443`
Note that the URL specifies the Data Space that Humio sends events to. 
In the example, the URL points to Humio in the cloud, which is fine if you are using our hosted service.  
It is important to specify the port number in the URL otherwise Filebeat defaults to using 9200.
* Insert an [ingest token](/ingest-tokens.md) from the dataspace as the username.
* Specify the text encoding to use when reading files using the `encoding` field. If the log files use special, non-ASCII characters, then set the encoding here. For example, `utf-8` or `latin1`.

* If all your events are fairly small, you can increase `bulk_max_size` from the default of 50. The default of 50 is fine for most use cases.
  But keep bulk_max_size low, as you may get "Failed to perform any bulk index operations: 413 Request Entity Too Large" if a requestends up being too large, measured in bytes, not in number of events.

## Running Filebeat
Run Filebeat as a service on Linux with the following commands
```
sudo systemctl enable filebeat
sudo systemctl restart filebeat 
```

!!! Note "Testing filebeat"
    On linux Filebeat is often placed at `/usr/share/filebeat/bin/filebeat` 
    To test it can be run like `/usr/share/filebeat/bin/filebeat -c /etc/filebeat/filebeat.yml` 


## Parsing data
Humio uses parsers to parse the data from Filebeat into events.
Parsers can extract fields from the text strings an add structure to the events.
For more information on parsers, see [parsing](/parsing.md).

!!! Note
    Take a look at Humio's [built-in parsers](/built-in-parsers.md).

You can specify the parser/type for each monitored file using the `type` field in the fields section in the Filebeat configuration.  
If not specifying a type, Humios built in key value parser (`kv`) will be used.
The key value parser expects the incoming string to start with a timestamp formatted in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601).
It will also look for key value pairs in the string on the form a=b

For example, when sending a web server access log file to Humio, you can use the built-in Humio access log parser by specifying `type=accesslog`.

### Parsing JSON data

Humio supports [JSON parsers](/parsing.md).
Filebeat processes logs line by line, so JSON parsing will only work if there is one JSON object per line.
Customize a JSON parser in Humio,  (do not use the JSON parsing built into filebeat).


## Adding fields
It is possible to add fields with static values using the fields section. These fields will be added to the each event.

### Default fields
Filebeat automatically sends the host (`beat.hostname`) and filename (`source`) along with the data. Humio adds theese fields to each event.
The fields are added as `@host` and `@source` (to try not to collide with other fields in the event).

!!! tip
     To avoid having the `@host` and `@source` fields, specify `@host` and `@source` in the `fields` section and provide an empty value.

## Tags
Humio saves data in Data Sources. You can provide a set of Tags to specify which Data Source the data is saved in.  
See [glossary](/glossary.md#tags) for more information about tags and Data Sources.  
The `type` configured in Filebeat is always used as tag. Other fields can be used as tags as well by defining the fields as `tagFields` in the [parser](/parsing.md) pointed to by the `type`.  
In Humio tags always start with a #. When turning a field into a tag it will be prepended with #.


## Multiline events
By default, Filebeat creates one event for each line in the in a file. However, you can also split events in different ways.
For example, stack traces in many programming languages span multiple lines.

You can specify multiline settings in the Filebeat configuration.
!!! Note "Multiline documentation"
    [See Filebeats official multiline configuration documentation](https://www.elastic.co/guide/en/beats/filebeat/master/multiline-examples.html)

Often a log event starts with a timestamp and we want to read all lines until we see a new line starting with a timestamp.
In filebeat that can be done like this:
```
multiline.pattern: '^[0-9]{4}-[0-9]{2}-[0-9]{2}'
multiline.negate: true
multiline.match: after
```
The `multiline.pattern` should match your timestamp format

## Full configuration example

``` yaml
filebeat:
  prospectors:
    - paths:
        - /var/log/nginx/access.log
      fields:
        type: accesslog
    - paths:
        - humio_std_out.log
      fields:
        type: humio
      multiline:
        pattern: '^[0-9]{4}-[0-9]{2}-[0-9]{2}'
        negate: true
        match: after

output:
  elasticsearch:
    hosts: ["https://cloud.humio.com:443/api/v1/dataspaces/test/ingest/elasticsearch"]
    username: "ingest-token"
    compression_level: 5
    bulk_max_size: 50

logging:
  level: info
  to_files: true
  to_syslog: false
  files:
    path: /var/log/filebeat
    name: filebeat.log
    keepfiles: 3
    
```
