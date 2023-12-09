resource "aws_db_subnet_group" "private" {
  name       = local.prefix
  subnet_ids = local.private_subnet_ids
}


resource "aws_security_group" "internal_access" {
  name        = "${local.prefix}-psql-from-vpc"
  description = "Allow PSQL access from internal VPC only"

  vpc_id = data.aws_vpc.vpc.id

  tags = {
    Name = "${local.prefix}-psql-from-vpc"
  }

  ingress {
    description = "PSQL from default VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }

  # Terraform removed default egress ALLOW_ALL rule
  # It has to be explicitely added
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_rds_cluster" "db" {
  for_each = var.dbs

  cluster_identifier                  = each.key
  database_name                       = each.value.db_name

  # allocated_storage                   = "1"
  availability_zones                  = var.zones
  backtrack_window                    = "0"
  backup_retention_period             = "7"
  copy_tags_to_snapshot               = "true"
  db_subnet_group_name                = aws_db_subnet_group.private.name
  deletion_protection                 = "false"
  apply_immediately                   = true
  # http_endpoint not supported by Aurora Serverless v2
  # enable_http_endpoint                = true
  enabled_cloudwatch_logs_exports     = ["postgresql"]
  engine                              = "aurora-postgresql"
  # engine_mode                         = "provisioned"
  engine_version                      = "15.4"
  iam_database_authentication_enabled = "true"
  # iops                                = "0"
  # db_cluster_parameter_group_name     = "default.aurora-postgresql15"

  master_username                     = "postgres"
  master_password                     = random_password.postgres[each.key].result
  network_type                        = "IPV4"
  port                                = "5432"
  preferred_backup_window             = "06:43-07:13"
  preferred_maintenance_window        = "mon:10:25-mon:10:55"
  skip_final_snapshot = true

  serverlessv2_scaling_configuration {
    max_capacity = "16"
    min_capacity = "2"
  }

  storage_encrypted      = "false"
  vpc_security_group_ids = [ aws_security_group.internal_access.id ]
}


resource "aws_rds_cluster_instance" "db_instance_1" {
  for_each = var.dbs


  identifier         = "${aws_rds_cluster.db[each.key].cluster_identifier}-1"
  cluster_identifier = aws_rds_cluster.db[each.key].id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.db[each.key].engine
  engine_version     = aws_rds_cluster.db[each.key].engine_version

  db_subnet_group_name  = aws_db_subnet_group.private.name
  apply_immediately     = true
  copy_tags_to_snapshot = true
}


resource "random_password" "postgres" {
  for_each = var.dbs

  length           = 10
  special          = true
  override_special = "_%@"
}


output "postgres-password" {
  value = values(random_password.postgres)[*].result
  sensitive = true
}


output "psql-cmd"{
  value = [[for key, db in var.dbs: "psql -U postgres -W -h ${aws_rds_cluster.db[key].endpoint} ${db.db_name}" ] ]
}
