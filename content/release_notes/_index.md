---
title: "Release notes"
weight: 9
pre: "<b>9. </b>"
---


## 2018-03-13
Regular update release.    
Data migrations: No.  

- Introduced [licensing](/operation/installation/license/). Humio requires a license to run. It can run in trial mode with all features enabled for a month.
- Fixed bug: In some scenarios the browsers back button had to be clicked twice or more to go back.
- Fixed bug: Enter does not start search after navigating using the browsers back button

## 2018-03-06
Cloud-only release.   
Data migrations: No.  
Version: 2018-03-07T08-10-28--build-2154--sha-a65e39f79ad7b4d38c18e9b9090648abb7da17c2  

- Starring dashboards. They will go to the top of the dashboard list and there is a section with starred dashboards on the frontpage.
- Labeling dashboards. Put labels on dashboards to organise them.
- Disconnect points on timecharts if there are empty buckets between them.
- Fixed bug: Make /regex/ work with AND and OR combinators.
- Fixed bug: gzipping of http responses could hit an infinite loop, burning cpu until the process was restarted.

## 2018-02-23
Minor update release.  
Data migrations: No.  
Version: 2018-02-23T05-52-15--build-2075--sha-83b8f03c2f4dea9acfbc95ba47a475343d956d2b  

- Fix bug: Retention was not deleting anything.  

## 2018-02-22
Minor update release.  
Version: 2018-02-22T14-01-13--build-2069--sha-b303c8b5330ac05a53d7f5b82e748cf11b7c3014.  
Data migrations: No.  

- Fixed bug: Clustered on-premises installs could stall in the copying of completed segment files inside the cluster.
- Allow saving dashboards with queries that do not parse. Allows editing dashboards where another widget is failing.
- Allow | before and after query.
- Fix issue with `:` occurring in certain query expressions, introduced with the new `:=` syntax.  A query
  such as `foo:bar | ...` using an unquoted string would fail to parse.

## 2018-02-21
Regular update release.  
Version: 2018-02-21T12-11-11--build-2054--sha-e65bbe26954feb1acbf45310ded5268e017c93a6  
Data migrations: No.  

- New `alt` language construct.
  This allows alternatives similar to `case` or `cond` in other languages.  
  With `... | alt { <query>; <query>; ...; * } | ...` every event passing through
  will be tried to the alternatives in order until one emits an event.  If you add `; *` in the end, events
  will pass through unchanged even if no other queries match.  Aggregate operators are not allowed in the 
  alternative branches.
  
- New `eval` syntax.  As a shorthand for `... | eval(foo=expr) | ...` you can now write `... | foo :=expr | ...`. 
  Also, on the left hand side in an eval, you can write ``  `att` := expr `` which assigns the field that is the 
  current value of `att`.
  
- Improvements to the query optimizer.  Data source selection (choosing which data files to scan from disk) can 
  now deal with more complex tag expressions.  For instance, now queries involving `OR` such as 
  `#tag1=foo OR #tag2=bar` are now processed more efficiently.  The query analyzer is 
  also able to identify `#tag=value` elements everywhere in the query, not only in the beginning of the query.
  
- New Feature: Dashboard Filters.
  Dashboard Filters allow you to filter the data set across all widgets in a dashboard. This effectively means
  that you can use dashboards for drill-down and reuse dashboards with several configurations.  
  Currently filters support writing _filter expressions_ that are applied as prefixes to all your widgets'
  queries. We plan to extend this to support more complex parameterized set-ups soon - but for now, prefixing
  is a powerful tool that is adequate for most scenarios.  
  Filters can be named and saved so you can quickly jump from e.g. Production Data to Data from your Staging
  Environment.  
  You can also mark a filter as "Default". This means that the filter will automatically be applied when
  opening a dashboard.

