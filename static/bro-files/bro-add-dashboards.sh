#!/bin/bash

TOKEN=none
DATASPACE=bro
HOST=http://localhost:8080

curl -0 -v "$HOST/api/v1/dataspaces/$DATASPACE/dashboards/" \
-H 'Content-Type: application/json; charset=utf-8' \
-H "Authorization: Bearer $TOKEN" \
-d @- << EOF
{
  "name": "Bro-conn",
  "widgets": [
    {
      "id": "c5998940-6b59-44cb-9030-29bfcfb713a0",
      "title": "Top Services",
      "options": {
        "x": 0,
        "y": 0,
        "height": 4,
        "visualisation": {
          "widgetType": "pie-chart"
        },
        "width": 6
      },
      "query": {
        "queryString": "#path=conn | groupby(service)",
        "end": "now",
        "showQueryEventDistribution": false,
        "isLive": true,
        "start": "24h",
        "timeZoneOffsetMinutes": 60
      }
    },
    {
      "id": "7e44fce2-9f7f-47e3-b5ba-c45cbdffe789",
      "title": "Top destination ports",
      "options": {
        "x": 0,
        "y": 4,
        "height": 4,
        "visualisation": {
          "widgetType": "pie-chart"
        },
        "width": 6
      },
      "query": {
        "queryString": "#path=conn | groupby(id.resp_p, function=count()) | sort(_count, limit=10)",
        "end": "now",
        "showQueryEventDistribution": false,
        "isLive": true,
        "start": "24h",
        "timeZoneOffsetMinutes": 60
      }
    },
    {
      "id": "8e74ff5e-a7b1-41c0-aa8d-227333fd2e21",
      "title": "Traffic by service",
      "options": {
        "x": 6,
        "y": 0,
        "height": 4,
        "visualisation": {
          "s": "",
          "plY": "",
          "stp": "y",
          "sc": "lin",
          "mx": "",
          "widgetType": "time-chart",
          "legend": "y",
          "lx": "",
          "p": "a",
          "ly": "",
          "mn": "",
          "pl": "",
          "op": "0.2"
        },
        "width": 6
      },
      "query": {
        "queryString": "#path=conn | timechart(service, function=sum(resp_bytes), unit=\"b/s\")",
        "end": "now",
        "showQueryEventDistribution": false,
        "isLive": true,
        "start": "24h",
        "timeZoneOffsetMinutes": 60
      }
    },
    {
      "id": "c08488fa-a6b9-4fe7-abf8-a59996cda2d3",
      "title": "Top ports by traffic",
      "options": {
        "x": 6,
        "y": 4,
        "height": 4,
        "visualisation": {
          "s": "",
          "plY": "",
          "stp": "y",
          "sc": "lin",
          "mx": "",
          "widgetType": "time-chart",
          "legend": "y",
          "lx": "",
          "p": "a",
          "ly": "",
          "mn": "",
          "pl": "",
          "op": "0.2"
        },
        "width": 6
      },
      "query": {
        "queryString": "#path=conn | timechart(id.resp_p, function=sum(resp_bytes), unit=\"B/s\", limit=10)",
        "end": "now",
        "showQueryEventDistribution": false,
        "isLive": true,
        "start": "24h",
        "timeZoneOffsetMinutes": 60
      }
    },
    {
      "id": "2e206d7a-a636-4a14-bf33-dbc036b160ea",
      "title": "Top IP by traffic",
      "options": {
        "x": 6,
        "y": 8,
        "height": 4,
        "visualisation": {
          "s": "",
          "plY": "",
          "stp": "y",
          "sc": "lin",
          "mx": "",
          "widgetType": "time-chart",
          "legend": "y",
          "lx": "",
          "p": "a",
          "ly": "",
          "mn": "",
          "pl": "",
          "op": "0.2"
        },
        "width": 6
      },
      "query": {
        "queryString": "#path=conn | timechart(id.orig_h, function=sum(resp_bytes), unit=\"B/s\", limit=10)",
        "end": "now",
        "showQueryEventDistribution": false,
        "isLive": true,
        "start": "24h",
        "timeZoneOffsetMinutes": 60
      }
    },
    {
      "id": "93e0f3c0-807f-493a-a960-2a0759101937",
      "title": "Top IP",
      "options": {
        "x": 0,
        "y": 8,
        "height": 4,
        "visualisation": {
          "widgetType": "bar-chart"
        },
        "width": 6
      },
      "query": {
        "queryString": "#path=conn | groupby(id.orig_h, function=count()) | sort(_count, limit=10)",
        "end": "now",
        "showQueryEventDistribution": false,
        "isLive": true,
        "start": "24h",
        "timeZoneOffsetMinutes": 60
      }
    }
  ]
}
EOF

