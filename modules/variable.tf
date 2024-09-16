variable env_name {
  description = "The name of the environment"
  type        = string
  default = "dev"
}

variable project_name {
  description = "The name of the project"
  type        = string
  default = "binance"
}

variable "aws_region" {
  default = "ap-southeast-2"
}