resource "aws_s3_bucket" "glue-data" {
  bucket = "${var.env}-glue-data-${local.account_id}"

  force_destroy = true
}

resource "aws_s3_object" "script" {
  bucket = aws_s3_bucket.glue-data.id
  key    = "scripts/CopyS3.py"

  content = <<EOF
import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglueml.transforms import EntityDetector

args = getResolvedOptions(sys.argv, ["JOB_NAME"])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# Script generated for node Input
Input_node1705505530241 = glueContext.create_dynamic_frame.from_options(
    format_options={"multiline": True},
    connection_type="s3",
    format="json",
    connection_options={
        "paths": ["s3://dev-glue-data-${local.account_id}/data/input/"],
        "recurse": True,
    },
    transformation_ctx="Input_node1705505530241",
)

# Script generated for node Detect Sensitive Data
detection_parameters = {
    "CREDIT_CARD": [{"action": "REDACT", "actionOptions": {"redactText": "******"}}]
}

entity_detector = EntityDetector()
DetectSensitiveData_node1705506030398 = entity_detector.detect(
    Input_node1705505530241, detection_parameters, "DetectedEntities", "HIGH"
)

# Script generated for node Amazon S3
AmazonS3_node1705506389906 = glueContext.write_dynamic_frame.from_options(
    frame=DetectSensitiveData_node1705506030398,
    connection_type="s3",
    format="json",
    connection_options={
        "path": "s3://dev-glue-data-${local.account_id}/data/output/",
        "partitionKeys": [],
    },
    transformation_ctx="AmazonS3_node1705506389906",
)

job.commit()
EOF
}

resource "aws_s3_object" "temporary-dir" {
  bucket = aws_s3_bucket.glue-data.id
  key    = "temporary/"
}

resource "aws_s3_object" "sparkHistoryLogs-dir" {
  bucket = aws_s3_bucket.glue-data.id
  key    = "sparkHistoryLogs/"
}

resource "aws_s3_object" "input" {
  bucket  = aws_s3_bucket.glue-data.id
  key     = "data/input/input.json"
  content = <<EOF
{"name": "John Doe", "address" : "111 Some Dr 76726282 Irving TX, US", "cc": "4242424242424242"}
{"name": "Anna Doe", "address" : "111 Some Dr 12323453 Irving TX, US", "cc": "5555555555554444"}
EOF
}

resource "aws_s3_object" "input-dir" {
  bucket = aws_s3_bucket.glue-data.id
  key    = "data/output/"
}


resource "aws_glue_job" "pci-s3-job" {
  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = "s3://dev-glue-data-${local.account_id}/scripts/CopyS3.py"
  }

  default_arguments = {
    "--TempDir"                          = "s3://dev-glue-data-${local.account_id}/temporary/"
    "--enable-auto-scaling"              = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-glue-datacatalog"          = "true"
    "--enable-job-insights"              = "false"
    "--enable-metrics"                   = "true"
    "--enable-observability-metrics"     = "true"
    "--enable-spark-ui"                  = "true"
    "--job-bookmark-option"              = "job-bookmark-disable"
    "--job-language"                     = "python"
    "--spark-event-logs-path"            = "s3://dev-glue-data-${local.account_id}/sparkHistoryLogs/"
  }

  description     = "Copies S3 with hiding credit cards in the files"
  execution_class = "FLEX"

  execution_property {
    max_concurrent_runs = "1"
  }

  glue_version      = "4.0"
  max_retries       = "0"
  name              = "CopyS3"
  number_of_workers = "2"
  role_arn          = aws_iam_role.glue-exec-role.arn
  timeout           = "120"
  worker_type       = "G.1X"

  depends_on = [aws_s3_object.script]
}
