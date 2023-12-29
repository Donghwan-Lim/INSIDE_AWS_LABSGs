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


########################################## (START) VPC1 PUBLIC VM SG ###########################################
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

### ICMP open from public vpc1
resource "aws_security_group_rule" "public_sg_rule_02" {
  from_port         = "-1"
  protocol          = "icmp"
  security_group_id = aws_security_group.vpc1_public_vm_sg.id
  to_port           = "-1"
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

### ICMP open to public vpc1
/*
resource "aws_security_group_rule" "public_sg_rule_03" {
  from_port         = "-1"
  protocol          = "icmp"
  security_group_id = aws_security_group.vpc1_public_vm_sg.id
  to_port           = "-1"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/24"]
}
*/
### HTTPS port open to any
resource "aws_security_group_rule" "public_sg_rule_04" {
  from_port         = "443"
  protocol          = "tcp"
  security_group_id = aws_security_group.vpc1_public_vm_sg.id
  to_port           = "443"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

### HTTP port open to any
resource "aws_security_group_rule" "public_sg_rule_05" {
  from_port         = "80"
  protocol          = "tcp"
  security_group_id = aws_security_group.vpc1_public_vm_sg.id
  to_port           = "80"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

### SSH port open to VPC
resource "aws_security_group_rule" "public_sg_rule_06" {
  from_port         = "22"
  protocol          = "tcp"
  security_group_id = aws_security_group.vpc1_public_vm_sg.id
  to_port           = "22"
  type              = "egress"
  cidr_blocks       = ["10.10.10.0/24"]
}

### HTTPS port open from any
resource "aws_security_group_rule" "public_sg_rule_07" {
  from_port         = "443"
  protocol          = "tcp"
  security_group_id = aws_security_group.vpc1_public_vm_sg.id
  to_port           = "443"
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "public_sg_rule_08" {
  from_port         = "22"
  protocol          = "tcp"
  security_group_id = aws_security_group.vpc1_public_vm_sg.id
  to_port           = "22"
  type              = "egress"
  cidr_blocks       = ["10.10.20.0/24"]
}
########################################## (END) VPC1 PUBLIC VM SG ###########################################

########################################## (START) VPC2 PRIVATE VM SG ###########################################
resource "aws_security_group" "vpc2_private_vm_sg" {
  name        = "private_vm_sg_vpc2"
  description = "INSIDE_AWS_Private_VM_Security_GROUP"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc02_id

  tags = (merge(local.common-tags, tomap({
    Name     = "vpc2_private_vm_sg"
    resource = "aws_security_group"
  })))
}

### SSH Port open ANY
resource "aws_security_group_rule" "vpc2_private_sg_rule_01" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.vpc2_private_vm_sg.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "vpc2_private_sg_rule_02" {
  from_port         = "-1"
  protocol          = "icmp"
  security_group_id = aws_security_group.vpc2_private_vm_sg.id
  to_port           = "-1"
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "vpc2_private_sg_rule_03" {
  from_port         = "-1"
  protocol          = "icmp"
  security_group_id = aws_security_group.vpc2_private_vm_sg.id
  to_port           = "-1"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "vpc2_private_sg_rule_04" {
  from_port         = "443"
  protocol          = "tcp"
  security_group_id = aws_security_group.vpc2_private_vm_sg.id
  to_port           = "443"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
########################################## (END) VPC2 PUBLIC VM SG ###########################################

########################################## (START) VPC1 Terraform Enterprise SG ###########################################
resource "aws_security_group" "vpc1_terraform_sg" {
  name        = "vpc1_terraform_sg"
  description = "vpc1_terraform_sg"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc01_id

  tags = (merge(local.common-tags, tomap({
    Name     = "terraform Enterprise SG"
    resource = "aws_security_group"
  })))
}

### Terraform Console Port ALL Port open ANY
resource "aws_security_group_rule" "vpc1_terraform_sg_rule_01" {
  from_port         = 8800
  protocol          = "tcp"
  security_group_id = aws_security_group.vpc1_terraform_sg.id
  to_port           = 8800
  type              = "ingress"
  cidr_blocks       = ["211.119.11.200/32"]
}
########################################## (END) VPC1 Terraform Enterprise SG ###########################################