resource "aws_s3_bucket" "KP1DataBucket" {
  bucket = "stream-binance-from-ed"  
  acl = "private"
  force_destroy = true
}