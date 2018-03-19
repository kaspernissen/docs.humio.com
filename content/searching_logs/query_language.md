
This section describes the Humio query language.

The Humio query language is the syntax that lets you compose queries to retrieve, process, and analyze business data in your system.

Before reading this section, we recommend that you read the [tutorial](/getting_started/tutorial/). The tutorial introduces you to queries in Humio, and lets you try out some sample queries that demonstrate the basic principles.


## Principles

We built the Humio query language around a 'chain' of data processing commands linked together. Each expression passes its result to the next expression in sequence. In this way, you can create complex queries by combining query expressions together.

This architecture is similar to the idea of [command
pipes](https://en.wikipedia.org/wiki/Pipeline_(Unix)) in Unix and Linux shells. This idea has proven to be a powerful and flexible mechanism for advanced data analysis.

## Basic Query Components

The basic model of a query in Humio is that data arrives at the
left of the query, and the result comes out at the right of the query. When Humio executes the query, it passes the data through from the left to the right.

As the data passes through the query, Humio filters, transforms, and aggregates it according to the query expressions.

For example, the following query has these components:

* Two tag filters
* One filter expression
* Two aggregate expressions

```
 #host=github #parser=json | repo.name=docker/* | groupby(repo.name, function=count()) | sort()

|--------------------------|--------------------|--------------------------------------|----------
        Tag filters        |       Filter       |              Aggregate               | Aggregate
```

{{% notice tip %}}
To chain query expressions, use the 'pipe' character, (`|`), between each of the query expressions.

This causes Humio to pass the output from one expression into the next expression.
{{% /notice %}}

## Tag filters

Tag filters always start with a `#` character. They behave in the same way as regular [attribute filters](#attribute-filters).

In the example shown in the previous section ([Basic Query Components](#basic-query-components)),
we have separated the tag filters from the rest of the query by a pipe character (`|`).

We recommend that you include the pipe character before tag filters in your queries to improve the readability of your queries.

However, these pipe characters are not mandatory. The Humio query engine can recognize tag filters
when they are at the front of the query, and use this information to narrow down the number of data sources to search. This feature decreases query time.

For more information on tags, see the [glossary](/glossary/#tags) page.


## Rawstring filters

The most basic query in Humio is to search for a particular string in the `@rawstring` attribute of events.  See [glossary](/glossary/#events) for more details on `@rawstring`.

{{% notice note %}}
You can perform more complex regular expression searches on the `@rawstring` attribute of an event by using the [regex](/searching_logs/query_functions/#regex) function.
{{% /notice %}}


### Examples

| Query | Description |
|-------|-------------|
| `foo` | Find all events matching "foo" in the `@rawstring` attribute of the events |
| `"foo bar"` | Use quotes if the search string contains white spaces or special characters, or is a keyword. |
| `"msg: \"welcome\""` | You can include quotes in the search string by escaping them with backslashes. |

You can also use a regular expression to match rawstrings.  To do this, just
write the regex.

| Query | Description |
|-------|-------------|
| `/foo/` | Find all events matching "foo" in the `@rawstring` attribute of the events |
| `/foo/i` | Find all events matching "foo" in the `@rawstring`, ignoring case |


## Attribute Filters

Besides the `@rawstring`, you can also query event attributes, both as
text and as numbers.


### Examples

**Text fields**

| Query | Description |
|-------|-------------|
|`url = *login*` | The `url` field contains `login`. You can use `*` as a wild card. |
|`user = *Turing` | The `user` field ends with `Turing`.
|`user = "Alan Turing"` | The `user` field equals `Alan Turing`.
|`user != "Alan Turing"` | The `user` field does not equal `Alan Turing`.
|`url != *login*` | The `url` field does not contain `login`.
|`user = *` | Find all events that have the field `user`.
|`user != *` | Find all events that do not have the field `user`.
|`user="Alan Turing"` | You do not need to put spaces around operators (for example, `=` or `!=`).

**Regex filters**

In addition to globbing (`*` appearing in match strings) you can match fields using regular expressions.

| Query | Description |
|-------|-------------|
|`url = /login/` | The `url` field contains `login`. 
|`user = /Turing$/` | The `user` field ends with `Turing`.
|`loglevel = /error/i` | The `loglevel` field matches `error` case insensitively, i.e. it could be `Error`, `ERROR` or `error`. 


**Comparison operators on numbers**

| Query | Description |
|-------|-------------|
| `statuscode < 400` | Less than|
| `statuscode <= 400` | Less than or equal to |
| `statuscode = 400` | Equal to |
| `statuscode != 400` | Not equal to |
| `statuscode >= 400` | Greater than or equal to|
| `statuscode > 400` | Greater than|
| `400 = statuscode` | (!) The attribute '400' is equal to `statuscode`.|
| `400 > statuscode` | This comparison generates an error. You can only perform a comparison between numbers. In this example, `statuscode` is not a number, and `400` is the name of an attribute.|



{{% notice note %}}
The left-hand-side of the operator is interpreted an attribute name. If you write `200 = statuscode`, Humio tries to find an attribute named `200` and test if its value is `"statuscode"`.
{{% /notice %}}

{{% notice warning %}}
If the specified attribute is not present in an event, then the comparison always fails.
You can use this behavior to match events that do not have a given field, using either `not (foo=*)` or the equivalent `foo!=*` to find events that do not have the attribute `foo`.
{{% /notice %}}

<!-- TODO: State explicitly which comparison operators will yield positive for missing attributes, and which ones won't. Especially: "!=" -->

## Combining Filter Expressions

You can combine filters using the `and`, `or`, `not` Boolean operators, and group them with parentheses.

### Examples

| Query | Description |
|-------|-------------|
| `foo and user=bar` | Match events with `foo` in the`@rawstring` attribute and a `user` attribute matching `bar`. |
| `foo bar` | Since the `and` operator is implicit, you do not need to include it in this simple type of query.
| `statuscode=404 and (method=GET or method=POST)` | Match events with `404` in their `statuscode` attribute, and *either* `GET` or `POST` in their `method` attribute. |
| `foo not bar`| This query is equivalent to the query `foo and (not bar)`.|
| `not foo bar`| This query is equivalent to the query `(not foo) and bar`. This is because the `not` operator has a higher priority than `and` and `or`.|
| `foo and not bar or baz` | This query is equivalent to the query `foo and ((not bar) or baz)`. This is because Humio has a defined order of precedence for operators. It evaluates operators from the left to the right. |
| `foo or not bar and baz` | This query is equivalent to the query `foo or ((not bar) and baz)`. This is because Humio has a defined order of precedence for operators. It evaluates operators from the left to the right. |
| `foo not statuscode=200` | This query is equivalent to the query `foo and statuscode!=200`.



## Composing queries

You can build advanced queries can by combining small queries using pipes.

Together, these small queries form a query pipeline.

Humio introduces events into each query pipeline, and filters, transforms, and aggregates the data as appropriate.

The following example shows a typical query pipeline:

| Query | Description |
|-------|-------------|
| <code>statuscode != 200 &#124; count()</code> | Count the number of `statuscode` values that are not equal to `200`. |

<!-- ^^ Workaround to get pipe-in-code-in-table. -->


{{% notice note %}}
Queries can be built by combining filters and functions. You can find out more about [Query Functions](/searching_logs/query_functions/).
{{% /notice %}}


## Extracting new attributes

You can extract new attributes from your text data using regular expressions and then test their values. This lets you access data that Humio did not parse when it indexed the data.

For example, if your log entries contain text such as
`"... disk_free=2000 ..."`, then you can use a query like the following
to find the entries that have less than 1000 free disk space:

`regex("disk_free=(?<space>[0-9]+)") | space < 1000`

{{% notice tip %}}
Since regular expressions do need some computing power, it is best to do as much simple filtering as possible earlier in the query chain before applying the regex function.
{{% /notice %}}

You can also use regex expressions to extract new fields. So the above could also 
be written

```
/disk_free=(?<space>[0-9]+)/ | space < 1000
```

In order to use field-extraction this way, the regex expression must be
a "top-level" expression, i.e. `|` between bars `|` i.e., the following doesn't work:

```
type=FOO or /disk_free=(?<space>[0-9]+)/ | space < 1000
```

## Assigning new attributes from functions

Attributes can also get a value as the output of many functions.
Most functions set their result in a field that has the function name prefixed qith a "_" as name by default. E.g. the "count" function outputs to "_count" by default.
The name of the target field can be set using the parameter "as" on most functions. E.g. "count(as=cnt)" assigns the result of the count to the field named "cnt"

### Eval syntax

The function [eval](/searching_logs/query_functions/#eval) can assign fields while doing numeric computations on the input.

The ":=" syntax is short for eval. Use "|" between assignments.

```
... | foo := a + b | bar := a / b |  ...
```

is short for

```
... | eval(foo = a + b) | eval(bar = a / b) | ...
```

### Backticks (`)
Backticks work in `eval` and the `:=` shorthand for eval only and provides one level of indirection of the name of the field.
The assignment happens to the field with the name that is the value of the backticked field.

An example on events with the following fields, which is e.g. the outcome of `top(key)`.:
```
  { key="foo", value="2" }
  { key="bar", value="3" }
  ...
```
Using
```
  ... | `key`:=value | ...
```
will get you events with
```
  { key="foo", value="2", foo="2" }
  { key="bar", value="3", bar="3" }
  ...
```

Then you can time chart them by doing

```
    timechart( function={ top(key) | `key` := _count } )
```

<!-- TODO:  But maybe we should have an alternative function to do the transpose, such as `transpose([key,value])` which takes a `Seq[{ key=k, value=v }]` and turns it onto a single event, with `{ k1=v1, k2=v2, ... }`. -->

## Conditional / Alternate Function Calls
There is no direct "if-then-else" syntax in humio, as the "streaming events" style is not well-suited for procedural-style conditions.
But there are several ways to accomplish conditional evaluation

### Using side-effects
Often you just want a default value for a field that some events may be missing.
You can achieve this by using the fact that a function that assign an attribute (such as `eval`) only assigns the field if the input fields exists.
You can thus set a default value if some other value is not present. Here we set `foo` to `missing` if there is no `bar` field, and otherwise set `foo` to the value of the `bar` field.
```
... | eval(foo="missing") | eval(foo=bar) | ..."
```

### Using `alt`

`alt` describes alternative flows (as in `case` or `cond`).  You write a sequence (`;` separated) of pipe lines, and the first of these to emit a value ends the selection.  You can add `alt { ... ; * }` to let all events through.

In effect, it is kind of an if-then-if-then-else construct for events streams.  An alternative cannot be syntactically empty, you must put in an explicit `*` to match all.

An example: We have logs from multiple sources that all have a "time" field, and we want to get percentiles of the time fields, but one for each kind of source.
To distinguish the lines, we need to match a text, then set a field ("type") that we can then group by.
```
time=*
| alt { "client-side" | type:="client";
        "frontend-server" | type:="frontend";
        Database | type:="db" }
| groupby(type, function=percentile(time)))
```

## Composite Function Calls

See [Query Functions](/searching_logs/query_functions/).

Whenever a function accepts a function as an argument, there are some
special rules.  For all variations of groupby (bucket and timechart), that
take a `function=` argument, you can also use a composite function.
Composite functions take the form `{ f1(..) | f2(..) }` which works
like the composition of `f1` and `f2`.  For example, you can do
`groupby(type, function={ avg(foo,as=avgFoo) | round(avgFoo,as=outFoo) })`

You can also use filters inside such composite function calls, but not
macros.


## Using Saved Queries as macros/functions

If you have stored a query as a 'saved query', then it can be used as a top-level
element of another query, sort of like a function call.

To use a saved query this way, you invoke it using the syntax `$"name of saved query"()`
or, if the name of the saved query is an identifier, you can use `$nameOfSavedQuery()`,
plain and simple.  A typical use for this is to define a filter or
extraction ruleset, that you can use as a prefix of another query.

Currently macros do not support parameters, though this will be part of a future
release - that is why we put parentheses at the end.

### Example

```
$"saved query name"() | $filterOutFalsePositive() | ...
```

<!---
Saved queries can also have arguments.  These are identified as 
`?{arg="foo"}` which gives the query parameter `arg` the default value `foo`.
Arguments can be used anywhere a string, number or identifier is allowed.

Now, when you invoke a saved query as a macro, you can pass new values for the
arguments.  You do this like this:

```
$"saved query name"(arg1=value, arg2=value, ...) | ...
```

or the more programming-language like:

```
$SavedQueryName(arg1=value, arg2=value, ...) | ...
```
-->

## Comments

Queries can have comments.  This is useful for long multi-line queries,
to add some description:

```java
#type=accesslog   // choose the type
| groupby(url)    // count urls
| sort(limit=20)  // choose the most frequently used

```

The Humio query language supports `// single line` and `/* multi line */`
comments just like Java or C++.
