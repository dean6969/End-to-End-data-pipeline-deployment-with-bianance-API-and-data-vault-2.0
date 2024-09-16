resource "aws_s3_bucket" "binance_streaming_bucket" {
  bucket = "stream-binance-from-ed-test1"  
  acl = "private"
  force_destroy = true
}

resource "aws_s3_bucket" "athena_results_bucket" {
  bucket = "athena-ed169503-${var.env_name}-${var.project_name}"
  force_destroy = true
}