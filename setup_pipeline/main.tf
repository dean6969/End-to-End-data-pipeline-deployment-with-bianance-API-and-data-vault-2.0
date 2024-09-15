provider "aws" {
  region = "ap-southeast-2"
}


terraform {
  backend "s3" {
    bucket = "terraform-state-chung2"
    key    = "state-file-key-local-setup"
    region = "ap-southeast-2"
  }
}

module "pipelinemodule" {
  source = "./modules"
}



