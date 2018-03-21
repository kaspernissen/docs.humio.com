---
title: "Query functions"
---
Query functions are specified using a name followed by brackets containing parameters. Parameters are supplied as named parameters

```
sum(field=bytes_send) # calculate the sum of the field bytes_send
```

Functions are allowed to have one `unnamed parameter`. The sum function accepts the field parameter as unnamed parameter and can be written as `sum(bytessend)`.

A function is either a `transformation function` or an `aggregate function` Transformation functions can filter events and add or remove fields. Aggregate functions aggregates events into a new set of events. Often they aggregate the events into just one result. For example function `count()` returns one event with one field `_count`.

Each query function is described below:

{{% queryfunctions %}}