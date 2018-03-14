
# Sizing Humio / Hardware Recommendations

This document describes how to choose hardware and size a Humio installation.

Sizing depends on your usage patterns, so we recommend first doing an example setup to see how Humio works 
with your data.  The following provides some examples.

For clustered setups, and/or setups with data replication, we currently recommend contacting
humio support for specific suggestions.

## Background

With Humio, the limiting factor is usually query speed, not ingest capacity.  Query speed depends on two factors:
available RAM and number of CPUs.  The following numbers are all "ballpark recommendations", your exact circumstances
may be different.

A running Humio instance will use something like 10-20% of available RAM - the rest of available memory is used for OS-level
file system cache. If you're for example on an AWS `m4.4xlarge` (60GB RAM, 16 vCPUs), then you would typically see 
~10GB used for running Humio, and ~50GB available for file system caches.    The 50GB cache represents compressed Humio
data files which are optimized for querying; this way you will typically observe recently read or written data 
is faster to query.

Data is typically compressed 5-10x, depending on what it is.  Your mileage may wary, but short log lines 
(http access logs, syslogs, etc.) compress better than longish JSON logs (such as those coming from metricbeat).

For data available as compressed data in the OS-level cache, Humio generally provides query speed at 1GB/s/vCPU,
or 1GB/s/hyperthread.  So, on a `m4.4xlarge` instance with 16 vCPUs, you observe ~16GB/s queries.  If your compression
ratio is 6x, then that means that the last 50GB x 6 = 300GB of ingested data can be read at this speed.

We recommend that you should be able to keep 48hrs of data accessible for fast querying for a good experience, so
thus we recommend that a `m4.4xlarge` is used for up to 150GB/day ingest; and this will let you do a full scan of
a day's worth of data in less than 10 seconds.  Many queries will be faster because you usually narrow the search
by specifying tags or other time limitations.

On this setup, a 300GB/day ingest will use ~5% of your CPU load, so there is plenty of headroom for data spikes 
and running dashboards.

Searches going beyond what fits in the OS-level filesystem caches are significantly slower, and depends on the
disk I/O performance.  We built Humio to run on local SSDs, so it is not (presently) optimized to run on high-latency
EBS storage. But it will work.

## Rules of thumb

- Assume data compresses 6x (test your setup and see, better compression means better performance).
- You need to be able to hold 48hrs of compressed data in 80% of you RAM.
- You want enough hyper threads/vCPUs (each giving you 1GB/s search) to be able
  to seach 24hrs of data in less than 10 seconds.
- You need disk space to hold your compressed data. NEver fill your disk more than 80%.

> Example: your machine has 64G of ram, and 8 hyper threads (4 cores), 1TB of storage.
  Your machine can hold 307GB of ingest data compressed, and process 8GB/s.  In this case
  that means that 10 seconds worth of query time will run through 80G of data.  So this machine 
  fits an 80G/day ingest, with +3 days data available for fast querying.  
  You can store 4.8TB of data before your disk is 80% full, corresponding to 60 days.  
   

## AWS Single Instance Humio

For AWS, we recommend starting with these instance types.  This represents
setups that can hold 48h compressed ingest data in RAM; powerful enough to
do a full tablescan of ~24h data in less than 10 seconds.

| Instance Type | Daily Ingest | RAM | vCPUs | Notes |
|---------------|--------------|-----|-------|-------|
| `m4.16xlarge` | 600GB        | 256 | 64 (2 CPUs) | run with per-instance cluster
| `m4.10xlarge` | 400GB        | 160 | 40 (2 CPUs) | run with per-instance cluster
| `m4.4xlarge`  | 200GB        | 60  | 16 | single node per instance
| `m4.2xlarge`  | 100GB        | 40  | 8  | single node per instance
| `m2.xlarge`   | 30GB         | 15  | 4  | single node per instance

For multi-socket machines (with multiple physical CPUs), we recommend running
humio as an per-instance cluster, with each Humio node tied to a single
physical CPU.

With EBS storage, you will see query performance drop ~100x when querying beyond
what is loaded into memory caches.

Alternatively, for a little more convenience and performant setup, you can run `i3` 
instances which have more RAM, and lets you store the data on local SSDs.  


| Instance Type | Daily Ingest | RAM | vCPUs | Notes |
|---------------|--------------|-----|-------|-------|
| `i3.16xlarge` | 600GB        | 488 | 64 (2 CPUs) | run with per-instance cluster
| `i3.8xlarge`  | 300GB        | 244 | 32 (2 CPUs) | run with per-instance cluster
| `i3.4xlarge`  | 150GB        | 122 | 16 | single node per instance
| `i3.2xlarge`  | 70GB         | 61  | 8  | single node per instance

For instance an `i3.4xlarge` would be suitable for 150GB/day ingest, holding 5 days
of data in cache, and because of the SSDs this would be avoiding the "cliff" when 
the cache runs full.  The 3.8TB SSD would hold ~150 days of ingest data.

With ephemeral SSD storage, you'd want to setup EBS instances for live backup (and kafka's storage), 
so that you can load the Humio data onto a fresh machine quickly.  Humio live backup live-replicates all data
to a separate network drive such that data loss is prevented even for ephemeral disks.


## Live Queries / Dashboards

Running many live queries / dashboards is less of an issue with Humio than 
most other similar products, because these are kept in-memory as a sort of
in-memory materialized view.  When initializing such queries, it does need to
run a historic query to fill in past data, and that can take some time it
it extends beyond the compressed-memory horizon.

