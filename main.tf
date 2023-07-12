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

resource "aws_security_group" "public_vm_sg" {
  name        = "public_vm_sg"
  description = "INSIDE_AWS_Public_VM_Security_GROUP"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc01_id

  tags = local.common-tags
}

resource "aws_security_group_rule" "public_sg_rule_01" {
  from_port = 22
  protocol = "tcp"
  security_group_id = aws_security_group.public_vm_sg.id
  to_port = 0
  type = "ingress"
}