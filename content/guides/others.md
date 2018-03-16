---
title: "Others"
---

So you are developing your own application and want to ship its logs
to Humio?  The easiest is to just log to a file on disk (remember to
set a limit on its size and rotate it so you don't run out of disk
space) and then use [Filebeat](/sending_logs_to_humio/log-shippers/beats/) to ship it
to Humio.

{{% notice note %}}
If you are using Docker for your own application, go to the [Docker Containers documentation](/sending_logs_to_humio/integrations/docker/)
{{% /notice %}}


## Filebeat Configuration

Filebeat ship logs as unstructured text. To parse these logs, you need
to set a log type using the `@type` field.  Humio will use the parser specified by `@type` to parse the data.  
See [Parsing Logs](/parsing.md) for more information on parsing log data.

Example Filebeat configuration with a custom log type:

```yaml
filebeat.prospectors:
- paths:
    - <path-to-your-application-log>
  fields:
    "@type": <name-of-your-application-log-parser>

output.elasticsearch:
  hosts: ["https://<humio-host>:443/api/v1/dataspaces/<dataspace>/ingest/elasticsearch"]
  username: <ingest-token>
```

See the detailed [documentation for Filebeat](/sending_logs_to_humio/log_shippers/filebeat/)
