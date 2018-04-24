---
title: "License Management"
weight: 101
---

Once you have purchased a license for running Humio on premise you will need
to install your license key.

Don't worry if you do not have a license key, you can run Humio in
Trial Mode and Humio will keep all your data once you install your license.

You can install a key either through the Administration interface in the UI,
or thought a API call.

If you are running Humio in a cluster setup, you only have to the they key
on a single node, it will be automatically propagated all cluster nodes.

## Using the Administration Interface

From the account menu in the top right corner of the UI select:

"Administration" > "License"

In the view you can paste in the license key.

## Using the API

Here is an example of updating the license key using CURL:

```bash
curl -v -X POST -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d "{ \"query\": \"mutation { updateLicenseKey(license: \\\"$LICENSE_KEY\\\") { expiresAt } }\" }" \
  https://$HUMIO_HOST/graphql
```

This will return status 200 and date when your license expires.

## License Properties

Admins can inspect the license properties from the admin interface under:

"Administration" > "License"  

## Expired Licenses

The UI will warn you 30 days before the license expires.

If you license runs out, Humio will continue accepting ingest data while
your license is renewed - but the search interval will be restricted.
