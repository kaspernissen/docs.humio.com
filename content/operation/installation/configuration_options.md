---
title: "Configuration Options"
weight: 1
---

Humio is configured by setting Environment Variables, when running Humio in Docker you can pass
set the `--env-file=` flag and keep your configuration in a file.
For a quick intro to setting configuration options see the [installation overview page](/operation/installation).


## Example configuration file with comments

```bash
# The stacksize should be at least 2M.
# We suggest setting MaxDirectMemory to 50% of physical memory. At least 2G required.
HUMIO_JVM_ARGS=-Xss2M -XX:MaxDirectMemorySize=32G

# Make Humio write a backup of the data files:
# Backup files are written to mount point "/backup".
#BACKUP_NAME=my-backup-name
#BACKUP_KEY=my-secret-key-used-for-encryption

# ID to choose for this server when starting up the first time.
# Leave commented out to autoselect the next available ID.
# If set, the server refuses to run unless the ID matches the state in data.
# If set, must be a (small) positive integer.
#BOOTSTRAP_HOST_ID=1

# The URL that other humio hosts in the cluster can use to reach this server. Required.
# Examples: https://humio01.example.com  or  http://humio01:8080
# Security: We recommend using a TLS endpoint.
# If all servers in the Humio cluster share a closed LAN, using those endpoints may be okay.
EXTERNAL_URL=https://humio01.example.com

# The URL which users/browsers will use to reach the server
# This URL is used to create links to the server
# It is important to set this property when using OAuth authentication or alerts
PUBLIC_URL=https://humio.mycompany.com

# Kafka bootstrap servers list. Used as `bootstrap.servers` towards kafka.
# should be set to a comma separated host:port pairs string.
# Example: `my-kafka01:9092` or `kafkahost01:9092,kafkahost02:9092`
KAFKA_SERVERS=kafkahost01:9092,kafkahost02:9092

# Zookeeper servers.
# Defaults to "localhost:2181", which is okay for a single server system, but
# should be set to a comma separated host:port pairs string.
# Example: zoohost01:2181,zoohost02:2181,zoohost03:2181
# Note, there is NO security on the zookeeper connections. Keep inside trusted LAN.
#ZOOKEEPER_URL=localhost:2181

# Select the TCP port to listen for http.
#HUMIO_PORT=8080

# Select the IP to bind the udp/tcp/http listening sockets to.
# Each listener entity has a listen-configuration. This ENV is used when that is not set.
#HUMIO_SOCKET_BIND=0.0.0.0

# Select the IP to bind the http listening socket to. (Defaults to HUMIO_SOCKET_BIND)
#HUMIO_HTTP_BIND=0.0.0.0

# The URL where the Humio instance is reachable. (Leave our trailing slashes)
#
# This is important if you plan to use OAuth Federated Login or if you want to
# be able to have Alert Notifications have consistent links back to the Humio UI.
# The URL might only be reachable behind a VPN but that is no problem, as a
# browser can access it.
#PUBLIC_URL=https://demo.example.com/humio
```

### Java virtual machine parameters
You can specify Java virtual machine parameters to pass to Humio using the property `HUMIO_JVM_ARGS`. The defaults are:
```bash
HUMIO_JVM_ARGS=-XX:+PrintFlagsFinal -Xss2M
```

## Number of CPU Cores
You can specify the number of processors for the machine running Humio by setting the `CORES` property.
Humio uses this number when parallelizing queries.

By default, Humio uses the Java [available processors function](https://docs.oracle.com/javase/8/docs/api/java/lang/Runtime.html#availableProcessors--) to get the number of CPU cores.

### Configuring Authentication

Humio supports different ways of authentication users. Read more in the dedicated [Authentication Documentation]({{< relref "authentication.md" >}}).

### Run Humio behind a (reverse) proxy server
It is possible to put Humio behind a proxy server.

{{% notice info %}}
It is important that the proxy does not rewrite urls, when forwarding to Humio.
{{% /notice %}}

For example a proxy server could accept all request at `http://example.com` and expose humio on `http://example.com/internal/humio/`.

For this to work, the proxy must be set up to forward incoming requests with a location starting with `/internal/humio` to the Humio server and
Humio must be configured with a proxy prefix url `/internal/humio`. This is done by letting the proxy add the header `X-Forwarded-Prefix`.

Humio requires the proxy to add the header `X-Forwarded-Prefix` only when Humio is hosted at at a non-empty prefix.
Thus hosting Humio at "http://humio.example.com/" works without adding a header. An example onfiguration snippet for an nginx location is:

```nginx
location /internal/humio {

    proxy_set_header        X-Forwarded-Prefix /internal/humio;
    proxy_set_header        X-Forwarded-Proto $scheme;
    proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header        X-Real-IP $remote_addr;
    proxy_set_header        Host $host;

    proxy_pass          http://localhost:8080;
    proxy_read_timeout  10;
    proxy_redirect http:// https://;
    expires off;
    proxy_http_version 1.1;
  }
```

If it is not feasible for you to add the header `X-Forwarded-Prefix` in your proxy, there is a fall-back solution: You can set `PROXY_PREFIX_URL` in your `/home/humio/humio-config.env`.

### Raising system limits for Humio

Humio needs to be able keep a lot of files open at a time. The default limits are typically too low for any significant amount of data. Increase the limits using commands like:

```bash
cat << EOF | tee /etc/security/limits.d/99-humio-limits.conf
# Raise limits for files.
humio soft nofile 250000
humio hard nofile 250000
EOF

cat << EOF | tee -a /etc/pam.d/common-session
# Apply limits:
session required pam_limits.so
EOF
```

These settings apply to the next login of the Humio user, not to any running processes.

### Public URL {#public_url}

`PUBLIC_URL` is the URL where the Humio instance is reachable from a browser.
Leave out trailing slashes.

This property is only important if you plan to use [OAuth Federated Login]({{< relref "operation/installation/authentication.md#oauth">}}), [Auth0 Login]({{< relref "operation/installation/authentication.md#auth0">}}) or if you want to be able to have Alert Notifications have consistent links back to the Humio UI.

The URL might only be reachable behind a VPN but that is no problem, as the user's
browser can access it.
