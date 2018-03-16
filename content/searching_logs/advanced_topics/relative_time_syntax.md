---
title: "Relative time syntax"
---

In many places in Humio, you must specify a time. For example, when [specifying the time interval for a query](http-api.md#time) or when using the [timechart query function](/query-language/query-functions.md#timechart).

To make specifying a time more flexible, Humio supports a relative time syntax. This lets you express a simple time duration, rather than specifying two absolute times.

You specify a relative time modifier as a number followed by a word. The following table shows which words you can use:

| Time unit     | Possible values |
----------------|-----------------|
Milliseconds    | `millisecond`, `milliseconds`, `millis`, `ms`
Seconds         | `second`, `seconds`, `s`, `sec`, `secs`
Minutes         | `minute`, `minutes`, `m`, `min`
Hours           | `hour`, `hours`, `h`, `hr`, `hrs`
Days            | `day`, `days`, `d`
Weeks           | `week`, `weeks`, `w`
Months          | `month`, `months`, `mon`
Quarters        | `quarter`, `quarters`, `q`, `qtr`, `qtrs`
Years           | `year`, `years`, `y`, `yr`, `yrs`

{{% notice note %}}
You can include a space character between the number and the unit of time.
{{% /notice %}}

## Examples

`2h`

`2 hours`

`3 weeks`

`10s` or `10seconds`