- Improvement: Better URL handling in dashboards.  
  The URL of a dashboard now includes more information about the current state or the UI. This means
  you can copy the URL and share it with others to link directly to what you are looking at. This includes
  `dashboard time`, `active dashboard filter`, and `fullscreen` parameters.  
  This will make it easy to have wall monitors show the same dashboard but with different filters applied,
  and allow you to send links when you have changed the dashboard search interval.

- New Feature: Show Widget Queries on Dashboards
  You can toggle displaying the queries that drive the widgets by clicking the "Code" button on dashboards.  
  This makes it easier to write filters because you can peek at what fields are being used in your widgets.

- Improvement: Better handling of reconnecting dashboards when updating a Humio instance.

- Improvement: Better and faster query input field.  
  We are using a new query input field where you should experience less "input lag" when writing queries.
  At the same time, syntax highlight has been tweaked, and while still not supporting some things like
  array notation, it is better than previous versions.

- New Feature: Clock on Dashboards. Making it easier to know what time/timezone Humio is displaying result for.

- Configure when Humio stops updating live queries (queries on dashboards) that are not viewed (not polled). This is now possible with the config option `IDLE_POLL_TIME_BEFORE_LIVE_QUERY_IS_CANCELLED_MINUTES`. Default is 1 hour.

## 2018-02-19
Regular update release.     
Version: 2018-02-19T10-09-13--build-2028--sha-f0923d76ad977c500927372b6be627b7b0e1e160   

Data migrations: **Yes: The backups are incompatible.**

- Backup feature (using `BACKUP_NAME` in env) now stores files in a new format.
     If using this, you MUST either move the old files out of the way, or set `BACKUP_NAME` to a new value, thus pointing to an new backup directory.
     The new backup system will proceeed to write a fresh backup in the designated folder.
     The new backup system no longer require use of "JCE policy files".
     Instead, it needs to run on java "1.8.0_161" or later.
     The current Humio docker images includes "1.8.0_162".
- Export to file. It is now possible to export the results of a query to a file.  
    When exporting, the result set is not limited for filter queries, making it possible to export large amounts of data.  
    Plain text, JSON and ND-JSON (Newline Delimited JSON) formats are supported in this version.  
