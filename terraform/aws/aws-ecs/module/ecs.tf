
resource "aws_cloudwatch_log_group" "logs" {
  name              = "/ecs/${local.prefix}"
  retention_in_days = 7
}

resource "aws_ecs_account_setting_default" "container-monitoring" {
  name  = "containerInsights"
  value = "enabled"
}

resource "aws_ecs_cluster" "cluster" {
  name = "${local.prefix}-cluster"

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = false
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.logs.name
      }
    }
  }
}



resource "aws_ecs_cluster_capacity_providers" "spot" {
  cluster_name = aws_ecs_cluster.cluster.name

  capacity_providers = ["FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE_SPOT"
  }
}
