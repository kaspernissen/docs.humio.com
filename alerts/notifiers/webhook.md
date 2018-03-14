Webhooks are our most flexible typpe of notifier. Use webhooks to integrate 3rd party services that Humio doesn't have natively integrated.
The webhook notifier can perform a http(s) call to any valid url and is managed via the following parameters

| Parameter             | Description                                                                                                                                                                                                          |
|-----------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Endpoint URL          | The URL of the endpoint the notifier will be interacting with                                                                                                                                                        |
| HTTP Method           | HTTP method of the call, typically `POST` or `PUT`                                                                                                                                                                   |
| Message Body Template | _Optional_. The body of the HTTP call. Can be of any form: JSON, Text or even XML. The Message Body accept our [Notifier template placeholders](/alerts/notifiers/templates.md) as well.                             |
| HTTP Headers          | A list of HTTP Headers, typically we recommend adding a `Content-Type` header with the corresponding content type, i.e. `application/json` for JSON message bodies. Add more headers by hitting the `+` on the right |
