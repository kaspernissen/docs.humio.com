---
title: "Bro"
---

Humio is an excellent tool for analysing [Bro](https://www.bro.org/) data.  
This document describes how to get Bro data into Humio

## Configure Bro
First let us setup Bro to write logs in the JSON format. That will make it easier to send them to Humio.
 
[Seth](https://twitter.com/remor) from [Corelight](https://www.corelight.com/) has made a nice Bro script to support streaming Bro logs as JSON.
The script requires Bro 2.5.2+

[Download it here](bro-files/corelight-logs.bro)

One way to install the script is to put it in the `<bro-directory>/site/` folder and then add the Bro script to the end of `local.bro` like this:
```
@load corelight-logs.bro
```

The script will add new JSON log files in the Bro log directory next to the standard CSV log files. 
The new JSON files will be prepended with `corelight_` and otherwise have the same name as its corresponding CSV file. 
So there will be a `corelight_conn.log` log file corresponding to the `conn.log` CSV log file etc.  

By default each JSON log file is rotated every 15 minutes, and 4 versions of the file is kept. 
These files will be monitored by Filebeat and data send to Humio as is described below in the section [Configure Filebeat](#configure-filebeat)

Some available configurations options for the Bro script are:

```
redef CorelightLogs::disable_default_logs = F;      ## Disable default logs and only log in JSON
redef CorelightLogs::extra_files = 4;               ## number of files to keep when rotating
redef CorelightLogs::rotation_interval = 15mins;    ## time before rotating a file
```

These options can be appended to `local.bro`


It is also possible to test the script by running:  
```
bro -i eth0 <bro-directory-full-path>/site/json-logs-by-corelight.bro
```

{{% notice note %}}
On Mac the default network interface is `en0`
{{% /notice %}}

You can follow the above or add the Bro script in a way matching your installation.
With the script in place, and after a restart, Bro should be logging in JSON format, formatted as JSON objects separated by newlines.
Verify this by looking in one of the log files, for example `corelight_conn.log`.

## Configure Humio

We assume you already have a local Humio running or is using Humio as a Service. 
Head over to the [installation docs](/installation/installation.md) for instructions on how to install Humio.

If you don't have a dataspace, create one by pressing 'Add Dataspace' on the front page of Humio. 
Or you can create it from the command line like this:

```
curl -v 'http://localhost:8080/humio/api/v1/dataspaces/bro' -X PUT -H 'Content-Type: application/json' -H 'Accept: application/json' --data-binary '{}'
```

{{% notice note %}}
If you are running with authentication or using Humio as a service you need to add your API token
`-H "Authorization: Bearer $TOKEN"`
{{% /notice %}}    
You now have a bro dataspace.


## Configure Filebeat
We will use [Filebeat](/integrations/log-shippers/filebeat.md) to ship Bro logs to Humio.
Filebeat is a light weight, open source agent that can monitor log files and send data to servers like Humio.
Filebeat must be installed on the server having the Bro logs.
Follow the instructions [here](/integrations/log-shippers/filebeat.md#installation) to download and install Filebeat. 
Then return here to configure Filebeat.

Below is a filebeat.yml configuration file for sending Bro logs to Humio:

```
filebeat.prospectors:
- type: log
  paths:
    - "${BRO_LOG_DIR}/corelight_*.log" #The file path should be a glob matching the json log files
  fields:
    type: bro-json

#-------------------------- Elasticsearch output ------------------------------
output.elasticsearch:
  hosts: ["http://${HUMIO_HOST}:8080/api/v1/dataspaces/${DATASPACE}/ingest/elasticsearch"]
  username: "${INGEST_TOKEN}"
  compression_level: 5
  bulk_max_size: 200

#================================ Logging =====================================
# Sets log level. The default log level is info.
# Available log levels are: critical, error, warning, info, debug
logging.level: debug
  
logging.selectors: ["*"]

``` 

The configuration file has these parameters:
  
* `BRO_LOG_DIR`  
* `HUMIO_HOST`  
* `DATASPACE`
* `INGEST_TOKEN`  

You can replace them in the file or set them as ENV parameters when starting Filebeat.  
If you are running without authentication leave out the whole line `username: ${INGEST_TOKEN}`. 
or set the `INGEST_TOKEN` to a dummy value. 
Otherwise [create an ingest token as described here](/ingest-tokens.md).


Note, that in the filebeat configuration we specify that Humio should use the built-in parser `bro-json` to parse the data.


### Run Filebeat

With the config in place we are ready to run Filebeat. 

{{% notice note %}}
***Running Filebeat***

Run Filebeat as described [here](/integrations/log-shippers/filebeat.md#running-filebeat).  
An example of running Filebeat with the above parameters as environment variables:  
```
BRO_LOG_DIR=/home/bro/logs DATASPACE=bro HUMIO_HOST=localhost INGEST_TOKEN=none /usr/share/filebeat/bin/filebeat -c /etc/filebeat/filebeat.yml
```
{{% /notice %}}

{{% notice note %}}
***Logging is verbose***

Logging is set to debug in the above Filebeat configuration. It can be a good idea to set it to info when things are running well.
Filebeat log files are by default rotated and only 7 files of 10 megabytes each are kept, so it should not fill up the disk. See more in the [docs](https://www.elastic.co/guide/en/beats/filebeat/current/configuration-logging.html)
{{% /notice %}}


If there is data in the Bro log files, Filebeat will start shipping the data to Humio.
Go to the bro dataspace in Humio and data should be streaming in. Filebeat starts shipping data from the start of the file. 
If data is old, widen the default search interval in Humio.
To see data flowing into Humio in realtime, select a timeinterval of "1m window". This will "tail" the data as it arrives in Humio.


## Search Bro data

With everything in place, Bro data is streaming into Humio.  

In the above Filebeat configuration events are given a `#path` tag describing from which file they originate.
To search for data from the `http.log`:
```
#path=http 
```
Or search data from the `conn.log`
```
#path=conn
```

Just leave out the `#path` filter to search across all files. For example we could count how many events we have in the different files:
```
groupby(#path, function=count())
```

Or show the event distribution over time
```
timechart(#path, unit="1/minute")
```

If you are new to Humio and its search capabilities, try the online tutorial.  
There is a link to the tutorial in the top right corner of the Humio UI. 

## Bro dashboards

We have created two example dashboards. You can add them to your Humio installation by running this [script](bro-files/bro-add-dashboards.sh)  
Before running the script set the right values for the parameters at the top

{{% notice note %}}
***Make the script executable***
```
chmod +x <path_to_script>/bro-add-dashboards.sh
```
{{% /notice %}}
