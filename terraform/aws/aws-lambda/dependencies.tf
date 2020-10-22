# assumes aws-iam was run
data "aws_iam_role" "lambda-basic" {
  name = "lambda-basic"
}
data "aws_iam_role" "apigateway-cloudwatch" {
  name = "apigateway-cloudwatch"
}

# assumes aws-instance was run
data "aws_security_group" "private_access" {
  tags = {
    Name = "private_access"
  }
}

data "terraform_remote_state" "ec2" {
  backend = "local"

  config = {
    path = "../aws-instance/terraform.tfstate"
  }
}

# assumes make prepare was run - aka lambda s3 is created and populated
data "terraform_remote_state" "lambda-s3" {
  backend = "local"

  config = {
    path = "prerequisites/terraform.tfstate"
  }
}


data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "public_subnet_1" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = var.zone
  default_for_az    = true
}