- [format()](/searching_logs/query_functions/#format) function. Format a string using printf-style.
- [top()](/searching_logs/query_functions/#top) function. Find the most common values of a field.
- Performance improvement for searches using in particular "expensive" aggregates functions such as groupby and percentile.
- `global-snapshots` topic in Kafka: Humio now deletes the oldest snapshot after writing a new, keeping the latest 10 only.


## 2018-02-07
Regular update release.   
Data migrations: No.   
Version: 2018-02-07T13-26-11--build-1962--sha-2559a567039ce7399da48dbb2aed9fdfe2fddc3e  

- Reduced query state size for live queries decreasing memory usage.
- Added [concat()](/searching_logs/query_functions/#concat) function.
- Log4j2 updated from 2.9.1 to 2.10.0. If you are using a custom logging configuration, you may need to update your configuration accordingly.
- Removed GC pauses caused by java.util.zip.* native calls from compressed http-traffic triggering "GCLocker initiated GC", which could block the entire JVM for many seconds.
- To eliminate GC pauses caused by compression in the Kafka-client in Humio, Humio now disables compression on all topics used by Humio.
  Humio compresses internally before writing to Kafka on messages where compression is required. (Ingest is compressed.)
  This release of Humio enforces this setting onto the topics used by humio.
  This is the list of topics used by Humio. (Assuming you have not configured a prefix, which is in then used on all of them)
```
      global-events
      global-snapshots
      humio-ingest
      transientChatter-events
```
  You can check the current non-default settings using this command: (Replace the topic name)

```bash
cd SOME_KAFKA_INSTALL_DIR
./bin/kafka-configs.sh --zookeeper localhost:2181 --entity-type topics --entity-name humio-ingest --describe
```


## 2018-02-02
Minor update release.   
Data migrations: No.   
Version: 2018-02-01T09-22-15--build-1899--sha-541164ae0e9374edc0e9d8956588326bca3647ed  

- RDNS function now runs asynchronously, looking up names in the background and caching the responses. Fast static queries may complete before the lookup completes.
  Push rdns as far right as possible in your queries, and avoid filtering events based on the result, as rdns is non-deterministic.


## 2018-02-01
Minor update release.   
Data migrations: No.    

- Improved performance on live queries with large internal states


## 2018-01-30
Regular update release.     
Data migrations: Yes. Rollback to previous version is supported with no actions required.   
Version: 2018-01-31T12-36-23--build-1884--sha-09768f142d1eb8097a5d08c1001df61a202b5d4a   

- Added PagerDuty notifier
- Added VictorOps notifier
- Fix bug in live queries after restarting a host.
- If the "span" for a timechart is wider than the search interval, the default span is used and a warnign is added. This improves zooming in time on dashboards.
- OnPrem: Configuration obsolete: No longer supports the KAFKA_HOST / KAFKA_PORT configuration parameters. Use the KAFKA_SERVERS configuration instead.
- OnPrem: Size of query states are now bounded by the MAX_INTERNAL_STATESIZE, which defaults to MaxHeapSize/128.
- On timechart, mouse-over now displays series sorted by magnitude, and pretty-prints the numbers.
- Regular expression parsing limit is increased from 4K to 64K when ingesting events.    

## 2018-01-25
Minor update release.  
Data migrations: No.  
Version: 2018-01-25T08-09-46--build-1819--sha-6c470f489af78891b4608fbf21cd930a05a5411d   

- Stop queries and warn if too big query states are detected
- Warnings are less intrusive inn the UI.



## 2018-01-23
Minor update release.  
Data migrations: No.  
Version: 2018-01-23T12-42-47--build-1788--sha-0c4e72ca7c36317ad8fc3687075e0c84be813569  

- Support ANSI colors
- Firefox is now supported.
- Added OpsGenie notification template
- Added documentation of the file formats that the lookup function is able to use
- Added "tags" to "ingest-messages" endpoint to allow the source to add tags to the events. It's still possible and recommended to add the tags using the parser.
- Fixed bug: An alert could fire a notification on a partial query result, resulting in extra alerts being fired.
- Fixed bug: Ingesting to a personal sandbox dataspace using ingest token was not working.


## 2018-01-19
Regular update release.    
Data migrations: No.  
Version: 2018-01-19T07-37-48--build-1755--sha-9b1daf191d2625da9a557078cb0af2d6a8413b7f   

- New front page page.  
    You can now jump directly to a dashboard from the front page using the dropdown on each list item.  
    All dashboards can also be filtered and accessed from the "Dashboards Tab" on the front page.
- Better Page Titles for Browser History.
- Renewing your API token from your account settings page.
- More guidance for new users in the form of help messages and tooltips.
- Added [suggestions on sizing of hardware to run Humio on](/operation/installation/instance_sizing/).
- Startup time reduced when running on large datasets.
- Fix [bug #35](https://github.com/humio/issues/issues/35) Preventing you from doing e.g. `groupby` for fields containing spaces or quotes in their field name.
- Fixed bug: If Kafka did not respond for 5 seconds, ingested events could get duplicated inside humio.
- Fixed bug: Cancelled queries influenced performance after they were cancelled.
- Fixed bug: Multiple problems on the Parsers page have been fixed.
- Sort and table function now supports sorting on multiple fields. Sort also supports sorting using "type=hex" as numbers when the field value starts with "(-)0x", or the type=hex argument is added.
- Fixed bug: replace function on @rawstring now work also for live part of query.
- For on-prems: You can now adjust BLOCKS_PER_SEGMENT from the default of 500 for influence on size of segment files.
- New implementation of Query API for integration purposes.


## 2018-01-09
Minor update release.   
Version: 2018-01-09T14-02-07--build-1632--sha-370b5cee6aa42d49ef419b454b94cafd9a0995ea   

- Fixed performance regression in latest release when querying, that hit in particular data sources with small events
- Percentile function now accepts "as" parameter, allowing to plot multiple series as percentiles in a timechart.
- Added option to do authentication in a http proxy in front of Humio, while letting Humio use the username provided by the proxy.


## 2018-01-04
Regular update release.  

- Netflow support for on premises customers. It is now possible to send Netflow data directly to Humio. It is configured using Ingest listeners.
- Tags can be defined in [parsers](/sending_logs_to_humio/parsers/parsing/#adding-tags).
- [Filebeat configuration](/sending_logs_to_humio/log_shippers/beats/filebeat/) now utilises tags in parsers. The Filebeat configuration is still backward compatible. 
- Better [Bro integration](/guides/bro/).
- Added [stddev()](/searching_logs/query_functions/#stddev) function.
- Root user management in the UI. A gear icon has been added next to the "Add Dataspace" button, if you are logged in as a root user. Press it and it is possible to manage users.
- Fix [bug #19](https://github.com/humio/issues/issues/19) uploading files to be used with the [lookup](/searching_logs/query_functions/#lookup) function. 
- Datasources are [autosharded](/operation/on_prem_http_api/#auto-tagging-high-volume-datasources) into multiple datasources if they have huge ingest loads. This is mostly an implementation detail.
- [Tag sharding](/operation/on_prem_http_api/#setup-sharding-for-tags). A tag with many different values would result in a lot of small datasources which will hurt performance.
A Tag will be sharded if it has many different values.  
For example, having a field user as tag and having 100.000 Different users could result in 100.000 datasources. Instead the tag will be sharded and allowed to have 16 different values (by default).  
In general do not use a field with high cardinality as a tag in Humio.
    

## 2017-12-18
Minor update release.  
Version: 2017-12-18T13-59-11--build-1480--sha-c3d4e89c0a646a940b7ef846257918f4baf6f987   

- Fixed a bug where the "parsers" page the fields found in parsing were hidden.
- Fixed a bug that leaked Kafka-connections.
- Turn off LZ4 on connection from Humio to kafka.
  Note: Storage of data in Kafka is controlled by broker settings, although having "producer" there will turn compression off now.
  The suggested Kafka broker (or topic) configuration is to have "compression.type=lz4"

## 2017-12-15
Minor update release.   

- Set default `timechart(limit=20)`.  This can cause some dashboards to display warnings.  But we decided that
  "for the greater good" and simplicity, it's the best default behavior.

## 2017-12-14
Regular update release.  
Version: 2017-12-14T14-28-14--build-1450--sha-f0ebc9b77e3bb1df225e1ea77b30da922443c812

 - New Search View functionality allows you to sort the event list to show newest events at the end of the list.
 - Scrolling the event list or selecting an event will pause the result stream while you inspect the events,
   this especially makes it easier to look at Live Query results. Resume a stream by hitting `Esc` or clicking the button.
 - Syntax highlighting in the event list for certain formats including Json.
 - Event List Results are now horizontally scrollable, though limited in length for performance reasons.
 - Different View Modes have been made more prominet in the Search View by the addition of tabs at the top of
   the result view. As we extend the visualization to be more specialized for different types of logs we expect
   to add more *Context Aware* tabs here, as well as in the inspection panel at the bottom of the screen.
 - Performance improvements in timecharts.
 - Styling improvement on several pages.
 - Typo Corrections in the Tutorial

## 2017-12-13
Regular update release.  
Version: 2017-12-13T14-44-36--build-1438--sha-6d538a6adf08f5b808962144a4f6d6c093fb2d08  

 - Upgraded to kafka 1.0. This is IMPORTANT for on premises installations. It requires updating the kafka docker image before updating the humio docker image
 - Filter functions can now generically be negated `!/foo/`, `!cidr(...)`, `!in(...)`, etc.
 - New parameter `timechart(limit=N)` chooses the "top N charts" selected as the charts with
   the most area under them.  When unspecified, `limit` value defaults to 100, and produces a warning if exceeded.
   When specified explicitly, no warning is issued.

## 2017-12-11
Minor update release.  
Version: 2017-12-11T12-11-10--build-1415--sha-c2660c06199865e4e7e8cc53ab7190bb8d16a478   

 - Support datasources with large data volumes by splitting them into multiple internal datasources. (Only for root users, ask your admin.)
 - Tags can now be sharded, allowing to add e.g IP-adresses as tags. (Only for root users, ask your admin.)

## 2017-12-07
Minor update release.

 - Kafka topic configuration defaults changed and documented.

If running on-premises, please inspect and update the retention settings on the Kafka topics created by Humio to match your Kafka . [See Configuration of Kafka](/operation/installation/kafka_configuration/).

## 2017-12-06
Regular update release.  

 - When saving queries/alerts - the query currently in the search field is saved - not the last one that ran
 - New implementation of the timechart function with better performance
 - Improved ingest performance by batching requests more efficiently to the kafka ingest queue. Queue Serialization format changed as well
 - Fixed bug with some tables having narrow columns making text span many lines
 - Fixed bug in timechart graphs, The edge buckets made the graph go to much back in time and also into the future

## 2017-11-26
Minor update release.

 - Humio now sets a CSP header by default. You can still replace this header in your proxy if needed
 - Fixed bug, where failure to compile regexp in query was reported as an internal server error
 - Bug fix: Make Kafka producer settings relative to Java max heap size

## 2017-11-24
Minor update release.  
Version: 2017-11-24T13-11-13--build-1280--sha-1e30b2e8f36eaa9b6d20be8f7929a1c81d0d1c4f

 - Improve support for running Humio behind a proxy with CSP
 - Fix links to documentation when running behind a proxy
 - Possible to specify tags for ingest listeners in the UI

## 2017-11-21
Regular update release.  
Version: 2017-11-21T22-05-37--build-1245--sha-1dd64f3d2665b5923549e84b2a1bc34a9bd10130   

 - Ui for adding ingest listeners (Only for root users)
 - New sandbox dataspaces. Every user get their own sandbox dataspace. It is a personal dataspace, which can be handy for testing or quickly uploading some data
 - New interactive tutorial
 - Added pagination to tables
 - Fixed a couple of issues regarding syntax highlighting in the search field
 

## 2017-11-15
Regular update release.  
Version: 2017-11-16T08-50-16--build-1204--sha-f15c4e367ee62e187f76788c12eb0feb3181be0e  

 - Fix bug where Humio ignored the default search range specified for the dataspace
 - Fix bug with "save as" menu being hidden behind event distribution graph
 - Add documentation for new [regular expression syntax](/searching_logs/)
 

## 2017-11-14
Regular update release.  
Version: 2017-11-14T11-02-13--build-1192--sha-4c326fd4ca7e79f581df6137be975bd6a87531c8

 - Possible to specify tags when using ingest listeners
 - Alerts are out of beta.
 - Grafana integration. [Check it out](https://github.com/humio/humio2grafana)
 - New [Humio agent for Mesos and DC/OS](https://github.com/humio/dcos2humio)
 - Improved Error handling when a host is slow. Should decrease the number of warnings
 


## 2017-11-09
Regular update release.  
Version: 2017-11-10T04-45-04--build-1166--sha-a823a7a3088c9ccddc9cd8707534d449f950aa50   

- Improve syntax highlighting in search field
- A bug has been fixed 🎉 where searching for unicode characters could cause false positives.
- Performance has improved for most usages of regex (we have moved to use `RE2/J` rather than Java's `java.util.regex`.)

Improvements to regular expression matching.

- New syntax `field = /regex/idmg` syntax for matching. Optional flags `i`=ignore case, `m`=multiline (change semantics
  of `$` and `^` to match each line, nut just start/end), `d`=dotall (`.` includes `\n`),
  and `g`=same as `repeat=true` for the `regex()` function.  I.e. to case-insensitively find all log lines containing `err` 
  (or `ERR`, or `Err`) you can now search
  ```
  /err/i
   ```
- When such a regex-match expression appears at top-level e.g. `|` between two bars `|`, then named capturing groups 
  also cause new fields to be added to the output event as for the `regex()` function.
- When no field is named, i.e. as in `/err/i`, then `@rawstring` is being searched.



## 2017-11-06
Regular update release.  
Version: 2017-11-06T11-27-28--build-1129--sha-8e24b956a8aee4bc039a0af8deaa7c07ae4b13bc

Improvements in the query language:

- [Saved queries can be invoked as a macro](/searching_logs/#using-saved-queries-as-macrosfunctions) using the following syntax:  
  `$"name of saved query"()` or `$nameOfSavedQuery()`.    
  Saved queries can declare arguments using `?{arg=defaultValue}` syntax.  
  Such arguments can be used where ever a string, number or identifier is allowed in the language.  
  When calling a saved query, you can specify values for the arguments with a syntax like:  
    `$savedQuery(arg=value, otherArg=otherValue)`.
  
- Support for C-style allow comments `// single line` or `/* multi line */`
- [Anonymous composite functions](/searching_logs/#composite-function-calls) can now make use of filter expressions:  
  ```
    #type=accesslog | groupby(function={ uri=/foo* | count() })
  ```
- New [HTTP ingest API supporting parsers](/sending_logs_to_humio/transport/http_api/#ingest-data-using-a-parser)  

## 2017-11-01
Regular update release.  
Version: 2017-11-01T04-45-03--build-1080--sha-fd1f9174f599a0e7c08374b9327cd1a59795976a

- Event timestamps are set to Humios current time, at ingestion, if they have timestamps in the future.  
Theese events will also be annotate with the fields @error=true and @error_msg='timestamp was set to a value in the future. Setting it to now'.
Events are allowed to be at most 10 seconds into the future, to take into account some clock skew between machines
- Timecharts are redrawn when series are toggled
- Created a public [github repository](https://github.com/humio/provision-humio-cluster) with scripts to support on-premises Humio installation and configuration.
- Fix bug with headline texts animating forever
- Improved handling of server deployments in dashboards


## 2017-10-23
Minor release

- Fixed Session timeout bug when logging in with LDAP
- Fixed Bug in search field when pasting formatted text
- Better support for busting the browsers local cache on new releases  

## 2017-10-17
Regular update release.  
Version: 2017-10-17T11-17-11--build-992--sha-dca8e2536d68838456a1b29580a14c870db2c0e3

- Fixed visual bug in the event distribution graph
- Added time range parameterization to dashboards
- The `in()` function now allow wildcards in it's `values` parameter

## 2017-10-17
Regular update release.

- Added syntax highlighting of the query in the search field.
- Allow resizing the search field.

## 2017-10-13
Minor release

- Fixed bug showing basic authentication dialogue in browser when loging token expires
- Add parameter `cidr(negate=true|false)` flag
- Add ipv6 support to `cidr`
- A system job will now periodically compacts and merges small segment files
  (caused by low volume data sources) improving performance and reducing storage
  requirements.

## 2017-10-11
Regular update release.  
Version: 2017-10-11T10-50-10--build-949--sha-292ff6da98b7ad91687db5fc31eef6033bd6fa86

- Mouse over in timecharts now displays values for all series in hovered bucket

on-premises notes:
- Since using the ingest queue is on by default, if running a clustered setup,
  make sure to update the ingest partition assignments.
  At the very least [reset them to defaults.](/operation/on_prem_http_api/#applying-default-partition-settings)


## 2017-10-10  
Cloud-only release.   

- New query functions: `in`, `length`, `sample` and `lowercase`.
- Ingest queue is used by default (if not disabled)
- Events are highlighted in the eventdistribution graph when they are hovered.
- Possible to migrate dataspaces from one Humio to another.
- Improved Auth0 on-prem support.
- [Heroku Integration](/sending_logs_to_humio/integrations/heroku/).
- Improved query scheduling for dashboards starting many queries at the same time.

## 2017-09-29  
Cloud-only release.  
Version 2017-09-29T12-57-12--build-843--sha-bb28eadf1d792fd9e5da335638e75e4ef49a0847


## 2017-09-06
Regular update release.  

- UI improvements with auto suggest / pop up documentation.
- new function: `shannon_entropy()`
- Fix bug with `Events list` view for aggregate queries

on-premises Humio improvements:

- New LDAP config options adding `AUTHENTICATION_METHOD=ldap-search` for using a bind user.  
- Fix bug with combination of add-cluster-member and real-time-backup-enabled.
- Generic UDP/TCP ingest added (for e.g. syslog). Config with HTTP/JSON API only, no GUI yet.

## 2017-08-30
Regular update release.

- Copy dashboard feature
- Syslog ingestion (Line ingestion) in Beta for on premises installations
- Improve Auth0 dependencies. (Better handling of communication problems)
- Change styling of list widgets


## 2017-08-17
Regular update release.
Version 2017-08-17T19-02-13--build-456--sha-0c37ad1f46977a203dc601f38e845f56b98b22ef

- Fix scrolling in safari for tables (1308)
- Show warning when there are too many points to plot in a timechart and some are discarded (1444)
- Make it possible to show event details, when looking at raw events inside a timechart (1438)


## 2017-08-16

Regular update release.
Version 2017-08-15T21-45-13--build-433--sha-81737edb48fb8c2b15c7e582a6bbbbfb9322b2f2

- Dataspace type ahead filter on frontpage
- Widget options now use radio buttons for many options
- Remember which tab to show in event details drawer (Same as the last one)
- Documentation for cluster management operations
- Ingest request waits for 1 Kafka server to ack the request by default (improves data loss scenarios with machines failing)

## 2017-08-04

Regular update release.
Version 2017-08-04T10-48-49--build-384--sha-86bff41c0f76d24b0338956d8e74b6214a54798f

- New 'server connection indicator' shows that the server is currently reachable from the browser.
- Background tabs are only updated minimally, resulting in much less CPU usage.
- Fixed a bug that would prevent wiping the kafka used to run Humio. (1347, 1408)
- Fix an issue with scrollbars appearing in dashboards. (1403)
- Various minor UI changes.


## 2017-07-09

Cloud-only release.

- When running an aggregate query (such as a `groupby`) the UI now shows a `Events list` 'tab' to see the events that
  were selected as input to the aggregate.
- Fix an issue where login fails and the UI hangs w/auth0. (#1368)
- Improved the update logic for read-only dashboards (#1341)
- Improved rendering performance for dashboards (#1360)

## 2017-06-22

Regular update release.
Version: 2017-06-21T13-43-14--build-251--sha-cb92c034d6f10dbf9eb2f2e7bb9082b24fc26cef

- Support for LDAP authentication for on-premises installations. (#1222)
- For calculations on events containing numbers, the query engine now maintains a higher precision in intermediate
  results.  Previously, numbers were limited to two decimal places, so now smaller numbers can show up in the UI. (#603)
- The `limit` parameter on `table` and `sort` functions now only issues a warning if the system limit is reached, not
  when the explicitly specified limit is reached. (#1323)
- Ingest requests are not rejected with an error, when incomming events contain fields reserved for humio (like @timestamp).
  Instead an @ is prepended to the field name and extra fields are added to the event describing the problem(`@error=true`). (#1320)
- The event distribution graph is not aligned better with graphs shown below.
- Certain long queries could crash the system. (#781)
- Various improvements in the scale-out implementation.  Contact us for more detail if relevant.


## 2017-06-15

Regular update release.  
Version: 2017-06-15T11-47-10--build-195--sha-44c2e1d988f54a6d79fa488a4c56241a0af92977

- While running a query, the UI will now indicate progress 0-100%. (#1262)
- For UI queries (and those using the `queryjob` API) the limit on the result set is lowered to 1500 rows/events.
  This avoids the UI freezing in cases where a very large result set is generated.
  To get more than 1500 results the `query` HTTP endpoint has to be used. (#1281, #960)
- Add parameters `unit` and `buckets` to `timechart()`.  The parameter `buckets` allows users to specify
  a specific number of buckets (maximum 1500) to split the query interval into, as an alternative to the `span` parameter
  which has issues when resizing the query interval.  The `unit` parameter lets you convert rates by e.g.
  passing `unit="bytes/bucket to Mibytes/hour"`.  As the bucket (or span) value changes, the output is converted to the
  given output unit. (#1295)
- Fixed a bug where read-only dashboards allowed dragging/resizing widgets. (#1274)
- In certain cases, live queries producing a warning would add the same warning repeatedly for every poll. (#1255)
- The event details view has been improved in various ways: remember height, new buttons for 'groupby attribute' and 'filter without'. (#1277)
- Humio can optionally use re2j (google's regex implementation), which is slightly slower than
  the default Java version, but avoids some strange corner cases that can sometimes cause
  stackoverflow.  Controlled with `USE_JAVA_REGEX=true|false`.  Defaults to `true`.
- Timecharts with `span=1d` now uses the browser's timezone to determine day boundary. (#1250)

Distributed

- The scale-out implementation is improved in several ways.  Most significantly, functionality
  adding a node to a cluster has been added.  Contact us for more detail if relevant.

## 2017-05-22

Major release includes early access for new multi-host scale-out functionality. See seperate
documentation for how to install and configure these functions.  Version: 2017-05-22T09-12-55--build-44--sha-ea8550e4bfa58f261d26671527af02ba90835586


- Dashboards can now be reconfigured by dragging and resizing widgets (#1205)
- Fixed a bugs with live aggregate queries which could cause results to inflate over time. (#1213)
- Fixed minor bug in parser selection (only used in undocumented tags selection mechanism)
- Fixed a bug with time charts that did not always include the Plotline Y. (#1111)
- For +2 seconds aggregate queries, shuffle order logs are processed.  This lets the
  user get an rough estimate of the nature of the data, which works well for such queries
  using e.g. `avg` or `percentiles` aggregates. (#1227)
- Fixed a bug which made docs not redirect properly for on-prem installations (#1112)
- Dashboards now indicate errors in the underlying queries with an transparent overlay (#775)

## 2017-05-04

Regular update release.  Version: 2017-05-04T13-25-16--build-173--sha-7d189458ba7c9fe5f52a3955a92fac22589a350e

- New flag to `groupby(limit=N)` allows specifying the maximum number of groups (0 up to ∞).  If more than `N` entries
  are present, elements not matching one of the existing are ignored and a warning is issued.
  The system has a hard limit of 20000, which can be removed by the operator by setting the property
  `ALLOW_UNLIMITED_GROUPS=true` in Humio's configuration file (env file for Docker). (#1199)

- Added UI to allow `root` users to set the retention on data spaces (#502)

- Improve scroll behavior in tables on dashboards (#1190)


## 2017-04-27

Regular update release. Version: 2017-04-27T09-55-28--build-159--sha-77ab43ca32047e23076afb22c1b1f0e110f4c8d5

- Fixes for logarithmic scale graphs (#1111)

- Allow configuration for standard search interval other than 24h (#1149)

- Save metadata locally to the file `global-data-snapshot.json` rather than to the Kafka topic `global-snapshots`.
  This file should only be edited while the server is down, and even then with care.  (#1156)

- Dashboard settings have been moved to the dataspace's own page, rather than on the front page (#1125)

- In the event-list view, a toggle has been added to enable line wrapping. (#1121)
