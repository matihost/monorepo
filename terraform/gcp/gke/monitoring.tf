# editing dashboards:
#
# list dashboards
# gcloud monitoring dashboards list --format="flattened(name,displayName)"
#
# export json structure of particular dashboard
# gcloud monitoring dashboards describe ec7eb31f-a99a-47c6-b958-b6d5eba63c5e --format=json

resource "google_monitoring_dashboard" "gke-capacity-dashboard" {
  dashboard_json = <<EOF
{
  "category": "CUSTOM",
  "dashboardFilters": [],
  "displayName": "GKE Capacity Status",
  "labels": {},
  "mosaicLayout": {
    "columns": 12,
    "tiles": [
      {
        "height": 4,
        "widget": {
          "title": "GKE :: Total Request & Limit Cores",
          "xyChart": {
            "chartOptions": {
              "mode": "COLOR"
            },
            "dataSets": [
              {
                "minAlignmentPeriod": "60s",
                "plotType": "LINE",
                "targetAxis": "Y1",
                "timeSeriesQuery": {
                  "apiSource": "DEFAULT_CLOUD",
                  "timeSeriesFilter": {
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "crossSeriesReducer": "REDUCE_SUM",
                      "groupByFields": [
                        "resource.label.\"cluster_name\""
                      ],
                      "perSeriesAligner": "ALIGN_MEAN"
                    },
                    "filter": "metric.type=\"kubernetes.io/container/cpu/request_cores\" resource.type=\"k8s_container\"",
                    "secondaryAggregation": {
                      "alignmentPeriod": "60s",
                      "crossSeriesReducer": "REDUCE_NONE",
                      "perSeriesAligner": "ALIGN_NONE"
                    }
                  }
                }
              },
              {
                "minAlignmentPeriod": "60s",
                "plotType": "LINE",
                "targetAxis": "Y1",
                "timeSeriesQuery": {
                  "apiSource": "DEFAULT_CLOUD",
                  "timeSeriesFilter": {
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "crossSeriesReducer": "REDUCE_SUM",
                      "groupByFields": [
                        "resource.label.\"cluster_name\""
                      ],
                      "perSeriesAligner": "ALIGN_MEAN"
                    },
                    "filter": "metric.type=\"kubernetes.io/container/cpu/limit_cores\" resource.type=\"k8s_container\"",
                    "secondaryAggregation": {
                      "alignmentPeriod": "60s",
                      "crossSeriesReducer": "REDUCE_NONE",
                      "perSeriesAligner": "ALIGN_NONE"
                    }
                  }
                }
              }
            ],
            "thresholds": [],
            "timeshiftDuration": "0s",
            "yAxis": {
              "label": "y1Axis",
              "scale": "LINEAR"
            }
          }
        },
        "width": 6,
        "xPos": 0,
        "yPos": 0
      },
      {
        "height": 4,
        "widget": {
          "title": "GKE ::  CPU usage time",
          "xyChart": {
            "chartOptions": {
              "mode": "COLOR"
            },
            "dataSets": [
              {
                "minAlignmentPeriod": "60s",
                "plotType": "LINE",
                "targetAxis": "Y1",
                "timeSeriesQuery": {
                  "apiSource": "DEFAULT_CLOUD",
                  "timeSeriesFilter": {
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "crossSeriesReducer": "REDUCE_NONE",
                      "perSeriesAligner": "ALIGN_RATE"
                    },
                    "filter": "metric.type=\"kubernetes.io/node/cpu/core_usage_time\" resource.type=\"k8s_node\"",
                    "secondaryAggregation": {
                      "alignmentPeriod": "60s",
                      "crossSeriesReducer": "REDUCE_MEAN",
                      "groupByFields": [
                        "resource.label.\"cluster_name\""
                      ],
                      "perSeriesAligner": "ALIGN_MEAN"
                    }
                  }
                }
              }
            ],
            "thresholds": [],
            "timeshiftDuration": "0s",
            "yAxis": {
              "label": "y1Axis",
              "scale": "LINEAR"
            }
          }
        },
        "width": 6,
        "xPos": 6,
        "yPos": 0
      }
    ]
  }
}
EOF
}


