---
title: "Authentication"
---


Humio supports different ways of authentication users.

* __No authentication__
* __Auth0 authentication__   
   Auth0 [Auth0](https://auth0.com/) is a cloud service making it possible to login with Google, GitHub and other providers using [OAuth](https://en.wikipedia.org/wiki/OAuth).  
   You can also create your own database of users in Auth0.
* __LDAP authentication__  
   Humio can connect to an LDAP server an authenticate users
* __By proxy authentication__
   Humio can use the username provided by the proxy in a HTTP header.

Users are authenticated (logged in) using one of the above integrations. But the authorisation is done in Humio. Which dataspaces a user can access is specified in Humio.


{{% notice note %}}
User authentication is disabled by default.
{{% /notice %}}

## Root User

If you have login access to the machine
running Humio, you can perform HTTP calls via 127.0.0.1:8080 using
the special API token for root access. The token is created every time the server starts, and placed in the file
"/data//humio-data/local-admin-token.txt". This token allows "root" access on the API for anyone able to read this file.
This can then be used for creating initial users and data spaces on the humio server.
It's also useful for running scripts/integrations on the local server, for provisioning or daily maintenance purposes.

{{% notice note %}}
As the token is created anew on server startup, it is not suitable for use from other machines.
{{% /notice %}}

To create an initial user with root priviledges on the server, use this:

```bash
TOKEN=`cat /data/humio-data/local-admin-token.txt`
curl http://localhost:8080/api/v1/users \
 -X POST \
 -H "Content-Type: application/json" \
 -H "Authorization: Bearer $TOKEN" \
 -d '{"email": "$EMAIL", "isRoot": true}'
```

`$EMAIL` needs to be verifiable, using one of the configured IdP's (identity
providers). If using LDAP, `$EMAIL` is the username the user must enter to login, and need not be an actual email address.

Once that user has been added, you can log on using that user and see your own API token, as described
in [API token](/sending_logs_to_humio/transport/http_api/#api-token).

## By proxy
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



## LDAP
It is possible to check the password of your users using an ldap server, such as an AD. Set the following parameters in humio-config.env:

    AUTHENTICATION_METHOD=ldap
    LDAP_AUTH_PROVIDER_URL=your-url      (example: ldap://ldap.forumsys.com:389)
    LDAP_AUTH_PRINCIPAL=your-principal   (example: cn=HUMIOUSERNAME,dc=example,dc=com)

AUTHENTICATION_METHOD=ldap turns on "simple" ldap checking using an ldap bind.

LDAP_AUTH_PROVIDER_URL is the URL to connecto to. It can start with either "ldap://" or "ldaps://", which selects plain and SSL connections respectively.

LDAP_AUTH_PRINCIPAL can be left unset, in which case the username is used directly when binding to the server.
If it is set, the token `HUMIOUSERNAME` is replaced with the username, and the resulting string is used as principal.

## LDAP-search (using a bind user)

If LDAP/AD requires login with the exact DN, then it is possible to first do a search for the DN using
a low-priviledge bind username, and then successively do the login with the correct DN.  
To enable this, use this alternative property set:

    AUTHENTICATION_METHOD=ldap-search
    LDAP_AUTH_PROVIDER_URL=your-url       (example: ldap://ldap.forumsys.com:389)
    LDAP_SEARCH_DOMAIN_NAME=your-domain   (example: example.com)
    LDAP_SEARCH_BASE_DN=search-prefix     (example: ou=DevOps,dc=example,dc=com)
    LDAP_SEARCH_BIND_NAME=bind-principal  (example: cn=Bind User,dc=example,dc=com)
    LDAP_SEARCH_BIND_PASSWORD=bind-password
    LDAP_SEARCH_FILTER=custom-search-filter (Optional, example: (uid={0}))

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

## Auth0
    
Create an [Auth0](https://auth0.com/) account. Unless you have specific requirements, the free tier is sufficient.

### Configure OAuth providers
Select which Connections, like Google, Github and Microsoft you want to use for authentication, and follow Auth0's instructions on how to set them up. 
When configuring which information to request from external providers, only the email is needed. Humio will only allow users with a verified email to login.

Another possibility is to create a user database in Auth0.


### Configure the default client
An Auth0 account has one default client. This client will be used for authenticating users logging into Humio from a browser.
Go into settings for the default client and set the following configurations:  
 
 * Put the URL of the server where Humio is running in `Allowed Callback URLs` and `Allowed Logout URLs`. For example *https://humio.yourcompany.com*,
 * Setup which `JsonWebToken Signature algorithm` is used. 
    * Go to the bottom of the client settings and press `Show Advanced Settings`.
    * Select the `OAuth` tab.
    * For the input field `JsonWebToken Signature Algorithm` select HS256
    
### Create a non interactive client
Then create a client that is used for allowing the Humio backend to call Auth0's APIs. This client will be referred to as the API-client.
The client needs the following configurations:

* The name of the client is not important, it can be `API` or whatever you decide
* The default settings for the client is sufficient
* Allow this client to call the Auth0 management API
    * Navigate to APIs
    * Press `Auth0 Management API`
    * Go to the tab `Non Interactive Clients`
    * Authorise this client
    * The client menu item should expand allowing scopes to be selected.
    * The only scope needed for this client is `read:users`
    * Update scopes and the client is ready for use
    

### Configure Humio
Now configure Humio to use the Auth0 account. Humio needs the client ids, client secrets and domain of the Auth0 clients. These are found at the top of the client settings page.
Specify the following properties in the humio-config.env: 

    AUTHENTICATION_METHOD=auth0
    AUTH0_DOMAIN=auth0domain
    AUTH0_WEB_CLIENT_ID= default-clients client ID
    AUTH0_WEB_CLIENT_SECRET= default clients client secret
    AUTH0_API_CLIENT_ID= API-clients client ID
    AUTH0_API_CLIENT_SECRET= API-clients client secret
      
Now Humio should authenticate using Auth0.

For questions, problems and more advanced configurations Please [contact us](mailto:support@humio.com)
