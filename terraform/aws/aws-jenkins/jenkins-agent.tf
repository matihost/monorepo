resource "aws_security_group" "jenkins_agent" {
  name        = "jenkins_agent"
  description = "For jenkins-agent EC2 - allow SSH access from Jenkins Master"

  tags = {
    Name = "jenkins_agent"
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # allow traffic from instance with jenkins_master security group attached
    security_groups = [aws_security_group.jenkins_master.id]
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
