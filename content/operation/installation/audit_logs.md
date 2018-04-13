---
title: "Audit logs"
---

{{% notice note %}}
Audit logging is currently being implemented as is as such considered "BETA".
{{% /notice %}}

Humio emits audit log events on many users actions.

These events are designed with GDPR requirements in mind and come in two variants: Sensitive and non-sensitive.
The purpose of the separation into these two groups is to make the audit trail trustworthy by making the sensitive actions not mutable through Humio.

The sensitive kind is assignment of roles to users on dataspaces, changing retention settings on dataspaces,
and deleting data spaces and data sources and similar actions. See the list of all logged events below.

Sensitive events are tagged with `#sensitive="true"`, non-sensitive as `#sensitive="false"`.

All audit log events are written to the internal dataspace `humio-audit`.
All audit log events are written to the Log4j2 logger named "HUMIOAUDITLOG", which by default writes to the file "${humio.auditlog.dir}/humio-audit.log"

## Retention settings for audit logs in the `humio-audit` dataspace

The dataspace `humio-audit` has special retention rules that depends on the `sensitive` value.
Senstive logs are deleted by retention only when they are too old, controlled by the system configuration option `AUDITLOG_SENSITIVE_RETENTION_DAYS`. The default is 200 years.
Changing this setting requires a systems operator to change the configuration of the servers running Humio and restart Humio.

Non-sensitive logs are deleted according to the regular retention settings for the data space.
The default retention settings for this dataspace is to keep the log for ever. Please configure according to your requirements.

## Sensitive events logged

* Create or delete a dataspace. Attributes include `dataspaceID`
* Set Retention on a dataspace. Attributes include `originalSizeInBytes`, `sizeInBytes`, `timeInMillis`, `backupAfterMillis` only listing those that are set.
* Create user
* Update user
* Delete user
* Add user to a dataspace
* Remove user from a dataspace
* Update role for user on a dataspace
* Configuration of ingest listeners
* Adding, removing or changing ingest tokens
* Adding, removing or changing parsers
* Managing the cluster nodes

## Non-sensitive events logged

* Sign in to Humio. When using Auth0, this events is logged only once, when the users logs in the first time and is assigned a local uuid.
  When using LDAP, it is logged every time the users verifies user name / password combination.

* Query. Every time a query is submitted on behalf of the user, either trough the UI or API using the API-token of a user.
  Note: Read-only dashboards are not logged here.

# Permissions and ENFORCE_AUDITABLE mode

Users with Humio `root role` by default has both `admin permissions` and `delete permissions` in all dataspaces, being able to query the data stored in the dataspace, add and remove users, and delete data.
the `delete permission` also allows setting retention settings on a dataspace. This allows users with Humio `root role` unrestricted access to all data in the Humio cluster.

Setting the configuration option `ENFORCE_AUDITABLE=true` restricts users with Humio `root role` as follows:

* Root users can no longer query dataspaces unless the user is member of the dataspace.
* Root users can not set retention on dataspaces unless the root user has explicit `delete permission` on the dataspace.
* Root users can not delete data from dataspaces unless the root user has explicit `delete permission` on the dataspace.

Regardless of value of ENFORCE_AUDITABLE Humio users with root role can always:

* Add users to a dataspace and remove users from a dataspace, and change their permissions on the dataspace. This includes adding the root user it self to a dataspace.
* Perform cluster related administration tasks, such as adding and deleting servers.
* Manage ingest listeners and tokens.
