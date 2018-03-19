
Welcome to Humio!

Humio is a log management system, so you need to put some logs
into it in order to make use of it.

If you want to get a little more context around what log management is, please read the [brief overview of log management](log-management-overview.md).

## Get logs into Humio

First, decide which log data sources you want to put into Humio.

Second, find or create an [ingest token](/sending_logs_to_humio/ingest_tokens/).

Third, go through the [Integrations](index.md#integrations) and see if you
can find the integretion you need. For example, if what you want is:

* **Logs from a Docker container**, then:
    1. Start [here](integrations/platforms/docker.md), then
    2. Get information about [how Humio parses logs](/sending_logs_to_humio/parsers/parsing/).

* **Logs that an application writes to a file**, then:
    1. Read an overview of the [Filebeat](integrations/log-shippers/beats.md) log shipper, then
    2. Get information about parsing [here](/sending_logs_to_humio/parsers/parsing/)

* **Metrics from platforms or applications**, then:
    1. Read the [Metricbeat](integrations/log-shippers/beats.md) topic, then
    2. Get information about parsing [here](/sending_logs_to_humio/parsers/parsing/)


## Start using Humio

The best way to start is to head
over to our [online tutorial](/getting_started/tutorial/).

Afterwards, you can learn about the [query language](/searching_logs/query_language/) and its
[functions](/searching_logs/query_language/query_functions/).


**Have fun!**
