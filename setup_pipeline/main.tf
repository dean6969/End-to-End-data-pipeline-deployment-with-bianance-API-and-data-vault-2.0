provider "aws" {
  region = "us-east-1"
}


module "pipelinemodule" {
  source = "./modules"
}



