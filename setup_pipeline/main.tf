provider "aws" {
  region = "ap-southeast-2"
}

terraform {
  backend "s3" {
    bucket = "state-tf-chung"
    key    = "state-file-key-local"
    region = "ap-southeast-2"
  }
}


module "pipelinemodule" {
  source = "./modules"
}



