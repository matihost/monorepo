
resource "aws_iam_role" "instana" {
  name = local.prefix

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}

# to discover other AWS services by the Agent on the EC2
resource "aws_iam_role_policy_attachment" "instana-attach" {
  role       = aws_iam_role.instana.name
  policy_arn = aws_iam_policy.instana-policy.arn
}


# to be able to SSM to the instance in private subnet
resource "aws_iam_role_policy_attachment" "instana-ssm-ec2" {
  role       = aws_iam_role.instana.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "instana" {
  name = local.prefix
  role = aws_iam_role.instana.name
}


resource "aws_iam_policy" "instana-policy" {
  name        = local.prefix
  path        = "/"
  description = "Allow discover AWS services by AWS Instana Agent"

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "apigateway:GET",
          "appsync:ListGraphqlApis",
          "appsync:GetGraphqlApi",
          "appsync:ListDataSources",
          "autoscaling:DescribeAutoScalingGroups",
          "cloudfront:GetDistribution",
          "cloudfront:ListDistributions",
          "cloudfront:ListTagsForResource",
          "docdb-elastic:ListClusters",
          "docdb-elastic:GetCluster",
          "docdb-elastic:ListTagsForResource",
          "dynamodb:ListTables",
          "dynamodb:DescribeTable",
          "dynamodb:ListTagsOfResource",
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "ec2:DescribeVolumes",
          "elasticache:ListTagsForResource",
          "elasticache:DescribeCacheClusters",
          "elasticache:DescribeEvents",
          "elasticbeanstalk:DescribeEnvironments",
          "elasticbeanstalk:ListTagsForResource",
          "elasticbeanstalk:DescribeInstancesHealth",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTags",
          "elasticmapreduce:ListClusters",
          "elasticmapreduce:DescribeCluster",
          "es:ListDomainNames",
          "es:DescribeElasticsearchDomain",
          "es:ListTags",
          "iot:DescribeEndpoint",
          "iot:ListThings",
          "kafka:ListClusters",
          "kafka:ListNodes",
          "kafka:ListTagsForResource",
          "kafka:DescribeCluster",
          "kinesis:ListStreams",
          "kinesis:DescribeStream",
          "kinesis:ListTagsForStream",
          "lambda:ListTags",
          "lambda:ListFunctions",
          "lambda:ListEventSourceMappings",
          "lambda:GetFunctionConfiguration",
          "lambda:ListVersionsByFunction",
          "mq:ListBrokers",
          "mq:DescribeBroker",
          "rds:DescribeDBClusters",
          "rds:DescribeDBInstances",
          "rds:DescribeEvents",
          "rds:ListTagsForResource",
          "redshift:DescribeClusters",
          "s3:GetBucketTagging",
          "s3:ListAllMyBuckets",
          "s3:GetBucketLocation",
          "s3:GetBucketPolicyStatus",
          "sns:GetTopicAttributes",
          "sns:ListTagsForResource",
          "sns:ListTopics",
          "sqs:ListQueues",
          "sqs:GetQueueAttributes",
          "sqs:ListQueueTags",
          "timestream:ListDatabases",
          "timestream:DescribeEndpoints",
          "timestream:DescribeDatabase",
          "timestream:ListTagsForResource",
          "xray:BatchGetTraces",
          "xray:GetTraceSummaries",
          "tag:GetResources"
        ],
        "Effect": "Allow",
        "Resource": "*"
      },
      {
        "Action": [
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  }
  EOF
}
