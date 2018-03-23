---
title: "Intro to Log Management"
weight: 1
---

Modern IT systems create a lot of operational data and it can be difficult to
manage. Often, this data is stored in 'logs'.

The term 'log management' relates to producing, shipping, normalizing, and
querying this data. It's a complex activity, with many moving
parts. A specialized log management tool like
[Humio](http://www.humio.com) can save you a lot of time and money.

Unfortunately, there are no standards across applications for
logging data. We recommend focusing on your key systems first, then
expanding and developing your log management setup as needed.

## Log Sources

Log data is the lowest common denominator for getting both real-time and historical insights into running systems.

Most systems and applications just append log data to log files on disk.
However, some systems also support sending logs directly to a log management
system like [Humio](http://www.humio.com).


## Shipping

In most situations, it's necessary to add a 'log shipping' layer to your system.  A 'log shipper' is an application that can take logs from a file on disk and send them directly to a log management system.


{{% notice note %}}
We are really fond of the Elastic
[Beats](https://www.elastic.co/products/beats). These are small,
lightweight programs that can ship a large (and growing) number of
different logs and metric types.

In general, Humio is compatible with the Elastic ingest APIs. So if your
favorite log shipper can send it to Elastic, there is a good chance it can ship to Humio as well. If you have questions or aren't sure, we are always here to support you.
{{% /notice %}}

An important aspect shipping is how faults are handled. When evaluating a log shipper, examine what situations will cause the loss of log lines, or duplications. Also check which kinds of failures it can tolerate.

## Parsing

Because most log formats are unique, at some point you'll need to parse
your logs.  Parsing let's you take logs that are essentially just lines of text, and extract their structure in order to incorporate a more in depth analysis.

For example, you can extract useful items of data such as a timestamp or
key-value pairs.

Humio can parse logs for you. If you are familiar with [Fluentd](http://www.fluentd.org/) or
[LogStash](https://www.elastic.co/products/logstash), they can also parse logs.

{{% notice note %}}
Humio integrates well with both of these shipping frameworks. Neat!
{{% /notice %}}


## Querying logs

Querying is where you will feel the real benefit of deploying a log management
tool like Humio. The system creates value by letting you ask a variety of questions about the data in ways it might not be possible to with a raw data log.

The list below shows just some of the use cases where a log management system
like Humio could be invaluable:

- Investigating incidents and anomalies
- Following operations in real-time - is the deployment causing errors?
- Discovering internal and external communication patterns
- Seeing how events in one part of the system affect other parts
- "Feeling the Hum of your System" - All systems have a rhythm.  What is yours?
- Seeing real-time status - are your systems up?
- Finding the answers to ad-hoc questions
- Making the system visible - put dashboards on big screens so everybody can "feel the hum"
