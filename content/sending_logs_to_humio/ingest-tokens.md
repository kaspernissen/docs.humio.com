---
title: "Ingest Tokens"
date: 2018-03-15T08:21:44+01:00
weight: 1
---

When communicating with Humio, you must provide an API authorization token. All users have an API token.

Humio also provides **ingest tokens** that you can use for sending data into Humio.
These tokens are write-only authorizations. You cannot query Humio, log in, or read any data using an ingest token.

!!! Note "Why use ingest tokens?"

    Ingest tokens are tied to a dataspace, instead of individual users. This provides an alternative way of managing authorization that is more convenient for some use cases.

    For example, if a user leaves the organization or project, then you do not need to reprovision all agents that send data with a new token.

You can manage your ingest tokens in the **Settings** tab:

![managing ingest-tokens](/images/ingest-tokens.png)

Click the 'eye' button (3) next to the token you want to view.