curl -0 -v "$HOST/api/v1/dataspaces/$DATASPACE/dashboards/" \
-H 'Content-Type: application/json; charset=utf-8' \
-H "Authorization: Bearer $TOKEN" \
-d @- << EOF
{
  "name": "Bro-http",
  "widgets": [
    {
      "id": "0b412c6f-3684-4696-af1d-694711f25d5d",
      "title": "HTTP errors",
      "options": {
        "x": 0,
        "y": 0,
        "height": 4,
        "visualisation": {
          "widgetType": "pie-chart"
        },
        "width": 6
      },
      "query": {
        "queryString": "#path=http | status_code>=400 | groupby(status_code) ",
        "end": "now",
        "showQueryEventDistribution": false,
        "isLive": true,
        "start": "24h",
        "timeZoneOffsetMinutes": 60
      }
    },
    {
      "id": "02eec787-4876-47ff-a439-daaedec5d497",
      "title": "HTTP errors over time",
      "options": {
        "x": 6,
        "y": 0,
        "height": 4,
        "visualisation": {
          "s": "",
          "plY": "",
          "stp": "y",
          "sc": "lin",
          "mx": "",
          "widgetType": "time-chart",
          "legend": "y",
          "lx": "",
          "p": "a",
          "ly": "",
          "mn": "",
          "pl": "",
          "op": "0.2"
        },
        "width": 6
      },
      "query": {
        "queryString": "#path=http | status_code>=400 | timechart(status_code, unit=\"1/min\")",
        "end": "now",
        "showQueryEventDistribution": false,
        "isLive": true,
        "start": "24h",
        "timeZoneOffsetMinutes": 60
      }
    },
    {
      "id": "90b50b2c-f897-4646-8745-76bbd3c42ac2",
      "title": "Http traffic - bytes per second",
      "options": {
        "x": 0,
        "y": 4,
        "height": 4,
        "visualisation": {
          "s": "",
          "plY": "",
          "stp": "y",
          "sc": "lin",
          "mx": "",
          "widgetType": "time-chart",
          "legend": "y",
          "lx": "",
          "p": "a",
          "ly": "",
          "mn": "",
          "pl": "",
          "op": "0.2"
        },
        "width": 6
      },
      "query": {
        "queryString": "#path=http | timechart(function=avg(response_body_len), unit=\"B/s\")",
        "end": "now",
        "showQueryEventDistribution": false,
        "isLive": true,
        "start": "24h",
        "timeZoneOffsetMinutes": 60
      }
    },
    {
      "id": "29af0518-15ad-49ef-a3c9-40e0535c18e7",
      "title": "Popular sites",
      "options": {
        "x": 6,
        "y": 4,
        "height": 4,
        "visualisation": {
          "widgetType": "pie-chart"
        },
        "width": 6
      },
      "query": {
        "queryString": "#path=http | groupby(host) | sort(_count, limit=10)",
        "end": "now",
        "showQueryEventDistribution": false,
        "isLive": true,
        "start": "24h",
        "timeZoneOffsetMinutes": 60
      }
    }
  ]
}
EOF
