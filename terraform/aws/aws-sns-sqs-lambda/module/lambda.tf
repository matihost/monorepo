resource "null_resource" "lambda-package-build" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = <<EOF
	cd ${path.module} && python -m venv target && . ./target/bin/activate && \
	pip install boto3 Pillow && cd target/lib/python3*/site-packages && \
	zip -r ../../../../lambda.zip . && cd ../../../.. && \
	zip lambda.zip *.py && rm -rf target && mkdir target && mv lambda.zip target
EOF
  }
}


data "local_file" "lambda-package" {
  filename   = "${path.module}/target/lambda.zip"
  depends_on = [null_resource.lambda-package-build]
}

resource "aws_lambda_function" "thumbnail" {
  function_name = "${local.prefix}-thumbnail"
  description   = "Creates thumbnail from /ingest directory"


  filename = data.local_file.lambda-package.filename

  # TODO add with try
  # source_code_hash =

  handler = "CreateThumbnail.handler"
  runtime = "python3.12"

  role = aws_iam_role.lambdarole.arn

  environment {
    variables = {
      FORMAT = "Thumbnail"
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.thumbnail,
    null_resource.lambda-package-build
  ]
}

# this is manage the CloudWatch Log Group for the Lambda Function
resource "aws_cloudwatch_log_group" "thumbnail" {
  name              = "/aws/lambda/${local.prefix}-thumbnail"
  retention_in_days = 1
}


resource "aws_lambda_event_source_mapping" "thumbnail-lambda-sqs-trigger" {
  event_source_arn = aws_sqs_queue.thumbnailImageResize.arn
  function_name    = aws_lambda_function.thumbnail.arn

  batch_size = 1
}



resource "aws_lambda_function" "mobile" {
  function_name = "${local.prefix}-mobile"
  description   = "Creates mobile sized image from /ingest directory"


  filename = data.local_file.lambda-package.filename

  handler = "CreateMobileImage.handler"
  runtime = "python3.12"

  role = aws_iam_role.lambdarole.arn

  environment {
    variables = {
      FORMAT = "Mobile"
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.mobile,
    null_resource.lambda-package-build
  ]
}

# this is manage the CloudWatch Log Group for the Lambda Function
resource "aws_cloudwatch_log_group" "mobile" {
  name              = "/aws/lambda/${local.prefix}-mobile"
  retention_in_days = 1
}


resource "aws_lambda_event_source_mapping" "mobile-lambda-sqs-trigger" {
  event_source_arn = aws_sqs_queue.mobileImageResize.arn
  function_name    = aws_lambda_function.mobile.arn

  batch_size = 1
}



resource "aws_lambda_function" "web" {
  function_name = "${local.prefix}-wb"
  description   = "Creates web sized image from /ingest directory"


  filename = data.local_file.lambda-package.filename

  handler = "CreateWebImage.handler"
  runtime = "python3.12"

  role = aws_iam_role.lambdarole.arn

  environment {
    variables = {
      FORMAT = "Mobile"
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.web,
    null_resource.lambda-package-build
  ]
}

resource "aws_cloudwatch_log_group" "web" {
  name              = "/aws/lambda/${local.prefix}-web"
  retention_in_days = 1
}


resource "aws_lambda_event_source_mapping" "web-lambda-sqs-trigger" {
  event_source_arn = aws_sqs_queue.webImageResize.arn
  function_name    = aws_lambda_function.web.arn

  batch_size = 1
}
