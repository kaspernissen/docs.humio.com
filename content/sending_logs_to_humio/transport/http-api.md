---
title: "HTTP API"
---

## Overview


This page provides information about the HTTP API that Humio provides.

<h4>Variables</h4>

This documentation uses the following variables to show places where you should replace the data in each example request with your own data:

* `$DATASPACE`: The identifier of a specific data space, for example `github` or `myapplication`.
* `$API_TOKEN`: Your [API token](#api-token).
* `$PARSER`: The identifier of a specific parser.

<h4>Available Endpoints</h4>

| Endpoint | Method | Description
|-----------|---------|------------
|`/api/v1/dataspaces/$DATASPACE/query`|[POST](#query)| Run a streaming query
|`/api/v1/dataspaces/$DATASPACE/queryjobs`| [POST](#create) | Run a poll-based query
|`/api/v1/dataspaces/$DATASPACE/queryjobs/$ID`| [GET](#poll)<br><br>[DELETE](#delete) | Poll a poll-based query<br><br>Delete a poll-based query
|`/api/v1/dataspaces/$DATASPACE/ingest-messages`| [POST](#ingest) | Put data into Humio
|`/api/v1/dataspaces/$DATASPACE/ingest`| [POST](#ingest) | Put data into Humio
|`/api/v1/dataspaces/$DATASPACE/files`| [POST](#files) | Upload CSV or JSON data to use with `lookup()` function
|`/api/v1/dataspaces/$DATASPACE/parsers`| [GET](#list-parsers) | List all parsers
|`/api/v1/dataspaces/$DATASPACE/parsers/$PARSER`| [PUT](#create-or-update-parser) | Add a new parser
|`/api/v1/dataspaces/$DATASPACE/parsers/$PARSER`| [DELETE](#delete-parser) | Delete a parser


### HTTP Headers


This section describes the HTTP headers that you can use with the Humio API.


### API token


To use the HTTP API, you must provide an API token using the `Authorization` header.

!!! note
    You can find your API token on the web application's front page (after login) by clicking the 'Account', then the 'Show' button.

    ![API Token](images/api-token.png)

Example:

```bash
curl https://demo.humio.com/api/v1/dataspaces/github/query \
 -X POST \
 -H 'Content-Type: application/json' \
 -H "Authorization: Bearer $API_TOKEN" \
 -d '{"queryString":"count()"}'
```

on-premises installs can also use [API token for local root access](/http-api-on-premises.md#api-token-for-local-root-access).

### Compression

All API calls support compression using deflate and GZIP.

Example:

```bash
curl https://demo.humio.com/api/v1/dataspaces/github/query \
 -X POST \
 -H 'Content-Type: application/json' \
 -H "Authorization: Bearer $API_TOKEN" \
 -H 'Accept-Encoding: gzip' \
 -d '{"queryString":"count()"}'
```
<!--
To request a gzip compressed response -->


## Query


This is the main endpoint for executing queries in Humio.

This endpoint streams results as soon as they are calculated, but depending on
the query type ([filter](glossary#filter-queries) or
[aggregate](glossary#aggregate-queries)), the time of delivery changes.  The following table illustrates this:

|                | Live query                                   | Standard query                                   |
|:--------------:|:--------------------------------------------:|:------------------------------------------------:|
| **Filter**     | Streaming                                    | Streaming                                        |
| **Aggregate**  | Error (use [query jobs](#query-jobs-create)) | "Streaming" (but result will only come at the end) |

The endpoint streams results for **filter queries** as they happen.

For **aggregate standard queries**, the
result is not ready until the query has processed all events in the
query interval. The request is blocked until the result is ready. It is at this point that Humio sends the result back.

For **aggregate live queries**, this endpoint returns an error. What
you want in this situation is to get a snapshot of the complete result
set at certain points in time (fx every second), but the query end
point does not support this behavior. Instead, you should use the [query
job endpoint](#query-jobs-create) and then poll the result when you need it.



<!-- This query API is designed for integrations. It is possible to
stream large amounts of data out of Humio or to make a blocking query
waiting for the final result.  How the data is returned depends on the
query. If an [aggregate function](glossary#aggregate-queries) is used,
the server cannot return the result until the query has finished.  It
is possible to use the [polling query
endpoint](http-api.md#poll-based-query.md) to continuously poll for
partial results. This is what the Humio UI does.  If the query is not
using aggregate functions, like filter queries, the result can be
streamed as events are found.  [Live
queries](glossary.md#live-queries) are continuous queries that newer
ends. A live query that aggregates data is not suited for this
endpoint. Use the [polling query
endpoint](http-api.md#poll-based-query.md).  This is illustrated in
the table below.  -->


### Request

To start a query, POST the query to:

``` text
POST /api/v1/dataspaces/$DATASPACE/query
```

The JSON request body has the following attributes:

Name        | Type   | Required     | Description
----------- | ------ | ------------ | -------------
`queryString` | string |  Yes         | The actual query. See [Query language](query-language.md) for details
`start`       | Time   |  No          | The start date and time. This parameter tells Humio not to return results from before this date and time. You can learn how to specify a time [here](http-api.md#time).
`end`         | Time   |  No          | The end date and time.  This parameter tells Humio not to return results from after this date and time. You can learn how to specify a time [here](http-api.md#time)
`isLive`      | boolean|  No         | Sets whether this query is live. Defaults to `false`. Live queries are continuously updated.
`timeZoneOffsetMinutes`      | number|  No   | Set the time zone offset used for `bucket()` and `timechart()` time slices, which is significant if the corresponding `span` is multiples of days.  Defaults to `0` (UTC); positive numbers are to the east of UTC, so for `UTC+01:00` timezone the value `60` should be passed.
`arguments`   | object|  No   | Dictionary of arguments specified in queries with `?param` or `?{param=defaultValue}` syntax.  Provided arguments must be a simple dictionary of string values. If an argument is given explicitly as in `?query(param=value)` then that value overrides values provided here.

If you use this API from a browser application, you may want to trigger "direct download".
You can achieve this by adding the HTTP header "X-Desired-Filename" to the request.
That will result in the response having the header "Content-Disposition" with the value
"attachment; filename=\"DESIRED_FILE_NAME\".

### Time
There are two ways of specifying the `start` and `end` time for a query:

#### Absolute time

With absolute time, you specify a number that expresses the precise time in milliseconds since the Unix epoch (Unix time) in the UTC/Zulu time zone. This method is shown in the following example:

``` json
{
  "queryString": "",
  "start": 1473449370018,
  "end": 1473535816755
}
```

#### Relative time

With relative time, you specify the start and end time as a relative time such as `1minute` or `24 hours`. Humio supports this using _relative time modifiers_. Humio treats the start and end times as relative times if you specify them as strings.

When providing a timestamp, relative time modifiers are specified relative to "now".

See the relative time syntax [here](/relative-time-syntax.md)

!!! note
    Relative time modifiers are always relative to now.

This method is shown in the following examples:

Search the last 24 hours:
``` json
{
  "queryString": "ERROR",
  "start": "24hours",
  "end": "now"
}
```

You can also mix relative and absolute time modifiers. For example, to search from a specified moment in time until two days ago:
``` json
{
  "queryString": "loglevel=ERROR",
  "start": 1473449370018,
  "end": "2days"
}
```

!!! note
    **Omitted and required arguments**

    Humio has defined behavior when you omit time arguments:

    * If you omit the`end` argument, it gets the default value `now`.  
    * If you omit the `start` argument, it gets the default value of `24hours`.  

    For [*_live queries_*](glossary.md#live-queries), you must either set `end` to "now", or omit it. You must set `start` to a relative time modifier.




### Response

Humio returns data in different formats depending on the media type you set in the [`ACCEPT`](https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html)
header of the HTTP request.

Data can be returned in the following formats:

| Media type | Description |
------------|-------------|
| `text/plain` (default)   |   Returns events delimited by newlines. <br /><br />If the event has a `rawstring` field, then Humio prints it as the event. If it does not, then Humio prints all fields on the event in the format `a->hello, b->world`. <br /> Note that the event can contain newlines. Nothing is escaped.
| `application/json`   |   Returns events in a standard JSON array. <br /><br />All field values in each event are returned as JSON strings, except for `@timestamp`. The `@timestamp` field is returned a long integer, representing time as Unix time in milliseconds (UTC/Zulu time). <br> Newlines inside the JSON data are escaped as `\n`
| [`application/x-ndjson`](http://specs.frictionlessdata.io/ndjson/)   | Returns events as [Newline Delimited JSON (NDJSON)](http://specs.frictionlessdata.io/ndjson/). <br /><br />This format supports streaming JSON data. Data is returned with one event per line. <br /><br /> Newlines inside the JSON data are escaped as `\n`.


### Example

#### Live query streaming all events

This live query returns an empty search, finding all events in a time window going 10 seconds back in time.

Notice the `ACCEPT` header. This tells the server to stream data as [Newline Delimited JSON](http://specs.frictionlessdata.io/ndjson/).

```bash
curl https://demo.humio.com/api/v1/dataspaces/$DATASPACE/query \
  -X POST \
  -H "Authorization: Bearer $API_TOKEN" \
  -H 'Content-Type: application/json' \
  -H "Accept: application/x-ndjson" \
  -d '{"queryString":"","start":"10s","isLive":true}'
```


#### Aggregate query returning standard JSON

This query groups results by service and counts the number of events for each service. The query blocks until it is complete and returns events as a JSON array:

``` bash
curl https://demo.humio.com/api/v1/dataspaces/$DATASPACE/query \
  -X POST \
  -H "Authorization: Bearer $API_TOKEN" \
  -H 'Content-Type: application/json' \
  -H "Accept: application/json" \
  -d '{"queryString":"count()","start": "1h","end":"now","isLive":false}'
```


### Query Jobs

#### Create

The Query Jobs endpoint lets you run a query and check its status later.

To execute a query using the Query Jobs endpoint, you first have to
start it, and then subsequently poll its current status in a separate
request.

The Query Jobs endpoint is designed to support the web front end. This means that filter queries only return a maximum of 200 matching events
and aggregate queries up to a maximum of 1500 rows.  The API has
facilities to support user interfaces (see the [response](#response_2)
of the Query Jobs poll endpoint).

#### Request

To start a Query Job, POST the query to:

``` text
POST /api/v1/dataspaces/$DATASPACE/queryjobs
```

The request body is similar to the [request body](#request) in the query endpoint.


#### Response

Starting a query yields a response of the form:

```json
HTTP/1.1 200 OK
{ id: "some-long-id" }
```

The `id` field indicates the `$ID` for the query, which you can then poll
using the HTTP GET method (see [below](#poll)).

#### Example

``` bash
curl https://demo.humio.com/api/v1/dataspaces/$DATASPACE/queryjobs \
 -X POST \
 -H 'Authorization: Bearer $API_TOKEN' \
 -H 'Content-Type: application/json' \
 -H 'Accept: application/json' \
 -H 'Accept-Encoding: ' \
 -d '{"queryString":"","start": "1d","showQueryEventDistribution":true,"isLive":false}'
```


### Poll

This endpoint lets you poll running Query Jobs.

### Request

To poll a running Query Job, make an HTTP GET request to the job.

In the following example request, replace `$ID` with the ID from the response of the [Query Job create request](#create):

``` text
GET     /api/v1/dataspaces/$DATASPACE/queryjobs/$ID
```




#### Response

When Humio runs a search, it returns partial results. It returns the results that it found
at the time of the polling.  Humio searches the newest data
first, and then searches progressively backward in time.

This way, Humio produces some results right away. The `done: true` property in a poll query
shows if the query is finished.

The response is a JSON object with the following attributes:

Name                   |   Type        |  Description
-----------------------|---------------|--------------
`done`                   | boolean       | True if the query has run to completion.
`events`                 | Array[Event]  | The 200 most recent elements of the query response.
`metaData`               | QueryMetaData | Information about the query.
`queryEventDistribution` | EventDistData | Information used to render the distribution graph. Only present in the response if `showQueryEventDistribution` was set to true.

The `MetaData` field contains the number of matching events, the query
boundary, and information about the attributes and their unique value
domains in the response.


!!! warning
    **Query timeouts**

    If you do not poll a query for 30 seconds, then it stops and deletes itself.

    Live queries keep running for an hour without being polled.

#### Example

```bash
curl https://demo.humio.com/api/v1/dataspaces/$DATASPACE/queryjobs/$ID \
  -H "Authorization: Bearer $API_TOKEN"
```

### Delete

Stops running Query Jobs.

#### Request

To stop a Query Job, you can issue a `DELETE` request to the URL of the Query Job:

``` text
DELETE     /api/v1/dataspaces/$DATASPACE/queryjobs/$ID
```

#### Response

Standard HTTP response codes.

#### Example

```bash
curl https://demo.humio.com/api/v1/dataspaces/$DATASPACE/queryjobs/$ID \
 -X DELETE \
 -H "Authorization: Bearer $API_TOKEN"
```


### Ingest

There are different ways of getting data into Humio. This page show how to send data using the HTTP API.

There are 2 endpoints. [One for sending data that will be parsed using a specified parser.](#ingest-data-using-a-parser) And another [endpoint for sending data that is already structured and does not need parsing.](#ingest-structured-data)  
When parsing text logs like syslogs, accesslogs or logs from applications you typically use the endpoint where a parser is specified. 
 
 
### Ingest data using a parser

This API should be used, when a parser should be applied to the data. It is possible to create [parsers](/parsing.md) in Humio

!!! Note "Filebeat is another option for sending data that needs a parser"
    Another option, that is related to this API is to use [Filebeat](/integrations/log-shippers/filebeat.md).  
    Filebeat is a lightweight open source agent that can monitor files and ship data to Humio. When using filebeat it is also possible to specify a parser for the data.
    Filebeat can handle many problems like network problems, retrying, batching, spikes in data etc. 

``` text
POST	/api/v1/dataspaces/$DATASPACE/ingest-messages
```

Example sending 4 accesslog lines to Humio

``` json
[
  {
    "type": "accesslog",
    "fields": {
      "host": "webhost1" 
    },
    "messages": [
       "192.168.1.21 - user1 [02/Nov/2017:13:48:26 +0000] \"POST /humio/api/v1/dataspaces/humio/ingest HTTP/1.1\" 200 0 \"-\" \"useragent\" 0.015 664 0.015",
       "192.168.1.49 - user1 [02/Nov/2017:13:48:33 +0000] \"POST /humio/api/v1/dataspaces/developer/ingest HTTP/1.1\" 200 0 \"-\" \"useragent\" 0.014 657 0.014",
       "192.168.1..21 - user2 [02/Nov/2017:13:49:09 +0000] \"POST /humio/api/v1/dataspaces/humio HTTP/1.1\" 200 0 \"-\" \"useragent\" 0.013 565 0.013",
       "192.168.1.54 - user1 [02/Nov/2017:13:49:10 +0000] \"POST /humio/api/v1/dataspaces/humio/queryjobs HTTP/1.1\" 200 0 \"-\" \"useragent\" 0.015 650 0.015"
    ]
  }
]
```

The above example sends 4 accesslog lines to Humio. the parser is specified using the `type` field and is set to `accesslog`.   
The parser accesslog should be specified in the dataspace. See [parsing](/parsing.md) for details.  
The `fields` section is used to specify fields that should be added to each of the events when they are parsed. In the example all the accesslog events will get a host field telling the events came from webhost1.  
It is possible to send events of different types in the same request. That is done by adding a new element to the outer array in the example above.
Tags can be specified in the parser pointed to by the `type` field

#### Events

When sending events, you can set the following standard fields:

Name            | Required      | Description
------------    | ------------- |------------
`messages`      | yes           | The raw strings representing the events. Each string will be parsed by the parser specified by `type`.
`type`          | yes           | The [parser](/parsing.md) Humio will use to parse the `messages`
`fields`        | no            | Annotate each of the `messages` with these key-values. Values must be strings.
`tags`          | no            | Annotate each of the `messages` with these key-values as Tags. Please see other documentation on tags before using.

#### Examples

Previous example as a curl command:

``` bash
curl -v -X POST localhost:8080/api/v1/dataspaces/developer/ingest-messages/ \
-H "Content-Type: application/json" \
-d @- << EOF
[
  {
    "type": "accesslog",
    "fields": {
      "host": "webhost1" 
    },
    "messages": [
       "192.168.1.21 - user1 [02/Nov/2017:13:48:26 +0000] \"POST /humio/api/v1/dataspaces/humio/ingest HTTP/1.1\" 200 0 \"-\" \"useragent\" 0.015 664 0.015",
       "192.168.1.49 - user1 [02/Nov/2017:13:48:33 +0000] \"POST /humio/api/v1/dataspaces/developer/ingest HTTP/1.1\" 200 0 \"-\" \"useragent\" 0.014 657 0.014",
       "192.168.1.21 - user2 [02/Nov/2017:13:49:09 +0000] \"POST /humio/api/v1/dataspaces/humio HTTP/1.1\" 200 0 \"-\" \"useragent\" 0.013 565 0.013",
       "192.168.1.54 - user1 [02/Nov/2017:13:49:10 +0000] \"POST /humio/api/v1/dataspaces/humio/queryjobs HTTP/1.1\" 200 0 \"-\" \"useragent\" 0.015 650 0.015"
    ]
  }
]
EOF
```

Shorter example using the built-in kv parser 

``` bash
curl -v -X POST localhost:8080/api/v1/dataspaces/developer/ingest-messages/ \
-H "Content-Type: application/json" \
-d @- << EOF
[
  {
    "type": "kv",
    "messages": [
       "2018-01-01T12:00:00+02:00 a=1 b=2"
    ]
  }
]
EOF
```

### Ingest structured data
This API should be used when data is well structured and no extra parsing is needed. (Except for the optional extra key-value parsing)

``` text
POST	/api/v1/dataspaces/$DATASPACE/ingest
```

The following example request contains two events. Both these events share the same tags:

``` json
[
  {
    "tags": {
      "host": "server1",
      "source": "application.log"
    },
    "events": [
      {
        "timestamp": "2016-06-06T12:00:00+02:00",
        "attributes": {
          "key1": "value1",
          "key2": "value2"
        }
      },
      {
        "timestamp": "2016-06-06T12:00:01+02:00",
        "attributes": {
          "key1": "value1"
        }
      }
    ]
  }
]
```


You can also batch events with different tags into the same request, as shown in the following example.

This request contains three events. The first two are tagged with `server1` and the third is tagged with `server2`:

``` json
[
  {
    "tags": {
      "host": "server1",
      "source": "application.log"
    },
    "events": [
      {
        "timestamp": "2016-06-06T13:00:00+02:00",
        "attributes": {
          "hello": "world"
        }
      },
      {
        "timestamp": "2016-06-06T13:00:01+02:00",
        "attributes": {
          "statuscode": "200",
          "url": "/index.html"
        }
      }
    ]
  },
  {
    "tags": {
      "host": "server2",
      "source": "application.log"
    },
    "events": [
      {
        "timestamp": "2016-06-06T13:00:02+02:00",
        "attributes": {
          "key1": "value1"
        }
      }
    ]
  }
]
```


#### Tags
Tags are key-value pairs.


Events are stored in data sources. A Data Space has a set of Data Sources. Data sources are defined by their tags. An event is stored in a data source matching its tags. If no data source with the exact tags exists it is created.
Tags are used as query boundaries when searching
Tags are provided as a json object containing key-value pairs. Keys and values must be strings, and at least one tag must be specified.
See the [Glossary](glossary/#tags) for more information.

#### Events

When sending an Event, you can set the following standard fields:

Name            | Required      | Description
------------    | ------------- |-----
`timestamp`     | yes           | You can specify the `timestamp` in two formats. <br /> <br /> You can specify a number that sets the time in millisseconds (Unix time). The number must be in Zulu time, not local time. <br /><br />Alternatively, you can set the timestamp as an ISO 8601 formatted string, for example, `yyyy-MM-dd'T'HH:mm:ss.SSSZ`.
`timezone`      | no            | The `timezone` is only required if you specify the `timestamp` in milliseconds. The timezone specifies the local timezone for the event. Note that you must still specify the `timestamp` in Zulu time.
`attributes`    | no            | A JSON object representing key-value pairs for the Event. <br /><br />These key-value pairs adds structure to Events, making it easier to search structured data. Attributes can be nested JSON objects, however, we recommend limiting the amount of nesting.
`rawstring`     | no            | The raw string representing the Event. The default display for an Event in Humio is the `rawstring`. If you do not provide the `rawstring` field, then the response defaults to a JSON representation of the `attributes` field.
`kvparse`       | no            | If you set this field to true, then Humio parses the `rawstring` field looking for key-value pairs of the form `a=b` or `a="hello world"`.

#### Event examples

``` json
{
    "timestamp": "2016-06-06T12:00:00+02:00",
    "attributes": {
        "key1": "value1",
        "key2": "value2"
    }
}
```

``` json
{
    "timestamp": 1466105321,
    "attributes": {
        "service": "coordinator"
    },
    "rawstring": "starting service coordinator"
}
```

``` json
{
    "timestamp": 1466105321,
    "timezone": "Europe/Copenhagen",
    "attributes": {
        "service": "coordinator"
    },
    "rawstring": "starting service coordinator"
}
```

``` json
{
    "timestamp": "2016-06-06T12:00:01+02:00",
    "rawstring": "starting service=coordinator transactionid=42",
    "kvparse" : true
}
```

#### Response

Standard HTTP response codes.

#### Example

``` bash
curl https://demo.humio.com/api/v1/dataspaces/$DATASPACE/ingest \
 -X POST \
 -H "Content-Type: application/json" \
 -H "Authorization: Bearer $API_TOKEN" \
 -d '[{"tags": {"host":"myserver"}, "events" : [{"timestamp": "2016-06-06T12:00:00+02:00", "attributes": {"key1":"value1"}}]}]'
```


### Files

You can use this endpoint to upload files that can be used by the
[lookup](query-language/query-functions.md#lookup) function.

You can upload files in CSV or JSON format.

!!! note
    Upload files as multipart form data.

    The file should be in a part named `file`.


#### Example using curl

Replace `myfile.csv` with the path to your file.

``` bash
curl https://demo.humio.com/api/v1/dataspaces/$DATASPACE/files \
 -H "Authorization: Bearer $API_TOKEN" \
 -F "file=@myfile.csv"
```

#### Example contents for a file in CSV format.
Whitespace gets included in the keys and values. To include the separator `","` in a value, quote using the `"` character.
```
userid,name
1,chr
2,krab
"4","p,m"
7,mgr
```

#### Example contents for a file en JSON format using an object as root of the file.
In this variant, the key field does not have a name.
```
{
 "1": { "name": "chr" },
 "2": { "name": "krab" },
 "4": { "name": "pmm" },
 "7": { "name": "mgr" }
}
```

#### Example contents for a file en JSON format using an array as root of the file.
In this variant, you select which field is the "key" using the "on" parameter in "lookup".
```
[
 { "userid": "1", "name": "chr" },
 { "userid": "2", "name": "krab" },
 { "userid": "4", "name": "pmm" },
 { "userid": "7", "name": "mgr" }
]
```

### Parsers

Data sent to Humio usually has some structure. You can use parsers to
extract this structure.

For example, a standard web server log has the status code, method, and URL
fields for each log line.

When sending data to Humio, for example using
[Filebeat](/integrations/log-shippers/filebeat.md), you must specify a parser telling
Humio how to parse the incoming data.

Humio has some built-in parsers for common formats like access logs from Apache and Nginx
web servers. It also allows for custom parsers.

#### List Parsers

##### Request

To list all parsers for a given Data Space:

``` text
GET     /api/v1/dataspaces/$DATASPACE/parsers
```

##### Response

```
[
  {
    "builtIn": true,
    "parseKeyValues": false,
    "parser": "(?<client>\\S+)\\s+-\\s+(?<userid>\\S+)\\s+\\[(?<@timestamp>.*)\\]\\s+\"((?<method>\\S+)\\s+(?<url>\\S+)?\\s+(?<httpversion>\\S+)?|-)\"\\s+(?<statuscode>\\d+)\\s+(?<responsesize>\\S+)\\s+\"(?<referrer>.*)\"\\s+\"(?<useragent>.*)\"\\s*(?<responsetime>.+)?",
    "id": "accesslog",
    "dateTimeFields": [
      "@timestamp"
    ],
    "kind": "regex",
    "dateTimeFormat": "dd/MMM/yyyy:HH:mm:ss Z"
  },
  {
    "id": "json",
    "kind": "json",
    "parseKeyValues": false,
    "dateTimeFields": [
      "@timestamp"
    ]
  }
]
```
The output format is similar to the input format in [Add Parser](#add-parser).

##### Example

``` bash
curl https://demo.humio.com/api/v1/dataspaces/$DATASPACE/parsers \
 -H "Authorization: Bearer $API_TOKEN"
```


#### Create or Update Parser

##### Request

To create a parser for a given data space:

``` text
POST     /api/v1/dataspaces/$DATASPACE/parsers/$PARSER_ID
```
or to updated an existing parser use
``` text
PUT     /api/v1/dataspaces/$DATASPACE/parsers/$PARSER_ID
```



The JSON request body has the following attributes:

Name           | Type   | Required     | Description
-------------- | ------ | ------------ | -------------
`kind`           | String | Yes          | Controls which parser kind to create. You can set this to `regex`, or `json`. 
`parser`         | String | Yes          | The parser specification.<br /><br />The contents of this field vary depending on the type of parser you are creating. See the details [below](#humio-parsers)
`parseKeyValues` | Boolean|  No          | Sets whether you want the parser to parse 'key=value' pairs in the log line. <br /><br />The default value is `false`.
`dateTimeFields` | Array  | Yes          | Specifies the fields which contain the timestamp of the event. <br /><br />You can specify multiple fields, for example, a date field and a time field. The values of these fields are concatenated with whitespaces. <br /> <br /> Humio parses these fields  with the format that you specify in the `dateTimeFormat` attribute.
`dateTimeFormat` | String |  No          | The format string that Humio should use to parse the fields identified by the `dateTimeFields` attribute. <br /><br />This attribute uses the [Java DateTimeFormatter syntax](https://docs.oracle.com/javase/8/docs/api/java/time/format/DateTimeFormatter.html). <br /><br />The default value is the ISO-8601 format, for example, `yyyy-MM-dd'T'HH:mm:ss.SSSZ`, with milliseconds as an optional addition.
`timezone`       | String |  No          | This field is only used if the timestamp of the event is in localtime and does not have a timezone. <br /> <br />In that case, you can use it to set a timezone. <br /><br />Do not use this field if the timezone is part of the `dateTimeFormat`.<br /><br /> Examples: `UTC`, `Z`, or `Europe/Copenhagen`.
`tagFields`      |Array   | No           | Specify fields in events generated by this parser that should be turned into [tags](/glossary.md#tags).<br/> For example it could be specified that the host field in the events from this parser should be treated as a tag.


##### Response

Standard HTTP response codes.

##### Example

``` bash
curl https://demo.humio.com/api/v1/dataspaces/$DATASPACE/parsers/$PARSER_NAME \
 -XPUT \
 -H "Authorization: Bearer $API_TOKEN" \
 -H "Content-Type: application/json" \
 -d '{"parser": "^(?<date>\\S*) (?<time>\\S*) (?<host>\\S*) (?<appname>\\S*):",
      "kind": "regex",
      "parseKeyValues": true,
      "dateTimeFormat": "yyyy-MM-dd HH:mm:ss.SSS",
      "dateTimeFields": ["date", "time"],
      "timezone": "UTC",
      "tagFields": ["host"]
     }'
```

##### Parser types

Humio currently supports two types of parsers. Regular expression parsers and JSON parsers:


##### JSON parser

When using the "json" parser type, Humio expects data to be in the
JSON format.

The only required field is `dateTimeFields`. This designates which
field has the timestamp.

**Example**

``` bash
curl https://demo.humio.com/api/v1/dataspaces/$DATASPACE/parsers/$PARSER_NAME \
 -XPUT \
 -H "Authorization: Bearer $API_TOKEN" \
 -H "Content-Type: application/json" \
 -d '{"kind": "json",
      "dateTimeFields": ["@timestamp"]
     }
```

#### Regular expression parser

The "regex" parser type allows you to specify parsers using regular
[expressions](https://github.com/google/re2/wiki/Syntax),
where named capture groups specify fields.

**Example**

This example shows how to parse Nginx access logs with regular expressions.  Note the use of `\\` to escape backslashes:

```
(?<client>\\S+)\\s+-\\s+(?<userid>\\S+)\\s+\\[(?<@timestamp>.*)\\]\\s+\"((?<method>\\S+)\\s+(?<url>\\S+)?\\s+(?<httpversion>\\S+)?|-)\"\\s+(?<statuscode>\\d+)\\s+(?<responsesize>\\S+)\\s+\"(?<referrer>.*)\"\\s+\"(?<useragent>.*)\"\\s*(?<responsetime>.+)?
```


#### Delete Parser

##### Request

To delete a parser from a given Data Space, make the following request:

``` text
DELETE     /api/v1/dataspaces/$DATASPACE/parsers/$PARSER_NAME
```

##### Response

Standard HTTP response codes.

##### Example

``` bash
curl https://demo.humio.com/api/v1/dataspaces/$DATASPACE/parsers/$PARSER_NAME \
 -XDELETE \
 -H "Authorization: Bearer $API_TOKEN"
```
