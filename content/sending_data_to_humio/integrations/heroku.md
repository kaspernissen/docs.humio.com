---
title: "Heroku"
---

### Logging from Heroku

To get logs from Heroku, you need to follow the guide lines to set up a 
[HTTPS Drain](https://devcenter.heroku.com/articles/log-drains#https-drains).  You need
to first create a dataspace at humio, and then create an ingest token in the data space's 
settings menu.

The comand to set up logging for your heroku app is then

```
heroku drains:add https://INGEST_TOKEN@HUMIO_HOST/api/v1/dataspaces/DATASPACE/logplex -a myapp
``` 

In which `INGEST_TOKEN` is the token you get from the Humio UI (a string such as `fS6Kdlb0clqe0UwPcc4slvNFP3Qn1COzG9DEVLw7v0Ii`),
and the `HUMIO_HOST` is your designated humio server (typically `cloud.humio.com`), and `DATASPACE` is
the data space you are using on said host.

#### Extra: Parsing Heroku logs

You can configure a parser to deal with the contents of your specific logs.
In the example below, the logplex ingester only deals with the log up to the `-` in the middle.  Anything
after that is specific to the particular kind of log.

```
<40>1 2012-11-30T06:45:29+00:00 host app web.3 - State changed from starting to up
<40>1 2012-11-30T06:45:26+00:00 host app web.3 - Starting process with command `bundle exec rackup config.ru -p 24405`
```

To deal with this, you can define a parser with the name of the application and the process (sans the `.3`) `"heroku_${app}_${process}"` (in this case `heroku_app_web`).    If such a parser exists in the dataspace, then it will be used to do further data extration in the log's message.
