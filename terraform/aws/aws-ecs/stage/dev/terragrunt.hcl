include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}


inputs = {
  env      = "dev"
  region   = "us-east-1"
  zone     = "us-east-1a"
  vpc_name = "dev-us-east-1"
  aws_tags = {
    Env    = "dev"
    Region = "us-east1"
  }
  zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  apps = {
    "nginx" : {
      name                = "nginx",
      image               = "nginx:latest",
      desired_instances   = 1,
      protocol            = "http",
      cpu                 = 1024,
      memory              = 2048,
      port                = 80,
      security_group_name = "dev-ssh-http-from-vpc"
      env_vars            = []
      docker_labels       = {}
    },
    # Datadog agent for RDS database monitoring
    # https://docs.datadoghq.com/database_monitoring/setup_postgres/aurora?tab=docker#install-the-agent
    #
    # "rds-datadog-agent" : {
    #   name                = "rds-datadog-agent",
    #   image               = "public.ecr.aws/datadog/agent:latest",
    #   desired_instances   = 1,
    #   protocol            = "http",
    #   cpu                 = 256,
    #   memory              = 512,
    #   port                = 0, # do not expose via ALB
    #   security_group_name = "dev-us-east-1-psql-from-vpc"
    #   env_vars = [
    #       {
    #         "name": "DD_API_KEY",
    #         "value": "<DD_API_KEY_HERE>"
    #       },
    #       {
    #         "name": "DD_HEALTH_PORT",
    #         "value": "80"
    #       },
    #       {
    #         "name": "DD_ENV",
    #         "value": "dev"
    #       },
    #       {
    #         "name": "ECS_FARGATE",
    #         "value": "true"
    #       },
    #   ],
    #
    ## TODO migrate DD checks/integration with format for Datadog Agent v7.36+:
    ## Example on Redis check:
    ##
    ## labels:
    ##   com.datadoghq.ad.checks: '{"redisdb": {"instances": [{"host": "%%host%%","port":"6379","password":"%%env_REDIS_PASSWORD%%"}], "logs": [{"type": "file", "path": "/var/log/redis_6379.log", "source": "redis", "service": "redis_service"}]}}'
    ##
    ## For earlier Agent versions it was formatted like:
    ##
    ## labels:
    ##   com.datadoghq.ad.check_names: '["redisdb"]'
    ##   com.datadoghq.ad.init_configs: '[{}]'
    ##   com.datadoghq.ad.instances: '[{"host": "%%host%%","port":"6379","password":"%%env_REDIS_PASSWORD%%"}]'
    ##   com.datadoghq.ad.logs: '[{"type": "file", "path": "/var/log/redis_6379.log", "source": "redis", "service": "redis_service"}]'
    #
    #   docker_labels = {
    #     "com.datadoghq.ad.check_names": "[\"postgres\"]",
    #     "com.datadoghq.ad.init_configs": "[{}]",
    #     "com.datadoghq.ad.instances": "[{\"dbm\": true, \"host\": \"<RDS-DNS>\", \"port\": 5432, \"username\": \"datadog\", \"password\": \"<PASSWORD>\" }]"
    #   },
    # },
  }
}
