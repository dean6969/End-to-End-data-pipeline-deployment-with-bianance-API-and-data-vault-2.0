provider "aws" {
  region = "us-east-1"
}


terraform {
  backend "s3" {
    bucket = "terraform-state-chung1"
    key    = "state-file-key-local-setup"
    region = "us-east-1"
  }
}

module "pipelinemodule" {
  source = "./modules"
}



