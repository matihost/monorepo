resource "aws_iam_role" "task-role" {
  name = "${var.env}-ecs-task-role"

  assume_role_policy = <<EOF
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Principal":{
            "Service":[
               "ecs-tasks.amazonaws.com"
            ]
         },
         "Action":"sts:AssumeRole",
         "Condition":{
            "ArnLike":{
            "aws:SourceArn":"arn:aws:ecs:${var.region}:${local.account_id}:*"
            },
            "StringEquals":{
               "aws:SourceAccount":"${local.account_id}"
            }
         }
      }
   ]
}
EOF

  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html?icmpid=docs_ecs_hp-task-definition#ecs-exec-required-iam-permissions
  inline_policy {
    name   = "EcsExec"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
      "Effect": "Allow",
      "Action": [
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel"
      ],
      "Resource": "*"
      }
  ]
}
EOF
  }
}






resource "aws_iam_role" "exec-role" {
  name = "${var.env}-ecs-exec-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html?icmpid=docs_ecs_hp-task-definition#task-execution-private-auth
  inline_policy {
    name   = "PrivateECRAuth"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters",
        "secretsmanager:GetSecretValue",
        "kms:Decrypt"
      ],
      "Resource": [
        "arn:aws:ssm:${var.region}:${local.account_id}:parameter/*",
        "arn:aws:secretsmanager:${var.region}:${local.account_id}:secret:*",
        "arn:aws:kms:${var.region}:${local.account_id}:key/*"
      ]
    }
  ]
}
EOF
  }

}


resource "aws_iam_role_policy_attachment" "exec-role" {
  role       = aws_iam_role.exec-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
