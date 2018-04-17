---
title: "Moving from Elastic Stack"
weight: 2
---

If you are an existing user of the Elastic Stack, be it either Filebeat or Logstash, together with Elastic Search this is the page for you.

Humio offers a drop-in replacement for the Elastic Search bulk API, meaning that switching your existing Filebeat or Logstash configurations over to Humio are very easy.

## Creating a new Humio Data Space

First of all you will need to create a data space in Humio. For an explanation of what a data space is, please take a look at the [Glossary page's section on Data Spaces](/glossary/#data-spaces).

The quickest way to get started using Humio is creating a dataspace in our [hosted environment](https://cloud.humio.com), where you will get a personal [Sandbox](https://cloud.humio.com/sandbox) for free.

Alternatively you can choose to run our [Docker image](/operation/installation/) on your own infrastucture.

## Beats

You probably know the whole Beats platform already, and would have a configuration that contains something like this

```yaml
output.elasticsearch:
  hosts: ["elasticsearch:9200"]
```

To make all beats point to Humio, just change the `output.elasticsearch` section with

```yaml
output.elasticsearch:
  hosts: ["https://<humio-host>:443/api/v1/dataspaces/<data-space>/ingest/elasticsearch"]
  username: <ingest-token>
```

Where `<humio-host>` should be replaced with the hostname of your Humio cluster. For our hosted solution, what would be `cloud.humio.com`.

{{% notice note %}}
Port has to set to `443`, since Beats is defaulting to port `9200`.
{{% /notice %}}

`<data-space>` is the data space that was created before, or just `sandbox` if you want to use your personal free data space.

Finally, `<ingest-token>` should be replace with an allocated ingest-token from the dataspace. If you have an empty dataspace a dialog will be shown which has direct access to the ingest token

![Data space welcome dialog](/images/dataspacewelcomewithingesttoken.png)

For more information about the Beats log shippers, please take a look at [Beats section](/sending_logs_to_humio/log_shippers/beats/).