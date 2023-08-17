### Terraform Cloud Info as Backend Storage and execution ###
terraform {
  cloud {
    hostname     = "app.terraform.io"
    organization = "Insideinfo"
    workspaces {
      name = "INSIDE_AWS_LABEC2"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.7.0"
    }
  }
}

### AWS Provider Info ###
provider "aws" {
  region = var.region
}

locals {
  common-tags = {
    author      = "DonghwanLim"
    system      = "LAB"
    Environment = "INSIDE__AWS_NETWORK"
  }
}

### AWS NETWORK Config GET ###
data "terraform_remote_state" "network" {
  backend = "remote"
  config = {
    organization = "Insideinfo"
    workspaces = {
      name = "INSIDE_AWS_LABNET"
    }
  }
}


########################################## VPC1 PUBLIC VM SG ###########################################
resource "aws_security_group" "vpc1_public_vm_sg" {
  name        = "public_vm_sg"
  description = "INSIDE_AWS_Public_VM_Security_GROUP"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc01_id

  tags = (merge(local.common-tags, tomap({
    Name     = "vpc1_public_vm_sg"
    resource = "aws_security_group"
  })))
}

### SSH Port open ANY
resource "aws_security_group_rule" "public_sg_rule_01" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.vpc1_public_vm_sg.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "public_sg_rule_02" {
  from_port         = "-1"
  protocol          = "icmp"
  security_group_id = aws_security_group.vpc1_public_vm_sg.id
  to_port           = "-1"
  type              = "ingress"
  cidr_blocks       = ["10.10.10.0/24"]
}

resource "aws_security_group_rule" "public_sg_rule_03" {
  from_port         = "-1"
  protocol          = "icmp"
  security_group_id = aws_security_group.vpc1_public_vm_sg.id
  to_port           = "-1"
  type              = "egress"
  cidr_blocks       = ["10.10.10.0/24"]
}

resource "aws_security_group_rule" "public_sg_rule_04" {
  from_port         = "443"
  protocol          = "tcp"
  security_group_id = aws_security_group.vpc1_public_vm_sg.id
  to_port           = "443"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "public_sg_rule_05" {
  from_port         = "443"
  protocol          = "tcp"
  security_group_id = aws_security_group.vpc1_public_vm_sg.id
  to_port           = "443"
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}


########################################## VPC1 PUBLIC VM SG ###########################################

resource "aws_security_group" "vpc2_public_vm_sg" {
  name        = "public_vm_sg_vpc2"
  description = "INSIDE_AWS_Public_VM_Security_GROUP"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc02_id

  tags = (merge(local.common-tags, tomap({
    Name     = "vpc2_public_vm_sg"
    resource = "aws_security_group"
  })))
}

### SSH Port open ANY
resource "aws_security_group_rule" "vpc2_public_sg_rule_01" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.vpc2_public_vm_sg.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "vpc2_public_sg_rule_02" {
  from_port         = "-1"
  protocol          = "icmp"
  security_group_id = aws_security_group.vpc2_public_vm_sg.id
  to_port           = "-1"
  type              = "ingress"
  cidr_blocks       = ["10.10.20.0/24"]
}

resource "aws_security_group_rule" "vpc2_public_sg_rule_03" {
  from_port         = "-1"
  protocol          = "icmp"
  security_group_id = aws_security_group.vpc2_public_vm_sg.id
  to_port           = "-1"
  type              = "egress"
  cidr_blocks       = ["10.10.20.0/24"]
}