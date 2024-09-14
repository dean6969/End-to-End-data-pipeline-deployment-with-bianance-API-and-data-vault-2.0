# IAM roles and policies for the Kinesis Producer and Consumer Lambda functions
resource "aws_iam_role" "KP1ConsumerRole" {
  name = "KP1ConsumerRole"

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

# Create a policy for the KP1ConsumerRole
resource "aws_iam_role_policy" "KP1ConsumerPolicy" {
  name   = "KP1ConsumerPolicy"
  role   = aws_iam_role.KP1ConsumerRole.id
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
        Resource = aws_kinesis_stream.KP1DataStream.arn
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
          "${aws_s3_bucket.KP1DataBucket.arn}",
          "${aws_s3_bucket.KP1DataBucket.arn}/*"
        ]
      },
    ]
  })
}