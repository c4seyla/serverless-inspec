variable "region" {
  description = "The AWS region to depoy to"
  default     = "eu-west-2"
}

variable "instance_type" {
  description = "The type of instance to start"
  default     = "t3a.small"
}

variable "key_name" {
  description = "The key name to use for the instance"
  default     = ""
}

variable "subnet_id" {
  description = "The VPC Subnet ID to launch in"
  default     = ""
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with"
  type        = list(string)
}