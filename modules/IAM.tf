# IAM roles and policies for the Kinesis Producer and Consumer Lambda functions
resource "aws_iam_role" "binance_consumer_Role" {
  name = "binance_consumer_Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
}

# Create a policy for the binance_consumer_Role
resource "aws_iam_role_policy" "binance_consumer_Policy" {
  name   = "binance_consumer_Policy"
  role   = aws_iam_role.binance_consumer_Role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kinesis:DescribeStream",
          "kinesis:DescribeStreamSummary",
          "kinesis:GetRecords",
          "kinesis:GetShardIterator",
          "kinesis:ListShards",
          "kinesis:ListStreams",
          "kinesis:SubscribeToShard"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.binance_streaming_bucket.arn}",
          "${aws_s3_bucket.binance_streaming_bucket.arn}/*"
        ]
      },
    ]
  })
}