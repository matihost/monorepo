resource "aws_ecr_repository" "app" {
  for_each = var.apps

  name                 = each.key
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  force_delete = true
}


resource "aws_ecr_lifecycle_policy" "app-policy" {
  for_each = var.apps

  repository = aws_ecr_repository.app[each.key].name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 30 images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"],
                "countType": "imageCountMoreThan",
                "countNumber": 30
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_ecs_task_definition" "app" {
  for_each = var.apps

  family = "${local.prefix}-${each.key}"

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  memory             = each.value.memory
  cpu                = each.value.cpu
  execution_role_arn = aws_iam_role.exec-role.arn

  task_role_arn = aws_iam_role.task-role.arn

  container_definitions = jsonencode(
    [
      {
        name      = each.key
        image     = each.value.image
        memory    = each.value.memory
        cpu       = each.value.cpu
        essential = true,
        portMappings = [
          {
            # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#container_definition_portmappings
            containerPort = each.value.port
            appProtocol = try(each.value.protocol, "http")
          }
        ]
        # environment = each.value.env_vars

        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group : aws_cloudwatch_log_group.logs.name
            awslogs-region : var.region
            awslogs-stream-prefix : each.key
          }
        }
      }
  ])
}


data "aws_security_group" "app-security-group" {
  for_each = var.apps
  vpc_id = data.aws_vpc.vpc.id
  tags = {
    Name = each.value.security_group_name
  }
}

resource "aws_ecs_service" "app" {
  for_each = var.apps

  name            = "${local.prefix}-${each.key}"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.app[each.key].arn
  desired_count   = try(each.value.desired_instances, 1)

  launch_type = "FARGATE"

  network_configuration {
    subnets = local.private_subnet_ids
    security_groups = [ data.aws_security_group.app-security-group[each.key].id ]
  }

  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "50"

  # load_balancer {
  #   target_group_arn = "${var.alb_target_group_arn}"
  #   container_name   = "${var.container_name}"
  #   container_port   = "${var.container_port}"
  # }
  lifecycle {
    ignore_changes = [desired_count]
  }
}
