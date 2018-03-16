---
title: "Netflow"
---

Humio has built in support for [Netflow](https://en.wikipedia.org/wiki/NetFlow).

{{% notice warning %}}
This feature is in beta!
{{% /notice %}}

It is possible to send NetFlow data directly to Humio over UDP using ingest listeners. 
Ingest listeners are configured under settings in a data space.  
Setting up an ingest listener will let Humio listen for NetFlow traffic on a specified port. 
Then you need to configure the network equipment (firewall, switch, ...) to send NetFlow data directly to Humio.

{{% notice note %}}
***Waiting for the templates***

After enabling NetFlow, some time can pass before the first data is ingested. As part of the Netflow protocol, a template for the data is sent at regular intervals.
Humio must wait for these templates to arrive before data can be parsed.
The time between emitting schemas can typically be configured in the components emitting NetFlow data. 
{{% /notice %}}

Humio supports NetFlow version 9.  For other versions, we suggest looking at using Logstash's netflow codec adapter.

Ingest listeners are only available in on-premises Humio due to security concerns.


