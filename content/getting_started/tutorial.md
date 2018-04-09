---
title: "Tutorial"
weight: 4
---

## Overview

Humio can deal with lots of different types of data, and present it in useful and easy to understand ways such as lists, tables, and charts.

To help you understand how Humio works with a large dataset, this tutorial shows you how to query and analyze the [GitHub
Activity data stream](https://developer.github.com/v3/activity/events/) using the [Humio demo site](https://demo.humio.com/).

You will learn:

* How to navigate the GitHub dataset to determine the names of the most frequent commenters in a project namespace
* How to manipulate and query the dataset using filters, field queries, functions, and pipes
* How to present useful information in a table or chart.

## 1. Getting started

We've set up the [Humio demo site](https://demo.humio.com/) for you, so all you need is:

* A web browser
* A [GitHub account](https://github.com/join) or [Google account](https://accounts.google.com/SignUp).

To access the data, log in to the [Humio demo site](https://demo.humio.com/) using either your GitHub or Google account.

After you have logged in to Humio, you can see the GitHub Data Space:

![Data Spaces](/images/data-spaces.png)

Click the GitHub Data Space to view it.

{{% notice note %}}
You can read more about Data Spaces and users in the [glossary](/glossary/) page.
{{% /notice %}}


## 2. Navigating the Search page

After choosing a Data Space, you see the Humio Search page.

The Search page is where you explore your data. You can enter queries and run them to show the results.

The following screenshot shows the main parts of the page:

![GitHub Main](/images/github-main.png)


## 3. Making your first query

The simplest query you can write is an empty query.

To run the query, simply hit `ENTER` in the _Search Bar_, or click the _Search Button_.

> [Click here to try an empty query](https://demo.humio.com/github/search?live=false&start=1day)

This query searches the entire data space for all events the last 24
hours. Humio only shows you the 200 most recent events.

The following screenshot shows example results for this query:

![An Empty Query](/images/github-main_not-annotated.png)


{{% notice note %}}
***The Event Distribution Graph***

Humio also provides an overview of all events that happened during the search interval in the _Event Distribution Graph_.

The _Event Distribution Graph_ is an important part in narrowing down your queries. You can use it to look for event patterns, or to 'sanity check' your queries. For example, you could check that a query returns the expected number of events.
{{% /notice %}}

Now, let's take a look at what data our query found. You can get the details of each item in the _Event List_ by clicking it. This shows the entire content of the event, as well as the fields that
Humio has parsed, in a detail view at the bottom of the screen.

You can find more about input Parsers [here](/sending_logs_to_humio/parsers/parsing/).
<!-- GRW: The link above does not work. -->


{{% notice note %}}
***Data format***

GitHub uses a JSON format for its event data.  Note that the [data model](https://developer.github.com/v3/activity/events/types/) for the GitHub events is outside the scope of this guide.
{{% /notice %}}

## 4. Narrowing down your query

You can build a query in  Humio by combining small, but powerful, parts that each perform a part of the query. We love the Unix pipes philosophy, and you can create a query in Humio by combining filters and functions using pipes:

* Filters
* Functions
* Pipes

You will use these elements to transform, select, or process data.

So let's start making our GitHub query a bit more sophisticated.


### 4.1 Adding a Filter

Filtering is the most common operation in Humio. It lets you narrow your search so that you get only the data you want.

To try this out, enter the string `gravatar` into the search bar and click the search button.

This query checks all GitHub events finds any event containing the string `gravatar`. By default, the time span is set to the last 24 hours.

> [`gravatar` - Click here to try this query ](https://demo.humio.com/github/search?live=false&query=gravatar&start=1day)

The following screenshot shows example results for this query:

![A simple query for the search term 'gravatar'](/images/github-search-filter-gravatar.png)

{{% notice note %}}
***Data types and fields in results***

The search query `gravatar` is present as a substring of one or more of the JSON key names in each result, for example, `gravatar_id`.

These matches show that Humio searched the data source as it would search plain text.

You can also search JSON in a structured way.
<!-- GRW: Need to add a reference, link, or pointer to this content -->
{{% /notice %}}

<!---

## Using wildcards in filters

You can add a "*" to the front or end of a query word, such as:

> [gravatar*](https://demo.humio.com/github/search?live=false&query=gravatar*&start=1day) or [*gravatar](https://demo.humio.com/github/search?live=false&query=*gravatar&start=1day)

In the basic filter you can only add "*" to the ends, but the function
[regex](/searching_logs/query_functions/#regex) enables you to make full regular expression
searches such as this:

> [regex("gr.*tar")](https://demo.humio.com/github/search?live=false&query=regex("gr.*tar")&start=1day)

More on functions further down the guide.
-->


<!--### Using keywords: and, or, not

The query language that Humio uses has 3 keywords:

* `and`
* `or`
* `not`

You can combine these keywords in filter expressions in a similar way to  Boolean expressions in programming languages.

For example, the following search finds all events that contain "foo", "bar", and "baz":

> [`foo and bar and baz` - Click here to try this query](https://demo.humio.com/github/search?live=false&query=foo%20and%20bar%20and%20baz&start=1day)


{{% notice note %}}
***Implicit `and`***

When you use two terms after each other in a query, Humio automatically inserts a 'hidden' `and` keyword. This means that the last query is identical to the following query:

[`foo bar baz` - Click here to try this query](https://demo.humio.com/github/search?live=false&query=foo%20bar%20baz&start=1day)
{{% /notice %}}

Here are some more examples:

> [`foo (bar or baz)` - Click here to try this query](https://demo.humio.com/github/search?live=false&query=foo%20(bar%20or%20baz)&start=1day)

> [`foo bar not baz` - Click here to try this query](https://demo.humio.com/github/search?live=false&query=foo%20bar%20not%20baz&start=1day)

> [`(foo bar) or (foo baz)` - Click here to try this query](https://demo.humio.com/github/search?live=false&query=(foo%20bar)%20or%20(foo%20baz)&start=1day)

-->

### 4.2 Filtering on fields in events

You can use the structure of each event in queries.

This means that you can use the structure of each JSON entry in the Humio Data Space to narrow down your query to particular fields.

{{% notice note %}}
For example, the following query finds all events related to the main GitHub repository for the [`Docker project`](https://github.com/docker/docker):

> [`repo.name=docker/docker` - Click here to try this query](https://demo.humio.com/github/search?live=false&query=repo.name%3Ddocker%2Fdocker&start=1day)

You can also use the wildcard character ("*") in structured Event Field queries.

For example, the following query finds events related to any repository under the `docker` namespace:

> [`repo.name=docker/*` - Click here to try this query](https://demo.humio.com/github/search?live=false&query=repo.name%3Ddocker%2F*&start=1day)

The following query finds events related to any repository named `docker` under any namespace:

[`repo.name=*/docker` - Click here to try this query](https://demo.humio.com/github/search?live=false&query=repo.name%3D*%2Fdocker&start=1day)
{{% /notice %}}

Let's use this knowledge to restrict our query to return only events under the `jenkinsci` namespace in GitHub.

Enter the following search query into the search bar, then click the search button:

> `repo.name=jenkinsci/*`

The following screenshot shows example results for this query:

![A query for events with `repo.name` set to `jenkinsci/*`](/images/github-filter-jenkinsci-all.png)

We now have the base structure of our query in place. The result set contains only information from the target namespace.

In the next steps, we'll use advanced features to restrict it to the events we are interested in.

<!-- GRW: migrate the paragraph below somewhere else, and rewrite it -->
<!-- (In fact simple query terms like 'foo' above, are simply translated into `@rawstring=*foo*`, i.e., the string foo appears anywhere in the special attribute `@rawstring` which is the raw event as originally received). -->

### 4.3 Adding Functions

Humio also contains a number of query functions that you can use to add logic to your queries.

We will use them to build up the logic required to figure out the most active users, return their identifiers, and sort the data appropriately.

For a detailed description of all the functions, please see the [reference guide](/searching_logs/query_functions/).


{{% notice note %}}
Functions come in two categories:

* **Transformation functions**
<br/>
An example of a transformation function is the [regex](/searching_logs/query_functions/#regex) function.  [regex](/searching_logs/query_functions/#regex) can do two kinds of transformations: pure filtering of events, or extraction of new fields using capture groups:
<br/>
<br/>
The following example query extracts dates in 2016 and adds the `mydate` field to all events.
> [`regex("2016-(?<mydate\>\\\\d\\\\d-\\\\d\\\\d)")` - Click here to try this query](https://demo.humio.com/github/search?live=false&query=regex%28%222016-%28%3F%3Cmydate%3E%5C%5Cd%5C%5Cd-%5C%5Cd%5C%5Cd%29%22%29&start=1day)
<br />
<br />
Note that a general introduction to regular expressions is outside the scope of this guide.

* **Aggregate functions**
<br />
An example of an aggregate function is [groupby](/searching_logs/query_functions/#groupby). This function groups events by the value of a field, then applies a function to each group. By default, it counts the number of events in each group.
<br />
<br />
The following example query shows you all the event types for the last 24 hours, along with the count of each type:
> [`groupby(type, function=count())` - Click here to try this query](https://demo.humio.com/github/search?live=false&query=groupby(type%2C%20function%3Dcount%28%29)&start=1day)

{{% /notice %}}
We now know how to insert functions into our search query. But we need to join the functions together to obtain a useful result. In the next section, you'll learn how to use pipes to do this.

### 4.4 Adding Pipes

You can group several query expressions together into a 'pipe' that runs them one after another, passing the result to the next expression each time. This is similar to the idea of pipes in Unix and Linux shells.

To chain query expressions, use the 'pipe' character, "|", between each of the query expressions.

{{% notice note %}}
***Example: Total count of activity***

In this query, we count the total number of events after a certain point in time:

> [`created_at=\*T07:00\*  | groupby(repo.name) | count()` - Click here to try this query](https://demo.humio.com/github/search?live=false&query=created_at%3D*T07:00*%20%7C%20groupby(repo.name)%20%7C%20count()&start=1day)

This query does these actions in sequence:

1. Finds all events from the first minute after 7:00 AM
2. Groups the events by the `repo.name` field using the `groupby()` function. This function transforms the result into a table with one column: `_count`.
3. Counts the number of events using the `count()` function.

**Example: Sort by group**

In this example, we filter for events related to repositories in the `docker` namespace, group them by the number of events in each repository, and then sort the result by the number of events. This provides an indication of the overall popularity of each repository.

> [`repo.name=docker/* | groupby(repo.name) | sort()` - Click here to try this query](https://demo.humio.com/github/search?live=false&query=repo.name%3Ddocker%2F*%20%7C%20groupby(repo.name)%20%7C%20sort()&start=1day)

This query does these actions in sequence:

1. Finds all events related to repositories in the Docker organization
2. Groups the events by the `repo.name` field using the `groupby()` function. This function transforms the result into a table with two columns: `_count` and `repo.name`.
3. Sorts the table using the `sort()` function. The [sort](/searching_logs/query_functions/#sort) function sorts by the `_count` field by default and will put the repository with the most activity at the top.
{{% /notice %}}



Let's use this knowledge to determine the top issue commenters. Enter the following query into the search box, then click the search button:

> <a href="https://demo.humio.com/github/search?widgetType=table-view&query=repo.name%3Djenkinsci%2F*%20%7C%20type%3DIssueCommentEvent%20%7C%20groupby(field%3Dactor.login%2C%20function%3Dcount())%20%7C%20sort(field%3D_count%2C%20limit%3D5)&live=false&start=1d">`repo.name=jenkinsci/* | type=IssueCommentEvent | groupby(field=actor.login, function=count()) | sort(field=_count, limit=5)` - Click here to try this query</a>

The following screenshot shows example results for this query:

![A query including pipes, showing the top issue commenters in a repository group in a summary table.`](/images/github-pipe-top-issuecomment.png)

The query does these actions in sequence:

1. Finds all events related to repositories in the Docker organization that are of the type `IssueCommentEvent`
2. Groups the events by the `actor.login` field using the `groupby()` function. This function transforms the result into a table with two columns: `_count` and `actor.login`.
3. Sorts the table using the `sort()` function. This provides an indication of the users who added the highest number of comments.


## 5. Creating a Chart

The knowledge you have gained in the previous section gives you a powerful set of tools to help analyze data. However, it is also useful to present this information in a visual way.

**Example: Pie chart showing the top five committers**

In this example, Humio finds the _Top 5 Commenters_ for all Jenkins repositories and displays them using a pie chart:

> [`repo.name=jenkinsci/* | type=IssueCommentEvent | groupby(field=actor.login, function=count()) | sort(field=_count, limit=5)` - Click here to try this query](https://demo.humio.com/github/search?live=false&query=repo.name%3Djenkinsci%2F*%20%7C%20type%3DIssueCommentEvent%20%7C%20groupby%28field%3Dactor.login%2C%20function%3Dcount%28%29%29%20%7C%20sort%28field%3D_count%2C%20limit%3D5%29&start=1day&widgetType=pie-chart)

The following screenshot shows an example chart for this query:

![A pie chart showing the top 5 commenters in a repository group.`](/images/github-top-committers-pie-chart.png)

<!-- GRW: The section below needs further work. -->
<!-- **Default parameters in functions**

The statement the `sort(_count, limit=5)` above shows two concepts involved
in calling functions. The first parameter is `_count`.
When a parameter is passed without writing it like `parameterName = value` we call it the default parameter.
 Most functions have a default parameter, e.g. when we write `groupby(actor.login)`, we might as well have written
`groupby(field=actor.login)`, but since `field` is the default parameter for `groupby()` we don't have to.

 We are also passing a parameter `limit=5` to `sort()`.
It is saying that the function should take the 5 records
with the highest value of the field `_count`. In this case
we could actually exclude the parameter `field` since `_count` is its default value, so you don't have to pass it. Knowing this we could write the previous query as:

 [`repo.name=jenkinsci/* | type=IssueCommentEvent | groupby(actor.login) | sort(limit=5)` - Click here to try this query](https://demo.humio.com/github/search?live=false&query=repo.name%3Djenkinsci%2F*%20%7C%20type%3DIssueCommentEvent%20%7C%20groupby(actor.login)%20%7C%20sort(limit%3D5)&start=1day&widgetType=pie-chart)

 and it would produce the same result.

 To create a Table or Bar Chart, use the
`View Selector` in the top left corner above the search
field to select another presentation type.

-->

**Example: Timechart showing commits in multiple repositories**

In this example, we compare the levels of activity in GitHub of the `docker` and the `akka` repositories. Humio graphs the results by the hour for the last day:

[`repo.name="docker/docker" or repo.name=akka/akka | timechart(repo.name, span=1h)` - Click here to try this query](https://demo.humio.com/github/search?live=false&query=repo.name%3D%22docker%2Fdocker%22%20or%20repo.name%3Dakka%2Fakka%20%7C%20timechart(repo.name%2C%20span%3D1h)&start=1day)

The following screenshot shows an example chart for this query:

![A timechart showing commits in multiple repositories.`](/images/github-multi-repo-time-chart.png)

You can read more about the timechart function in the [docs](/searching_logs/query_functions/#timechart).


## 6. Running Live Queries

In Humio, you always search over a time interval. The default is the
last 24 hours.

You choose your time interval using the _Time Selector_ dialog:

![Time Selector](/images/time-selector.png)

The dialog presents a set of preset intervals, custom _fixed intervals_
and custom _time windows_.  The presets have both _fixed date ranges_ and
_time windows_.

### Fixed Date Ranges

A _fixed date range_ runs from a _start date_ to and _end date_.



An often used _end date_ is _now_, which means _this
very second_. All the example queries above use this _end date_.


### Time Windows

_Time windows_ define live queries in Humio. A _live
query_ is a query that analyzes events as the occur in real-time.

A _time window_ is always relative to _now_. You can apply it to any query or chart in Humio.

**Example: all events:**

The following query lists all GitHub events from the last five minutes:

> [`_empty search_`- Click here to try this query](https://demo.humio.com/github/search?live=true&start=5minutes)

In the _event distribution bar_, you can see the events as
they progress through the _time window_. Humio displays the last 200 events in the _event list_ as they occur.

**Example: number of events per second**

The following query shows a *live* time chart showing the number of _events per second_ for the last five minutes.

> [`timechart(span=1s)` - Click here to try this query](https://demo.humio.com/github/search?live=true&query=timechart(span%3D1s)&start=5minutes)

**Example: Live pie chart of most watched repositories**

The following query shows a *live* pie chart of the most watched repositories in the last five minutes.

> [`type=WatchEvent | groupby(repo.name) | sort(limit=5)` - Click here to try this query](https://demo.humio.com/github/search?live=true&query=type%3DWatchEvent%20%7C%20groupby(repo.name)%20%7C%20sort(limit%3D5)&start=5minutes&widgetType=pie-chart)

<!--
Comparing Humio to Other Software
---------------------------------

First thing you should do is to consider whether or not Humio is the _Right Tool for the Job ®_.
To do that you should understand what it is and what it isn't.

The biggest strength of Humio is that it has been built for returning real-time
results from the ground up. By real-time we mean that you can start a search and
keep it running forever. Any new events that enter the system and that match the
search query, will be streamed to the listeners. Other products can do this as
well, but Humio can run thousands of them - simultaneously and with little overhead!

But let's take a step back and discuss what problems Humio actually solves
and try to describe what makes Humio different then comparable solutions like
ElasticSearch.

## ElasticSearch (ELK Stack)
## Splunk
## Hadoop

Saved Queries
-------------

Dashboards
----------

User Management
---------------
-->

## Next Steps

We hope you've found this tutorial useful and rewarding. We've given you some pointers on how to work with Humio, and you should now have some experience with writing queries.

However, this tutorial has only scratched the surface of what Humio can do. If you want to learn more, then the best way to continue your learning is to read the rest of the documentation.

We suggest reading:

* The [Glossary Section](/glossary/)
* The [Query Language Reference](/searching_logs/)
* The [Query Functions](/searching_logs/query_functions/) reference documentation.

** _Thanks, and have fun!_ **
