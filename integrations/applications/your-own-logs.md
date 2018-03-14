
So you are developing your own application and want to ship its logs
to Humio?

The easiest way to ship your application logs is to have your application
write logs to a file on disk, and then use
[Filebeat](../log-shippers/beats.md) to ship them to Humio.

!!! tip
    Remember to set a limit on the size of the log file, and rotate it so that
    you don't run out of disk space.


!!! Docker

    If you are using Docker for your application, see the [Docker
    Containers documentation](../platforms/docker.md)


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

See the detailed documentation for filebeat [here](/integrations/log-shippers/filebeat.md)
