




resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.binance_streaming_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "${aws_iam_role.glue_crawler_role.arn}"
        },
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "${aws_s3_bucket.binance_streaming_bucket.arn}",
          "${aws_s3_bucket.binance_streaming_bucket.arn}/*"
        ]
      }
    ]
  })
}


resource "aws_iam_role" "glue_crawler_role" {
  name = "glue-crawler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_role_policy" "glue_crawler_policy" {
  role = aws_iam_role.glue_crawler_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {

        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject"
        ],
        Effect = "Allow",
        Resource = [
          "${aws_s3_bucket.binance_streaming_bucket.arn}",
          "${aws_s3_bucket.binance_streaming_bucket.arn}/*"
        ]
      },
      {

        Action = [
          "glue:*"  # Cấp quyền đầy đủ cho Glue
        ],
        Effect = "Allow",
        Resource = "*"
      },
      {

        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect = "Allow",
        Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws-glue/*"
      },
      {

        Action = [
          "athena:StartQueryExecution",
          "athena:StopQueryExecution",
          "athena:GetQueryExecution",
          "athena:GetQueryResults",
          "athena:CreateNamedQuery",
          "athena:DeleteNamedQuery",
          "athena:ListNamedQueries",
          "athena:BatchGetNamedQuery"
        ],
        Effect = "Allow",
        Resource = "*"
      },
      {

        Action = [
          "glue:GetDatabase",
          "glue:GetTable",
          "glue:CreateTable",
          "glue:UpdateTable",
          "glue:DeleteTable",
          "glue:BatchCreatePartition",
          "glue:GetPartition",
          "glue:BatchDeletePartition"
        ],
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}




resource "aws_glue_crawler" "json_crawler" {
  name         = "${var.project_name}-json-data-crawler-${var.env_name}"
  role         = aws_iam_role.glue_crawler_role.arn
  database_name = "my_glue_database"  # Tên database trong Glue Catalog


  s3_target {
    path = aws_s3_bucket.binance_streaming_bucket.bucket
  }


  schedule = "cron(0 * * * ? *)"  # Chạy crawler mỗi giờ
}


data "aws_caller_identity" "current" {}






