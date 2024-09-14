provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "terraform-state-chung1"
    key    = "state-file-key"
    region = "us-east-1"
  }
}

module "streamingmodule" {
  source = "./modules"
}

output "name" {
  description = "Kinesis stream name"
  value       = module.streamingmodule.kinesis_stream_name
}