
Welcome to Humio!

Humio is a log management system, so you need to put some logs
into it in order to make use of it.

If you want to get a little more context around what log management is, please read the [brief overview of log management](log-management-overview.md).

## Get logs into Humio

First, decide which log data sources you want to put into Humio.

Second, find or create an [ingest token](/ingest-tokens.md).

Third, go through the [Integrations](index.md#integrations) and see if you
can find the integretion you need. For example, if what you want is:

* **Logs from a Docker container**, then:
    1. Start [here](integrations/platforms/docker.md), then
    2. Get information about [how Humio parses logs](parsing.md).

* **Logs that an application writes to a file**, then:
    1. Read an overview of the [Filebeat](integrations/log-shippers/beats.md) log shipper, then
    2. Get information about parsing [here](parsing.md)

* **Metrics from platforms or applications**, then:
    1. Read the [Metricbeat](integrations/log-shippers/beats.md) topic, then
    2. Get information about parsing [here](parsing.md)


## Start using Humio

The best way to start is to head
over to our [online tutorial](tutorial.md).

Afterwards, you can learn about the [query language](query-language.md) and its
[functions](query-language/query-functions.md).


**Have fun!**
