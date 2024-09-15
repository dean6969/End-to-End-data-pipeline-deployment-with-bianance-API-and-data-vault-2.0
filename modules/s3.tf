resource "aws_s3_bucket" "binance_streaming_bucket" {
  bucket = "stream-binance-from-ed-test1"  
  acl = "private"
  force_destroy = true
}