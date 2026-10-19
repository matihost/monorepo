resource "aws_s3_bucket" "glue-data" {
  bucket = "${var.env}-glue-data-${local.account_id}"

  force_destroy = true
}

resource "aws_s3_object" "script" {
  bucket = aws_s3_bucket.glue-data.id
  key    = "scripts/CopyS3.py"

  source = "${path.module}/CopyS3.py"
  # re-upload the script when its content changes
  etag = filemd5("${path.module}/CopyS3.py")
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
    "--DATA_BUCKET"                      = aws_s3_bucket.glue-data.id
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
