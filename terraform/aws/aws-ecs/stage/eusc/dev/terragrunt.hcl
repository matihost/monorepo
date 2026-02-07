locals {
  region                    = "eusc-de-east-1"
  dd_api_key                = try(get_env("DD_API_KEY"), "")
  dd_rds_dns                = try(get_env("DD_RDS_DNS"), "")
  dd_rds_password           = try(get_env("DD_RDS_PASSWORD"), "")
  dd_db_instance_identifier = try(get_env("DD_DB_INSTANCE_IDENTIFIER"), "")
}

include "root" {
  path = find_in_parent_folders("eusc.hcl")
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}


inputs = {
  env      = "dev"
  region   = local.region
  zone     = "${local.region}a"
  vpc_name = "dev-${local.region}"
  aws_tags = {
    Env    = "dev"
    Region = local.region
  }
  zones = [
    "${local.region}a", "${local.region}b",
    # TODO eusc does not have 3 AZs yet
    # "${local.region}c"
  ]
  apps = {
    "nginx" : {
      name                = "nginx",
      image               = "nginx:latest",
      desired_instances   = 1,
      protocol            = "http",
      cpu                 = 1024,
      memory              = 2048,
      port                = 80,
      security_group_name = "dev-${local.region}-ssh-http-from-vpc"
      env_vars            = []
      docker_labels       = {}
    },
    # Datadog agent for RDS database monitoring
    # Configure PostgreSQL database: add user and grant permissions:
    # https://docs.datadoghq.com/database_monitoring/setup_postgres/rds?tab=postgres15#grant-the-agent-access
    # https://docs.datadoghq.com/database_monitoring/setup_postgres/aurora?tab=docker#install-the-agent
    #
    # To deploy and test:
    #
    # export DD_API_KEY="your_api_key"
    # export DD_RDS_DNS="dev.cluster-czk84imkkq6n.eusc-de-east-1.rds.amazonaws.eu"
    # export DD_RDS_PASSWORD="datadog"
    # export DD_DB_INSTANCE_IDENTIFIER="dev"
    #
    # And uncomment:
    #
    # "rds-datadog-agent" : {
    #   name                = "rds-datadog-agent",
    #   image               = "public.ecr.aws/datadog/agent:latest",
    #   desired_instances   = 1,
    #   protocol            = "http",
    #   cpu                 = 256,
    #   memory              = 512,
    #   port                = 0, # do not expose via ALB
    #   security_group_name = "dev-${local.region}-psql-from-vpc"
    #   # to emulate Recreate deployment strategy
    #   maximum_percent         = 100,
    #   minimum_healthy_percent = 0,
    #   env_vars = [
    #       {
    #         "name": "DD_API_KEY",
    #         "value": "${local.dd_api_key}"
    #       },
    #       {
    #         "name": "DD_SITE",
    #         "value": "datadoghq.com"
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
    #   docker_labels = {
    #     "com.datadoghq.ad.checks": "{\"postgres\": {\"instances\": [{\"dbm\": true, \"host\": \"${local.dd_rds_dns}\", \"port\": 5432, \"username\": \"datadog\", \"password\": \"${local.dd_rds_password}\", \"database_autodiscovery\": {\"enabled\": true}, \"aws\": {\"instance_endpoint\": \"${local.dd_rds_dns}\", \"region\": \"${local.region}\"}, \"tags\": [\"dbinstanceidentifier:${local.dd_db_instance_identifier}\"]  }]}}"
    #   },
    # },
  }
}
