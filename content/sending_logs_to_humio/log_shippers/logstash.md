---
title: "Logstash"
---

Logstash is an established open source tool for collecting logs,
parsing them and outputting them to other systems.

You can use Logstash alongside Humio to process and analyze logs
together. In this scenario, you use Logstash as the log collection and
parsing agent, and instruct it to send the data to Humio.

{{% notice tip %}}
***Humio supports the Elasticsearch bulk insertion API*** 

Just point the Elastic  outputter to Humio as described [here](logstash.md#configuration)
{{% /notice %}}


The benefit of this approach is that you can take advantage of the
extensible architecture of Logstash to parse many kinds of data:

* You can install one of the many available plugins that can parse
  many well-known data formats.

* You can use the Grok language to build custom parsers for unusual
  data formats. Grok has many built-in patterns to help parse your
  data.

### Installation

To download Logstash, visit the [Logstash downloads page](https://www.elastic.co/downloads/logstash).

{{% notice note %}}
You can find the complete documentation for Logstash at [the Reference page of the official Logstash website](https://www.elastic.co/guide/en/logstash/current/index.html).
{{% /notice %}}


### Configuration

Because Humio supports parts of the Elasticsearch insertion API, you
can use the built-in `elasticsearch` output in the Logstash
configuration.

The following example shows a very simple Logstash configuration that
sends data to Humio:

```
input{
  exec{
    command => "date"
    interval => "5"
  }
}
output{
  elasticsearch{
    hosts => ["https://<humio-host>:443/api/v1/dataspaces/<dataspace>/ingest/elasticsearch/"]
    user => "<ingest-token>"
    password => "notused" # a password has to be set, but Humio does not use it
  }
}
```

Where:

* `<humio-host>` - is the name of your Humio server
* `<dataspace>` - is the name of your dataspace on your server
* `<ingest-token>` - is the [ingest token](/ingest-tokens.md) for your dataspace


In the above example, Logstash calls the Linux `date` command every
five seconds. It passes the output from this command to Humio.

#### Field mappings

When you use the Elasticsearch output, Logstash outputs JSON
objects. The JSON for an event sent to Humio with the above
configuration looks like this:

```json
{
  "@timestamp": "2016-08-25T08:34:37.041Z",
  "message": "Thu Aug 25 10:34:37 CEST 2016\n",
  "command": "date"
}
```

Humio maps each JSON object into an Event. Each field in the JSON
object becomes a field in the Humio Event.

Humio treats some fields as special cases:

| Name                     |   Description |
---------------------------|---------------|
| `@timestamp`             | This field must be present, and contain the timestamp in ISO 8601 format. This format is: `yyyy-MM-dd'THH:mm:ss.SSSZ`. <br /><br />You can specify the timezone (like +00:02) in the timestamp. Specify the time zone if you want Humio to save this information. Logstash adds the `@timestamp` field automatically. <br /><br />Depending on the configuration, the timestamp can be the time at which Logstash handles the event, or the actual timestamp in the data. If the timestamp is present in the data, you can configure logstash to parse it, for example, by using the date filter. |
| `message`                | If present, Humio treats this field as the rawstring of the event. <br /><br />Humio maps this field to the `@rawstring` field, which is textual representation of the raw event in Humio. <br /><br />If you do not provide the message or rawstring field, then the rawstring representation is the JSON structure as text. |
| `rawstring`              | This field is similar to the `message` field. <br /><br />If you provide both fields, then Humio uses the `message` field. The reason for having both is that some Logstash integrations automatically set a message field representing the raw string. <br /><br />In Humio, we use the name rawstring. |

#### Dropping fields

Logstash often adds fields like `host` and `@version` to events. You
can remove these fields using a filter and the `drop_field` function
in Logstash.
