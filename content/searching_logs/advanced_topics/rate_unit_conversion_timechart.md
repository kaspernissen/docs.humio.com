---
title: "Rate Unit Conversions in timecharts"
---

When displaying a rate (somethings per timeunit) in a timechart, the display is sensitive to the size of the chart's 
`span` or `bucket` parameter, if the thing being graphed is a `sum` (or `count`) of log data.  

You can use `timechart(function=sum(bytes),span=1h)` to show an hourly rate.  
But sometimes you want a rate (say `Kibytes/sec`) for which it does not make sense to create a bucket for each. 
Previously we have sugguested to use a successive `eval()` to reduce the chart inputs, but that's rather cumbersome
and also sensitive to the size of the buckets (the span of each bar in the chart).
Unit conversions to the rescue!  

## When the source-unit is a sum or count

You can convert using a syntax like `timechart(function=sum(bytes), unit="bytes/span to Mi bytes/day")`.  This will make it so that the
conversion takes the timespan into account.  If you use the above with `span=1d` there will be no conversion, 
but if you it with `span=1h`, then the plotted values will be multiplied by 24 (because there are 24hours in a day).
You can use `/span` or `/bucket` interchangeably. 

## When the source-unit is already a rate

You can convert using a syntax like `timechart(..., unit="bytes/sec to Mibytes/day")`.  In this case, the source
is already a rate (i.e. measued in units per time).  With this the conversion is applied independently of the 
length of the span (bucket size) for the graph.

## Expressing rates and units

Units in this system is either a base unit (like events or bytes) or a rate
i.e., a base unit per time unit.  The syntax for a base unit is this:

````
base_unit    ::= Number_opt SIunit_opt unitname_opt
Number_opt   ::= ([0-9]+)?
SIunit_opt   ::= ([KMGP]i?|)
unitname_opt ::= (' '? <string>)?
````

So one example of a base unit is `2Gi bytes`.  
We use the standard SI-units K, M, G, and P to denote 1000-based kilo, mega, 
giga and peta; whereas Ki, Mi, Gi, and Pi designate 1024^n style.  See 
[here](http://physics.nist.gov/cuu/Units/binary.html) for further explanation.

The `unitname_opt` can optinally be 
separated from the SI unit with a single space to be able to differentiate names
unit names starting with an 'i'.


Time units follow the same pattern:

```
time_unit    ::= Number_opt Time
Number_opt   ::= ([0-9]+)?
Time         ::= prefix-of( "seconds, "milliseconds", "minutes", "hours" "days" ) | "ms" | "bucket" | "span"
```

The non-uniq prefixes `m` and `mi` are interpreted as minutees.  "ms" designates milli seconds.

A rate is 

```
Rate ::=   base_unit "/" time_unit
```

Since the entirety of base-unit is optional (a missing base unit is implied to be  _one_), you can convert
from events/second to events/hour with a minimal expression such as:

```
unit="/s to /h"
```

the `to`-side of such a conversion must be a rate, whereas the left hand side
can just be a basic unit, which is interpreted as `unit/bucket`
