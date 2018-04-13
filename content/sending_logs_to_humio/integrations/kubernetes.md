---
title: "Kubernetes"
---

This is a description of how you get your logs from **services in a Kubernetes cluster into Humio**. If you're looking at hosting Humio inside a Humio cluster, please take a look at [Running Humio as a Docker Image](/operation/installation/#running-humio-as-a-docker-container).

## Overview
Fluentd is used to forward *application-* and *host-* level logs from each kubernetes node to a Humio server. This integration extends the [standard setup](https://github.com/fluent/fluentd-kubernetes-daemonset) from Fluentd for log forwarding in kubernetes. For clusters where the master nodes are not accessible (eg. on GCP) we use eventer to expose events occurring in the kubernetes control plane.

## Quick Start
0. Pre-requisites:
   - Kubernetes cluster
   - User authorized to administrate via kubectl
   - Default service account with read privileges to API server for use by the [kubernetes metadata filter plugin](https://github.com/fabric8io/fluent-plugin-kubernetes_metadata_filter). This should be present by default in the kube-system namespace (even in kubernetes 1.6 with RBAC enabled)
   - A cloned copy of [kubernetes2humio](https://github.com/humio/kubernetes2humio) repository
     ```
	 $ git clone https://github.com/humio/kubernetes2humio
     ```
1. Setup your data space in Humio and create an [ingest-token](/sending_logs_to_humio/ingest_tokens/)
2. Base64 encode your ingest-token by running `printf '<TOKEN>' | base64` and update `fluentd/k8s/fluentd-humio-ingest-token-secret.yaml` line 8 with the value of the base64 encoded ingest-token
3. Update environment variables `FLUENT_HUMIO_HOST` fluentd/k8s/fluentd-humio-daemonset.yaml#L27) and [`FLUENT_HUMIO_DATA_SPACE`](fluentd/k8s/fluentd-humio-daemonset.yaml#L29) in [`fluentd/k8s/fluentd-humio-daemonset.yaml`](fluentd/k8s/fluentd-humio-daemonset.yaml)
4. Create fluentd resources in kubernetes: `kubectl apply -f fluentd/k8s/`
5. Logs start appearing in Humio!

Optional:

6. If master nodes are not scheduleable in your cluster, you can also
   create eventer to expose control-plane events: `kubectl apply -f
   eventer/`
7. Add `log-type` pod labels to designate Humio parsers

## Node-level Forwarding
In `fluentd/docker-image/` a docker image is defined which specifies
how to forward logs to Humio (with other settings, like log sources
reused from the base image). Kubernetes manifests are defined in
`fluentd/k8s/`: a daemonset will deploy fluentd pods across every
worker node inside the *kube-system* namespace, and each pod will read
the Humio ingest token from the `fluentd-humio-ingest-token` secret.

As per the normal setup, fluentd output is buffered, and uses TLS for
nice log confidentiality. It also appends kubernetes metadata such as
pod name and namespace to each log entry, wrapping raw logs in a
standard json structure.

### Log types
If your pod logs using JSON, Humio will parse the fields as excepted.
If your logs are text based, e.g. an nginx access log, you can set the
label `log-type` on a pod. Humio will use the log-type label to
determine which parser to apply to the log line. Using a parser you
can retain the structure in the logs. If the label is unspecified or
doesn't correspond to a parser then pod logs will be left as
unstructured text.

### Fluentd Container Variables
We expose three environment variables so the daemonset configuration
can be easily changed in different environments:

- **FLUENT_HUMIO_HOST**: Humio host
- **FLUENT_HUMIO_DATA_SPACE**: your data space
- **FLUENT_HUMIO_INGEST_TOKEN**: authorization to push logs into Humio

If you need to make further customizations, you will need to mount in
an altered version of the fluentd config files
`/fluentd/etc/fluent.conf` and `/fluentd/etc/kubernetes.conf`,
e.g. using ConfigMaps.

### Namespacing and Service Accounts Usage
As noted above, the 'default' service account is used by the fluentd
metadata plugin to lookup pod/namespace information. This is not
particularly in line with the developing RBAC model for service
accounts in kubernetes, but causes few problems in the kube-system
namespace where services are assumed to be somewhat root-like. Since
'default' service account is available to all pods in a namespace,
careful thought is recommended when assigning permissions to this
account to get fluentd to work outside the kube-system namespace.

## Control-plane Events
Appropriate for clusters where fluentd cannot run on master nodes, the
eventer component of [heapster](github.com/kubernetes/heapster) is
used to retrieve cluster events from the API server. We forward events
to fluentd by simply printing events to stdout, providing a consistent
interface for logs coming out of kubernetes. Eventer runs as a
deployment with a single instance handling all cluster events,
regardless of cluster size. As with heapster, it makes use of the
addon-resizer component to update requested resources as load on the
eventer, causing the eventer pod to get redeployed as cluster activity
grows past certain thresholds.

## What about metrics?
We are currently working on integrating metrics from
[heapster](https://github.com/kubernetes/heapster) into Humio.  Stay
tuned...

Getting logs from a Kubernetes cluster can be done using Fluentd.

See [kubernetes2humio](https://github.com/humio/kubernetes2humio) for
a ready made setup.