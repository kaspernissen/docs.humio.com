---
title: "Welcome to the Humio documentation"
date: 2018-03-15T07:27:14+01:00
---


<img style="float: left;margin-right: 1em;" src="./images/humio-owl.svg">

This site explains how to understand and use [Humio](http://www.humio.com).

Navigate the site to the left and find *table of contents* for pages on the right.  Enjoy!

<!--

## Explain Humio to me in 15 seconds!

**Humio is a tool that helps you aggregate, explore, report on, and analyze your server and application log data in *real time*. Using Humio, you can quickly harvest your log data for answers to business questions.**
-->
<!-- **You should [try it now!](tutorial.md)** -->
## Quick Links

  - [First Time User?](first-time-use.md)
  - [Learn the Query Language](tutorial.md)
  - [Query Functions](query-language/query-functions.md)
  - [HTTP API](http-api.md)
  - [Release notes](release-notes.md)

{{% notice tip %}}
**Already using Logstash?**
Great - you can get your data into Humio really quickly!
See our instructions on pointing your [Elastic outputter](/integrations/log-shippers/logstash.md) to Humio.
{{% /notice%}}

## Integrations

<div class="integrations">
  <ul>
    <li><a href="integrations/log-shippers/beats/index.html">Beats</a></li>
    <li><a href="integrations/platforms/bro/index.html">Bro</a></li>
    <li><a href="integrations/platforms/docker/index.html">Docker</a></li>
    <li><a href="integrations/log-shippers/filebeat/index.html">Filebeat</a></li>
    <li><a href="integrations/log-shippers/beats/index.html">Heartbeat</a></li>
    <li><a href="integrations/platforms/heroku/index.html">Heroku</a></li>
    <li><a href="http-api/index.html">HTTP API</a></li>
    <li><a href="integrations/platforms/mesos/index.html">Mesos and DC/OS</a></li>
    <li><a href="integrations/log-shippers/metricbeat/index.html">Host metrics</a></li>
    <li><a href="integrations/platforms/kubernetes/index.html">Kubernetes</a></li>
    <li><a href="integrations/platforms/linux/index.html">Linux</a></li>
    <li><a href="integrations/log-shippers/logstash/index.html">LogStash</a></li>
    <li><a href="integrations/log-shippers/metricbeat/index.html">Metricbeat</a></li>
    <li><a href="integrations/applications/nginx/index.html">Nginx</a></li>
    <li><a href="integrations/platforms/netflow/index.html">Netflow</a></li>
    <li><a href="integrations/log-shippers/beats/index.html">Packetbeat</a></li>
    <li><a href="integrations/applications/your-own-logs/index.html">Your own logs...</a></li>
    <li><a href="integrations/log-shippers/beats/index.html">Winlogbeat</a></li>
  </ul>
</div>

<!--

## Why would I use Humio?

In most organizations, log data is growing exponentially in its volume and complexity. Understanding this data can provide immediate value to your business, including meeting key performance goals and diagnosing problems.

Humio provides a unified <!-- , scalable, -- > and flexible solution that your organization can use to meet this challenge. It is an easy-to-use tool that lets you aggregate, explore, report on, and analyze machine data and system logs in real time.


## Okay, tell me more!

Humio is designed for server logs from large software installations, but you can use it to analyze any type of log data. Some [example use cases](use-cases.md) help to illustrate its flexibility.


Humio can receive data from existing log processing tools such as Logstash, Fluentd, and Filebeat (see integrations -> logshippers). You can also use Humios [HTTP API](http-api) to send data directly.

Humio has [built-in parsers](parsers.md) that can extract relevant fields from popular event formats such as Apache log files and NetFlow records. When Humio receives JSON data, you do not need to perform any special parsing.

The following sections will give you an understanding of how you can use Humio.


## Use Cases

Humio is designed for server logs from large software installations, but you can use it to analyze any type of log data. Some use cases help to illustrate its flexibility.

<h3>Supporting Continuous Delivery and DevOps</h3>

More and more organizations are adopting Continuous Delivery (CD) workflows to deliver value to customers quicker. With Continuous Delivery, you must monitor the frequent deployments of application code to your infrastructure for potential issues before they impact customers.

Humio provides a useful way to monitor application deployment and performance during release, and to detect, investigate, and resolve issues that occur afterwards. Its real-time querying capability is well suited to monitoring frequent deployments.

Its ability to aggregate and query all logs in a single application makes debugging complex distributed architectures a breeze.

<h3>Monitoring applications and infrastructure</h3>

Whether you are running a small internal application or a distributed cloud service, Humio provides an effective way to monitor your systems or applications in real time.

You can configure Humio to watch for error rates, transaction or user volumes, registration counts, or any other metric that makes sense for your business.

Even better, you do not have to identify your search and monitoring parameters up-front. The real-time nature of Humio means that you can adjust metrics with no delays or downtime for re-indexing.


<h3>Providing accurate business intelligence</h3>

Humio lets you create simple dashboard views that provide real-time summaries of business data. These let non-technical users get access to the insights generated by Humio without having to learn anything about querying.

For example, you could display Key Performance Indicators (KPIs) such as sales, user activity, or any other query-based metric on a dashboard. Humio updates the dashboard in real-time, and you can optionally filter it to a specific time period.

-->
