provider "aws" {
  region = "ap-southeast-2"
}

terraform {
  backend "s3" {
    bucket = "terraform-state-chung2"
    key    = "state-file-key"
    region = "ap-southeast-2"
  }
}

module "streamingmodule" {
  source = "./modules"
}

output "name" {
  description = "Kinesis stream name"
  value       = module.streamingmodule.kinesis_stream_name
}