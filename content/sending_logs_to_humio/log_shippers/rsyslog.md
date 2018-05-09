---
title: "Rsyslog"
draft: true
---

The [Rsyslog](https://www.rsyslog.com) log processor is very popular and is being shipped with a some very popular Linux distributions, including Ubuntu and Centos.
Rsyslog provides [a long list of plugins](https://www.rsyslog.com/plugins/), most importantly the [Elastic search output plugin](https://www.rsyslog.com/doc/v8-stable/configuration/modules/omelasticsearch.html), which is supported by Humio.

## Minimal configuration
We recommend the following minimal configuration for forwarding all logs to Humio

Create a file named `/etc/rsyslog.d/33-humio.conf` with the following contents

```
module(load="omelasticsearch")
template(name="humiotemplate"
         type="list"
         option.json="on") {
           constant(value="{")
             constant(value="\"@timestamp\":\"")      property(name="timereported" dateFormat="rfc3339")
             constant(value="\",\"message\":\"")     property(name="msg")
             constant(value="\",\"host\":\"")        property(name="hostname")
             constant(value="\",\"severity\":\"")    property(name="syslogseverity-text")
             constant(value="\",\"facility\":\"")    property(name="syslogfacility-text")
             constant(value="\",\"syslogtag\":\"")   property(name="syslogtag")
           constant(value="\"}")
         }
*.* action(type="omelasticsearch"
           server="<Humio server>"
           template="humiotemplate"
           uid="<ingest token>"
           pwd="none"
           bulkmode="on"
           usehttps="on")
```

Remember to replace `<Humio server>` with your Humio host, i.e. `cloud.humio.com` and `<ingest token>` with the ingest token for your dataspace.

Furthermore `bulkmode` and `usehttps` _has_ to be set to `on`.
