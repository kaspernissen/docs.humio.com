---
title: "Authentication"
---

Humio supports the following authentication types:

* [__None__ (Default)](#no-authentication)  
   Humio can run without authentication at all, and with only a single user account named _developer_.
   This is the default if authentication is not configured, but is __not recommended__ for production systems.
* [__LDAP__](#ldap)  
   Humio can connect to an LDAP server an authenticate users
* [__By-Proxy__](#by-proxy)  
   Humio can use the username provided by the proxy in a HTTP header.
* [__OAuth Identity Providers__](#oauth)  
   Authentication is done by external OAuth identity provider, Humio supports:
   - [Google]({{< relref "#google" >}})
   - [GitHub]({{< relref "#github" >}})
   - [BitBucket]({{< relref "#bitbucket" >}})
* [__Auth0 Integration__](#auth0)  
  [Auth0](https://auth0.com/) is a cloud service making it possible to login with many different OAuth identity providers e.g. Google and Facebook. You can also create your own database of users in Auth0.

Users are authenticated (logged in) using one of the above integrations. But the authorisation is done in Humio. Which dataspaces a user can access is specified in Humio.


{{% notice warning %}}
__Authentication disabled by default__  
In order to make first-time setup easy for new users, Humio defaults to running without authentication
at all. This is __not recommended__ for production environments.
{{% /notice %}}

## Root Access Token {#root-token}

If you have SSH access to the machine running Humio, you can always perform API request via `127.0.0.1:8080` using
the special API token for root access. The token is re-created every time the server starts, and placed in the file
`/data/humio-data/local-admin-token.txt`. The token allows root access on the API for anyone able to read this file.

The root token can be used for creating initial setup and configuration e.g. setting up users and data spaces.
It's also useful for running scripts/integrations on the local server, for provisioning or daily maintenance purposes.

{{% notice note %}}
Since the token is re-generated on every server startup, it is not suitable as a long-term API token.
{{% /notice %}}

### Creating a Root User

You can use the root token to create root users in Humio.
To create a user with root privileges on the server, run:

```bash
TOKEN=`cat /data/humio-data/local-admin-token.txt`
curl http://localhost:8080/api/v1/users \
 -X POST \
 -H "Content-Type: application/json" \
 -H "Authorization: Bearer $TOKEN" \
 -d '{"email": "$EMAIL", "isRoot": true}'
```

`$EMAIL` needs to be verifiable, using one of the configured IdP's (identity
providers) as described in this section.

When using LDAP, `$EMAIL` is the username the user must enter to login, and need not be an actual email address.

Once that user has been added, you can log on using that user and see your own API token, as described
in [API token](/sending_logs_to_humio/transport/http_api/#api-token).

## By-Proxy {#by-proxy}
Make Humio use the username provided by a HTTP proxy.

If you have a "reverse proxy" in front of Humio, and that proxy has a way of knowing a proper username or user email or
other unique user identifier, you can let the proxy decide what username the user gets access as inside Humio.
This is one way to accomplish single sign-on in certain configurations.

{{% notice note %}}
Make sure Humio is not accessible without passing through the proxy, as direct access to the Humio server
in this configuration allows anyone to assumte any identity in Humio.
{{% /notice %}}

Configure using:

    AUTHENTICATION_METHOD=byproxy
    AUTH_BY_PROXY_HEADER_NAME=name-of-http-header

The proxy must add a header with the username of the end user in the specified header.
If the proxy leaves the header blank, the user does not get authenticated,
and can thus only access e.g. shared dashboards

Please note, that Humio uses the "Authentication" header as transport from the browser to the Humio backend in this case too.
It is thus not possible to use a proxy that also uses this header. This rules out using e.g. https://github.com/bitly/oauth2_proxy


## LDAP {#ldap}
It is possible to check the password of your users using an ldap server, such as an AD. Set the following parameters in humio-config.env:

    AUTHENTICATION_METHOD=ldap
    LDAP_AUTH_PROVIDER_URL=your-url      (example: ldap://ldap.forumsys.com:389)
    LDAP_AUTH_PRINCIPAL=your-principal   (example: cn=HUMIOUSERNAME,dc=example,dc=com)

AUTHENTICATION_METHOD=ldap turns on "simple" ldap checking using an ldap bind.

LDAP_AUTH_PROVIDER_URL is the URL to connecto to. It can start with either "ldap://" or "ldaps://", which selects plain and SSL connections respectively.

LDAP_AUTH_PRINCIPAL can be left unset, in which case the username is used directly when binding to the server.
If it is set, the token `HUMIOUSERNAME` is replaced with the username, and the resulting string is used as principal.

### LDAP-search (using a bind user)

If LDAP/AD requires login with the exact DN, then it is possible to first do a search for the DN using
a low-priviledge bind username, and then successively do the login with the correct DN.  
To enable this, use this alternative property set:

```bash
AUTHENTICATION_METHOD=ldap-search
LDAP_AUTH_PROVIDER_URL=your-url       (example: ldap://ldap.forumsys.com:389)
LDAP_SEARCH_DOMAIN_NAME=your-domain   (example: example.com)
LDAP_SEARCH_BASE_DN=search-prefix     (example: ou=DevOps,dc=example,dc=com)
LDAP_SEARCH_BIND_NAME=bind-principal  (example: cn=Bind User,dc=example,dc=com)
LDAP_SEARCH_BIND_PASSWORD=bind-password
LDAP_SEARCH_FILTER=custom-search-filter (Optional, example: (uid={0}))
```

If `LDAP_SEARCH_FILTER` is set, Humio makes a search for a DN mathcing the provided filter
in the subtree specified by `LDAP_SEARCH_BASE_DN`, Using the bind-principal/password,
providing what a user entered at the login prompt as parameter to search.

If `LDAP_SEARCH_FILTER` is not set, the default filters to use are the following.
```
"(& (userPrincipalName={0})(objectCategory=user))"
"(& (sAMAccountName={0})(objectCategory=user))"
```

Humio will make the two searches above, one on `sAMAccountName=%HUMIOUSERNAME%`,
and one on `userPrincipalName=%HUMIOUSERNAME%@%LDAP_SEARCH_DOMAIN_NAME%` in the subtree specified by `LDAP_SEARCH_BASE_DN`,
using the bind-principal/password. Here `%HUMIOUSERNAME%` is what the user entered at the login prompt.


If either of those searches returns a distinguishedName, then
that DN is used to login (bind) with the end-user provided password.
A search for "(& (dn={0})(objectCategory=user))" is then performed in the new context,
with the DN found as further validation of that context.

## OAuth {#oauth}

Humio supports the OAuth 2.0 login flow for the following providers:

- [Google Sign-In]({{< ref "#google" >}})
- [GitHub Sign-In]({{< ref "#github" >}})
- [BitBucket Sign-In]({{< ref "#bitbucket" >}})

Providers must be configured on the Humio server, as seen in the section
for each provider.

You can enable several providers at the same time by setting multiple provider
configurations.

Before you get started you must create OAuth Apps with the provider and
get `client_id` and `client_secret`, and configure your `redirect_uri`.

{{% notice warning %}}
In order for OAuth authentication to work properly you must provide
a URL where Humio can be reached from the browser, see the configuration option [PUBLIC_URL]({{< ref "operation/installation/configuration.md#public_url" >}}).
{{% /notice %}}

### Google Sign-In {#google}

Detailed Setup Instructions: https://developers.google.com/identity/sign-in/web/sign-in

__Quick Summary__:

- Create a Project from the Google Developer Console,
- Create a _OAuth Client ID_ on the Credentials Page,
- Add an _Authorized redirect URI_: `%PUBLIC_URL%/auth/google`

Where [`%PUBLIC_URL%`]({{< relref "configuration.md#public_url" >}}) is the same value as Humio is configured with.
This can e.g. be `http://localhost:8080/auth/google` during development.
Login will fail if the `redirect_uri` is not set correctly.

Once your app is created you can configure Humio to use authenticate with Google:

__Configuration Properties__

- `GOOGLE_OAUTH_CLIENT_ID`: The `client_id` from your Google OAuth App
- `GOOGLE_OAUTH_CLIENT_SECRET`: The `client_secret` your Google OAuth App

Read more about [Configuring Humio]({{< relref "configuration.md" >}})

### GitHub Sign-In {#github}

Setup Instructions: https://developer.github.com/apps/building-oauth-apps/creating-an-oauth-app/

__Quick Summary__:

- Create an OAuth App from your organization / user settings page,
- Set the _Authorization callback URL_: `%PUBLIC_URL%/auth/github`

Read more about [Configuring Humio]({{< relref "configuration.md" >}})

Once your app is created you can configure Humio to use authenticate with GitHub:

__Configuration Properties__

- `GITHUB_OAUTH_CLIENT_ID`: The `client_id` from your GitHub OAuth App
- `GITHUB_OAUTH_CLIENT_SECRET`: The `client_secret` your GitHub OAuth App

Read more about [Configuring Humio]({{< relref "configuration.md" >}})


### BitBucket Sign-In {#bitbucket}

Setup Instructions: https://confluence.atlassian.com/bitbucket/integrate-another-application-through-oauth-372605388.html

__Quick Summary__:

- Go to your Account Settings
- Create an OAuth Consumer
- Set the _Callback URL_: `%PUBLIC_URL%/auth/bitbucket`
- Grant the `account:email` permission.
- Save
- Find the Key (Client Id), and Secret (Client Secret) in the list of consumers.

Read more about [Configuring Humio]({{< relref "configuration.md" >}})

Once your consumer is created you can configure Humio to use authenticate with BitBucket:

__Configuration Properties__

- `BITBUCKET_OAUTH_CLIENT_ID`: The `Key` from your BitBucket OAuth Consumer
- `BITBUCKET_OAUTH_CLIENT_SECRET`: The `Secret` your BitBucket OAuth Consumer

Read more about [Configuring Humio]({{< relref "configuration.md" >}})

## Auth0 {#auth0}

Humio can be configured to authenticate users through [Auth0](https://auth0.com/). Unless you have specific requirements,
Auth0's free tier is sufficient.

You can choose which Identity Providers (e.g. Google, Github and Facebook) you wish to allow for authentication.

{{% notice info %}}
__GDPR Consideration__  
Auth0 keeps information about your users. This may require you to have a Data Processing Agreement with
Auth0. If all you need is Google and GitHub, you can use [Humio's build-in support for these providers](#oauth) and
avoid storing your users' personal data with a third party provider.
{{% /notice %}}

### Create a Humio Application

You should create an Auth0 Application specifically for Humio.
When selecting the type of application you should choose the option _Regular Web Application_.

Once the application is created you will need to set up a couple of properties.

### Find your Application's Configuration

Under the application's _Settings_ page find:

- _Client ID_
- _Client Secret_
- _Domain_

We will need these for Humio's settings, you will also have to set the
`AUTHENTICATION_METHOD` option to `auth0`, e.g.:

```bash
AUTHENTICATION_METHOD=auth0
AUTH0_CLIENT_ID=$YOUR_CLIENT_ID
AUTH0_CLIENT_SECRET=$YOUR_CLIENT_SECRET
AUTH0_DOMAIN=$YOUR_AUTH0_DOMAIN
PUBLIC_URL=$YOUR_SERVERS_BASE_URL
```

_See the [installation overview page](/operation/installation) on how to set
these settings for your Humio cluster._

### Setting the Callback URI

In order to avoid CSRF attacks you must set the _Allowed Callback URLs_ field
to `%PUBLIC_URL%/auth/auth0`, e.g. https://www.example.com/auth/auth0, where
`%PUBLIC_URL%` is the value of the Humio configuration option `PUBLIC_URL`.

_Using Auth0 authentication for Humio requires that you set the `PUBLIC_URL` configuration option.
