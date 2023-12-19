## Terraform Infrastructure Setup
This repository contains Terraform code for setting up infrastructure in AWS. The infrastructure is divided into three main modules: networking, compute, and application.

## Overview
The root module contains the AWS provider configuration and calls the child modules. It also contains a local value that maps Terraform workspaces to environment names.
The child modules are responsible for setting up different parts of the infrastructure:


# Networking Module: 
This module sets up the VPC, public subnets, and private subnets. It also configures an Internet Gateway for the public subnets and a NAT Gateway for the private subnets.

overview of what each resource within the module does:

Availability Zones
Data Source: aws_availability_zones.available
Purpose: Fetches the availability zones that are available for use within the AWS account.
Virtual Private Cloud (VPC)


Resource: aws_vpc.main
Purpose: Creates a VPC with the specified CIDR block. DNS support and DNS hostnames are enabled for this VPC.
Private Subnets


Resource: aws_subnet.private
Purpose: Creates two private subnets within the VPC. These subnets do not automatically assign public IP addresses to instances.
Public Subnets


Resource: aws_subnet.public
Purpose: Creates two public subnets within the VPC. These subnets automatically assign public IP addresses to instances.
Internet Gateway


Resource: aws_internet_gateway.igw
Purpose: Creates an internet gateway and attaches it to the VPC. This allows instances within the VPC to access the internet.
Elastic IP (EIP)


Resource: aws_eip.nat
Purpose: Allocates an Elastic IP address for use with the NAT gateway.
NAT Gateway


Resource: aws_nat_gateway.nat_gw
Purpose: Creates a NAT gateway within the first public subnet and associates it with the allocated Elastic IP address. This allows instances in the private subnets to access the internet.
Public Route Table


Resource: aws_route_table.public
Purpose: Creates a route table for the public subnets. This route table contains a route that directs all traffic (0.0.0.0/0) to the internet gateway.
Private Route Table


Resource: aws_route_table.private
Purpose: Creates a route table for the private subnets. This route table contains a route that directs all traffic (0.0.0.0/0) to the NAT gateway.
Route Table Associations


Resources: aws_route_table_association.public and aws_route_table_association.private
Purpose: Associates the public and private subnets with their respective route tables.


# Compute Module: 

The compute module in this Terraform configuration is responsible for provisioning and managing various AWS resources related to compute and networking. Here's a brief overview of what each resource within the module does:
EC2 Instance for MySQL

Resource: aws_instance.mysql
Purpose: Creates an EC2 instance using the specified AMI (ami-0068d7451cf00173c) and instance type (t2.micro). This instance is intended to run a MySQL database and is placed within the first public subnet provided by the public_subnets variable.

Security Groups: The instance is associated with a custom security group (aws_security_group.mysql_sg) and an additional existing security group (sg-0a0e94eddc865eae0).
Tags: The instance is tagged with the environment name and a specific name indicating its purpose as a MySQL server.
Security Group for MySQL
Resource: aws_security_group.mysql_sg
Purpose: Defines a security group that allows inbound MySQL traffic on port 3306 from the VPC's CIDR range and a specific external IP address (188.161.184.40/32). It also allows all outbound traffic.
Tags: The security group is tagged with the environment name and a specific name indicating its purpose.

DNS A Record
Resource: aws_route53_record.dns_record
Purpose: Creates a DNS A record in the specified Route53 hosted zone (Z0719936LWNSUHYQY8CX) that points to the public IP of the MySQL EC2 instance. The record is named after the environment and is intended to provide a domain name for accessing the MySQL server.

Data Lifecycle Manager Policy
Resource: aws_dlm_lifecycle_policy.ec2_dlm_backup
Purpose: Establishes a Data Lifecycle Manager policy to automate the creation of daily EBS-backed AMIs of the MySQL EC2 instance. It retains only one snapshot and tags the snapshots for identification.

ECS Cluster
Resource: aws_ecs_cluster.cluster
Purpose: Creates an ECS cluster named after the environment, which will be used to manage containerized services.

Launch Template
Resource: aws_launch_template.lt
Purpose: Defines a launch template for EC2 instances that will be part of an Auto Scaling group. The template specifies the AMI, instance type, key name, IAM instance profile, and network interfaces. It also includes user data to configure the instances as part of the ECS cluster.

Auto Scaling Group
Resource: aws_autoscaling_group.asg
Purpose: Creates an Auto Scaling group using the defined launch template. It sets the minimum and maximum size of the group and associates it with the public subnets. The group is tagged and configured to create new instances before destroying old ones.

ECS Capacity Provider
Resource: aws_ecs_capacity_provider.capacity_provider
Purpose: Creates an ECS capacity provider linked to the Auto Scaling group. It enables managed scaling and termination protection for the instances within the ECS cluster.

ECS Cluster Capacity Providers
Resource: aws_ecs_cluster_capacity_providers.cluster
Purpose: Associates the created capacity provider with the ECS cluster and sets it as the default capacity provider strategy.

# Application Module: 

This Terraform module sets up an AWS environment for running containerized services behind an application load balancer. 
The services' Docker images are stored in ECR repositories,
and the services themselves are run as ECS tasks. 
The ALB distributes incoming traffic to these services, and a security group controls the traffic allowed to reach the ALB.

Here's a brief overview of what each resource within the module does:

Application Load Balancer (ALB): The aws_lb resource creates an application load balancer named according to the provided environment variable. This ALB is not internal, meaning it's accessible from the internet. It uses a specific security group and is associated with public subnets


Security Group: The aws_security_group resource creates a security group for the application load balancer. This security group allows inbound traffic on ports 80 (HTTP) and 443 (HTTPS) from any source, and allows all outbound traffic


Elastic Container Registry (ECR) Repositories: The aws_ecr_repository resource creates ECR repositories for each service name provided in the service_names variable. These repositories will store Docker images for the services


Elastic Container Service (ECS) Task Definitions: The aws_ecs_task_definition resources define tasks for the "orders" and "users" services. Each task runs a single Docker container, using the image stored in the corresponding ECR repository. The tasks are configured to use the "bridge" network mode and are compatible with the "EC2" launch type. Each container listens on port 80 and logs to AWS CloudWatch Logs

## Prerequisites

AWS account with necessary permissions


Usage
Clone the repository:
sh
git clone <repository-url>

Navigate to the repository directory:
sh
cd <repository-directory>

Initialize Terraform:


terraform init

Validate the configuration:

terraform validate

Plan the deployment:

terraform plan -var="cidr_block=<your-cidr-block>"

Apply the configuration:

terraform apply -var="cidr_block=<your-cidr-block>"

Replace <your-cidr-block> with the desired CIDR block for your VPC.
