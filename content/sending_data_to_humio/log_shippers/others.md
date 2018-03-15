
Humio supports the following API's for ingesting data.

## Humio Ingest API

Humio has an [Ingest API](../../http-api.md#ingest).  You can use this
to build an integration towards Humio.

## Elasticsearch Bulk API

Humio is compatible with the [Elasticsearch Bulk ingest
API](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html).

If you have a log shipper that supports the Elasticsearch Bulk API,
there is a good change that you can use this to send logs to Humio.
See the [Beats documentation](beats.md) for an example of
configuration options.

Contact us if you have trouble getting this working.

<!--
## rsyslogd using omelasticsearch module - unsupported.
module(load="omelasticsearch")
template(name="testTemplate"
         type="list"
         option.json="on") {
           constant(value="{")
             constant(value="\"timestamp\":\"")      property(name="timereported" dateFormat="rfc3339")
             constant(value="\",\"@type\":\"")        constant(value="syslog-utc")
             constant(value="\",\"message\":\"")     property(name="msg")
             constant(value="\",\"host\":\"")        property(name="hostname")
             constant(value="\",\"severity\":\"")    property(name="syslogseverity-text")
             constant(value="\",\"facility\":\"")    property(name="syslogfacility-text")
             constant(value="\",\"syslogtag\":\"")   property(name="syslogtag")
           constant(value="\"}")
         }
action(type="omelasticsearch"
       server="unsupported.humio.com"
       serverPort="9200"
       uid="INGEST-TOKEN-HERE"
       pwd=""
       template="testTemplate"
       searchIndex="docker2humio"
       searchType="ingest"
       bulkmode="on"
       #maxbytes="1m"
       queue.type="linkedlist"
       queue.size="50"
       queue.dequeuebatchsize="3"
       action.resumeretrycount="2")

$DebugFile /tmp/rsyslog-debug
$DebugLevel 2
-->