resource "google_monitoring_dashboard" "prometheus-ingestion-rate" {
  dashboard_json = <<EOF
{
  "category": "CUSTOM",
  "dashboardFilters": [],
  "displayName": "Prometheus Ingestion Rate",
  "labels": {},
  "mosaicLayout": {
    "columns": 12,
    "tiles": [
      {
        "height": 4,
        "widget": {
          "title": "Managed Prometheus Samples Ingested",
          "xyChart": {
            "chartOptions": {
              "mode": "COLOR"
            },
            "dataSets": [
              {
                "minAlignmentPeriod": "60s",
                "plotType": "LINE",
                "targetAxis": "Y1",
                "timeSeriesQuery": {
                  "apiSource": "DEFAULT_CLOUD",
                  "timeSeriesFilter": {
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "crossSeriesReducer": "REDUCE_SUM",
                      "groupByFields": [
                        "resource.label.\"location\"",
                        "resource.label.\"attribution_id\""
                      ],
                      "perSeriesAligner": "ALIGN_RATE"
                    },
                    "filter": "metric.type=\"monitoring.googleapis.com/collection/attribution/write_sample_count\" resource.type=\"monitoring.googleapis.com/MetricIngestionAttribution\" resource.label.\"attribution_dimension\"=\"cluster\" metric.label.\"metric_domain\"=\"prometheus.googleapis.com\" metric.label.\"resource_type\"=\"prometheus_target\"",
                    "pickTimeSeriesFilter": {
                      "direction": "TOP",
                      "numTimeSeries": 5,
                      "rankingMethod": "METHOD_MAX"
                    },
                    "secondaryAggregation": {
                      "alignmentPeriod": "60s",
                      "crossSeriesReducer": "REDUCE_NONE",
                      "perSeriesAligner": "ALIGN_NONE"
                    }
                  }
                }
              }
            ],
            "thresholds": [],
            "timeshiftDuration": "0s",
            "yAxis": {
              "label": "y1Axis",
              "scale": "LINEAR"
            }
          }
        },
        "width": 6,
        "xPos": 0,
        "yPos": 0
      },
      {
        "height": 4,
        "widget": {
          "title": "Managed Prometheus Samples Ingested by Metric (Top 5)",
          "xyChart": {
            "chartOptions": {
              "mode": "COLOR"
            },
            "dataSets": [
              {
                "minAlignmentPeriod": "60s",
                "plotType": "LINE",
                "targetAxis": "Y1",
                "timeSeriesQuery": {
                  "apiSource": "DEFAULT_CLOUD",
                  "timeSeriesFilter": {
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "crossSeriesReducer": "REDUCE_SUM",
                      "groupByFields": [
                        "metric.label.\"metric_type\""
                      ],
                      "perSeriesAligner": "ALIGN_RATE"
                    },
                    "filter": "metric.type=\"monitoring.googleapis.com/collection/attribution/write_sample_count\" resource.type=\"monitoring.googleapis.com/MetricIngestionAttribution\" resource.label.\"attribution_dimension\"=\"cluster\" metric.label.\"resource_type\"=\"prometheus_target\"",
                    "pickTimeSeriesFilter": {
                      "direction": "TOP",
                      "numTimeSeries": 5,
                      "rankingMethod": "METHOD_MAX"
                    },
                    "secondaryAggregation": {
                      "alignmentPeriod": "60s",
                      "crossSeriesReducer": "REDUCE_NONE",
                      "perSeriesAligner": "ALIGN_NONE"
                    }
                  }
                }
              }
            ],
            "thresholds": [],
            "timeshiftDuration": "0s",
            "yAxis": {
              "label": "y1Axis",
              "scale": "LINEAR"
            }
          }
        },
        "width": 6,
        "xPos": 6,
        "yPos": 0
      }
    ]
  }
}
EOF
}
