---
title: "Filters"
menu:
  docs:
    parent: "Query Language Reference"
    weight: 30
---

# Filters

Typically the first thing you want to do when searhing is supplying a string and find all events matching the string.
In Humio you can just type in a string - and Humio will find all events containing that string.
When doing a query like this the filter is applied to an events rawstring, which is the the original event as a string.


`foo #find all events matching foo in the events rawstring`
`"foo bar" #find the string "foo bar" - use quotes if string contains whitespaces or special characters`

The above queries have done the filtering on the events rawstring. It is also possible to filter on fields

`url like login #url field contains the string login`  
`url=*login* # * can be used as wildcard - query is the same as the like query above`  
`user = *Turing # user field ends with Turing`  
`user = "Alan Turing" # user field equals Alan Turing`  
`user != "Alan Turing" # user field does not equal Alan Turing`    
`url != *login* # login is not in url field`  
`user=* # find all events having the field user`  
`user!=* #find all events not having the field user`  

Using " inside an already quoted string requires escaping.
`"msg: \"velcome\"" # the quotes (") around velcome are inside other quotes and must be escaped`


Filters can be combined with `and`, `or`, `not` and grouped with parentheses

`foo and user=bar`
`foo bar # Same as foo and bar - whitespace is interpreted as an and expression`
`statuscode=404 and (method=GET or method=POST)`
`foo not bar`
`foo not (bar or baz)`
`foo not statuscode=200 # same as foo and statuscode!=200`


Fields containing numbers can be queried with `< <= = != > >=`
`statuscode >= 400 and statuscode < 500`

When searching with comparison/equality as described above, the
attribute must be before the comparison operator.  Thus

`foo=bar`

means that the attribute `foo` has the value `bar`.  Likewise for numbers,
you cannot write

`200 > statuscode`

as this will be interpreted to mean that the attribute `200` holds a value
which is larger than the string `statuscode`.

## Composing queries

Inspired by the Unix philosophy advanced queries can be built by composing small queries.  
A query pipeline is built by composing queries using pipes.
Events flow through the query pipeline and can be filtered transformed and aggregated

`statuscode != 200 | count() # count the number of statuscodes not equal to 200`


Queries can be built by combining filters and functions. Query Functions are descirbed [here](query-functions.md).  
