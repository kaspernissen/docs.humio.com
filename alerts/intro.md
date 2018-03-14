Humio has the ability to reach out on various channels under some user configured circumstances.

## Concept
Every dataspace has it's own individual configuration. The Alert concept in Humio consists of two parts: *Notifiers* and *alerts*.

Notifiers are the integration between Humio and _other_ systems. Currently e-mail and webhooks are supported along with a list of integrations.   

Alerts are what triggers the notifiers. They are created using Humio's query language. For instance, when an alert detects your accesslog has reached a set threshold for Internal Server Errors, it will trigger a notifier that will send a message informing about the issue .

## Notifiers
Our list of notifiers is ever growing and currently we do support the following services. We are constantly expanding what we support (If you don't see a service you need here, please contact [support@humio.com](mailto:support@humio.com?subject=Requesting alert notifier) and we will be happy to find a solution for you):

* [E-mail](/alerts/notifiers/email.md)
* [Slack](/alerts/notifiers/slack.md)
* [WebHook](/alerts/notifiers/webhook.md)
* [OpsGenie](/alerts/notifiers/webhook.md)
<!--TODO: * PagerDuty-->
<!--TODO: * VictorOps-->


Creating a new Notifier is pretty simple. On the Alerts page there's a Notifiers pane on the left. For a new dataspace this list will be empty.
To create a new one hit the "New Notifier" button on the top right.

First you'll need to select a type of notifier from the "Notifier Type" dropdown list

All notifiers must be assigned a name.

!!! Tip "Naming notifiers"
	Make sure you give your notifiers a meaningful name, i.e. "OpsTeam", "Backlog issues" etc. We will make sure that the type of the notifier is also displayed.

## Alerts
Alerts are pretty simple. First and foremost they are based on standard Humio queries that a re running in a specified time window. An alert is connected to a notifier, that will send a message when the alert fires.
Alerts trigger whenever there's one or more events in the search result.
For instance an Alarm can be configured to trigger whenever there's more than 5 status 500s in the accesslog.  


```
#type=accesslog statuscode=500 | count(as=internal_server_errors) | internal_server_errors > 5
```

If there's less than 5 events in the time window the search will be an empty result and nothing will happen.
On the other hand, if there's more than five events a non-empty result will be returned and then alert will trigger the notifier.

!!! Tip "Alerts"
    Generally speaking, alerts can be divided into two groups
    * Single events, that can affect one or more users experience with the product. Usually not something that should wake up engineers at night but could result in an ticket on your issue tracker.
    * Faulty state is when one or more components has reached a bad state and is unable to function properly. This usually affects most users and is something that should wake up engineers at night.


### Creating new alerts
The easiest way to create a new alert is by building up your query in the Search view. Don't forget to set a Live time window for the search. And then hit the Save As… → Alerts option on the right.
The Alert should have a name assigned, i.e. "Too many Internal Server Errors". Select a notifier and finally Notification Frequency. The Notification Frequency is the minimum time before the same alert will be triggered again.

!!! Tip "Notification Frequency length"
    For notifiers like E-mail and Slack you want a lower Notification Frequency (more time inbetween) triggers since they don't do de-duplication.

<!--TODO: When Auto-cancel has been implemented, please reconsider guideline on Notification Frequency -->
