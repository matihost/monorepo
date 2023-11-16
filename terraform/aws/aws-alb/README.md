# Terraform :: Application Load Balancer usage example

Terraform scripts deploy sample webserver app in autoscalling mode in private subnets and expose public facing loadbalancer to it.

In particular it creates:

- launch template for webserver (ubuntu with nginx acting as webserver)

- autoscaling group, plus simple autoscaling policy

- targetgroup for ALB usage - it is being populated via autoscaling group automatically (aka changes to instances count is reflected in target group)

- Application Load Balancer (ALB)  with single listener forwarding all traffic to above target group

This setup use AWS resources eligible to AWS Free Tier __only__.

## Prerequisites

- Logged to AWS Account

```bash
aws configure
```

- Latest Terraform installed

- The scripts assume that [aws-network-setup](../aws-network-setup) is already deployed (aka private networking is present).

## Usage

```bash

# deploy webservers ALB
make run ENV=dev MODE=apply

# test webservers via ALB
make test

# show autoscalling group state(see DesiredCapacity field for current amount of instances)
make show-auto-scalling-group-state

# scale Auto Scalling Group up by single instance
make scale-up-manually

# scale Auto Scalling Group down by single instance
make scale-down-manually

# show Terraform state
make show-state

# terminates all AWS resource created with apply task
make destroy
```
