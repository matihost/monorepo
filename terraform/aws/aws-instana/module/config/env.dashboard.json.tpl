[
  {
    "id": "VhL6g0bojIzA8LMg",
    "title": "EC2 Memory Usage (Top 20)",
    "width": 1,
    "height": 1,
    "x": 0,
    "y": 0,
    "type": "chart",
    "config": {
      "shareMaxAxisDomain": false,
      "y1": {
        "formatter": "percentage.detailed",
        "renderer": "line",
        "metrics": [
          {
            "lastValue": false,
            "color": "",
            "compareToTimeShifted": false,
            "threshold": {
              "critical": "",
              "warning": "",
              "thresholdEnabled": false,
              "operator": ">="
            },
            "aggregation": "MEAN",
            "label": "",
            "source": "INFRASTRUCTURE_METRICS",
            "type": "host",
            "metricPath": [
              "Others",
              "Host"
            ],
            "grouping": [
              {
                "maxResults": 20,
                "by": {
                  "tagDefinition": {
                    "path": [
                      {
                        "label": "Host"
                      },
                      {
                        "label": "name"
                      }
                    ],
                    "name": "host.name",
                    "availability": [],
                    "type": "STRING"
                  },
                  "groupbyTag": "host.name",
                  "groupbyTagEntity": "NOT_APPLICABLE",
                  "groupbyTagSecondLevelKey": ""
                },
                "includeOthers": false,
                "direction": "DESC"
              }
            ],
            "formatter": "percentage.detailed",
            "unit": "percentage",
            "metric": "memory.used",
            "timeShift": 0,
            "tagFilterExpression": {
              "tagDefinition": {
                "path": [
                  {
                    "label": "Other"
                  },
                  {
                    "label": "tag.Env"
                  }
                ],
                "name": "tag.Env",
                "availability": [],
                "type": "STRING"
              },
              "name": "tag.Env",
              "type": "TAG_FILTER",
              "value": "${env}",
              "entity": "NOT_APPLICABLE",
              "operator": "EQUALS"
            },
            "allowedCrossSeriesAggregations": [],
            "metricLabel": "Used",
            "crossSeriesAggregation": "MEAN"
          }
        ],
        "formatterSelected": false
      },
      "y2": {
        "formatter": "number.detailed",
        "renderer": "line",
        "metrics": []
      },
      "type": "TIME_SERIES"
    }
  },
  {
    "id": "Yg9QcbnMeWnIM5_-",
    "title": "EC2 CPU Usage (Top 20)",
    "width": 1,
    "height": 1,
    "x": 0,
    "y": 0,
    "type": "chart",
    "config": {
      "shareMaxAxisDomain": false,
      "y1": {
        "formatter": "percentage.detailed",
        "renderer": "line",
        "metrics": [
          {
            "lastValue": false,
            "color": "",
            "compareToTimeShifted": false,
            "threshold": {
              "critical": "",
              "warning": "",
              "thresholdEnabled": false,
              "operator": ">="
            },
            "aggregation": "MEAN",
            "label": "",
            "source": "INFRASTRUCTURE_METRICS",
            "type": "host",
            "metricPath": [
              "Others",
              "Host",
              "CPU"
            ],
            "grouping": [
              {
                "maxResults": 20,
                "by": {
                  "tagDefinition": {
                    "path": [
                      {
                        "label": "Host"
                      },
                      {
                        "label": "name"
                      }
                    ],
                    "name": "host.name",
                    "availability": [],
                    "type": "STRING"
                  },
                  "groupbyTag": "host.name",
                  "groupbyTagEntity": "NOT_APPLICABLE",
                  "groupbyTagSecondLevelKey": ""
                },
                "includeOthers": false,
                "direction": "DESC"
              }
            ],
            "formatter": "percentage.detailed",
            "unit": "percentage",
            "metric": "cpu.used",
            "timeShift": 0,
            "tagFilterExpression": {
              "tagDefinition": {
                "path": [
                  {
                    "label": "Other"
                  },
                  {
                    "label": "tag.Env"
                  }
                ],
                "name": "tag.Env",
                "availability": [],
                "type": "STRING"
              },
              "name": "tag.Env",
              "type": "TAG_FILTER",
              "value": "dev",
              "entity": "NOT_APPLICABLE",
              "operator": "EQUALS"
            },
            "allowedCrossSeriesAggregations": [],
            "metricLabel": "Used",
            "crossSeriesAggregation": "MEAN"
          }
        ],
        "formatterSelected": false
      },
      "y2": {
        "formatter": "number.detailed",
        "renderer": "line",
        "metrics": []
      },
      "type": "TIME_SERIES"
    }
  }
]
