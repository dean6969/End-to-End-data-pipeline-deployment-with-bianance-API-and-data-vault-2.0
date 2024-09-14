resource "aws_s3_bucket" "binance_streaming_bucket" {
  bucket = "stream-binance-from-ed"  
  acl = "private"
  force_destroy = true
}