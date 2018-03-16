---
title: "New to log management"
date: 2018-03-15T08:09:40+01:00
weight: 1
---

## Introduction

Modern IT systems create a lot of operational data that can be difficult to
manage. Often, this data is stored in 'logs'.

The term 'log management' relates to how you can produce, ship, normalize, and
query this data. Log management is a complex activity, with many moving
parts. A specialized log management tool like
[Humio](http://www.humio.com) will save you a lot of time and money.

Unfortunately, there are no standards across applications for
logging data. We recommend that you focus on your key systems first, and
expand and develop your log management setup as needed.

## Log Sources

All IT systems produce some kind of log data. It is the lowest common denominator for
getting both real-time and historical insights into running systems.

Most systems and applications just append log data to log files on disk.
However, some systems also support sending logs directly to a log management
system like [Humio](http://www.humio.com).


## Shipping

In most situations, you must add a 'log shipping' layer to your system.  A
'log shipper' an application that can take logs from a file on disk and
send them directly to a log management system like [Humio](http://www.humio.com).


!!! note
    We are really fond of the Elastic
    [Beats](https://www.elastic.co/products/beats).  These are small,
    lightweight programs that can ship a large (and growing) number of
    types of logs and metrics.

    In general, Humio is compatible with the Elastic ingest APIs. So if your
    favorite log shipper can send it to Elastic, then there is a good chance
    that it can send to Humio as well. If not, let us know and we'll look into it.

An important aspect of the shipping layer is how it handles faults. When
evaluating a log shipper, you should check out in what situations it will lose
log lines, or duplicate them. You should also check which kinds of failures it
can tolerate.

## Parsing

Because most log formats are unique, at some point you'll have to parse
some of your logs.  Parsing lets you take logs that are
essentially just lines of text, and extract their structure.

For example, you could extract useful items of data such as a timestamp or
key-value pairs.

Humio can parse logs for you. Some log shipping frameworks, like
[Fluentd](http://www.fluentd.org/) or
[LogStash](https://www.elastic.co/products/logstash), can also parse logs.

!!! note
    Humio integrates well with both of these shipping frameworks. Neat!


## Querying logs

Querying is where you will feel the real benefit of deploying a log management
tool. The system creates value by letting you ask a variety of questions about
your data that you could not otherwise ask.

The list below shows just some of the use cases where a log management system
like Humio could be invaluable:

- Investigating incidents and anomalies
- Following operations in real-time - is the deployment causing errors?
- Discovering internal and external communication patterns
- Seeing how events in one part of your system affect other parts
- "Feeling the Hum of your System" - All systems have a rhythm.  What is yours?
- Seeing real-time status - are your systems up?
- Finding the answers to ad-hoc questions
- Making the system visible - put dashboards on big screens so everybody can "feel the hum"
