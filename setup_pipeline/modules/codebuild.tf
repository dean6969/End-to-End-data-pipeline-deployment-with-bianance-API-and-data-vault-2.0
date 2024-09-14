# Tạo CodeBuild Project
resource "aws_codebuild_project" "my_codebuild_project" {
  name          = "${var.project_name}-codebuild-project-${var.env_name}"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = 5

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"  # Liên kết với CodePipeline
    buildspec = "buildspec.yml" # Trỏ đến tệp buildspec.yml
  }

  artifacts {
    type = "CODEPIPELINE"
  }
}

# IAM Role cho CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name = "${var.project_name}-codebuild-role-${var.env_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "codebuild.amazonaws.com"
      }
    }]
  })
}

# Gắn chính sách cho CodeBuild để có quyền truy cập vào các dịch vụ AWS
resource "aws_iam_role_policy_attachment" "codebuild_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy" "codebuild_logs_policy" {
  name = "${var.project_name}-codebuild-logs-policy-${var.env_name}"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:log-group:/aws/codebuild/*"
      }
    ]
  })
}

# Gắn chính sách cho CodeBuild để có quyền truy cập IAM, Kinesis và Lambda
resource "aws_iam_role_policy" "codebuild_policy" {
  name = "${var.project_name}-codebuild-policy-${var.env_name}"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          # IAM permissions
          "iam:CreateRole",
				"iam:AttachRolePolicy",
				"iam:PutRolePolicy",
				"iam:PassRole",
				"iam:GetRole",
				"iam:ListRolePolicies",
				"iam:ListAttachedRolePolicies",
				"iam:PutRolePolicy",
				"iam:ListInstanceProfilesForRole",
				"iam:DetachRolePolicy",
				"iam:DeleteRole",
				"iam:ListAttachedUserPolicies",
				"iam:ListPolicyVersions"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          # Kinesis permissions
          	"kinesis:DescribeStream",
          "kinesis:DescribeStreamSummary",
          "kinesis:GetRecords",
          "kinesis:GetShardIterator",
          "kinesis:ListShards",
          "kinesis:ListStreams",
          "kinesis:SubscribeToShard",
          "kinesis:createStream",
          "kinesis:DeleteStream"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          # Lambda permissions
          "lambda:CreateFunction",
          "lambda:UpdateFunctionCode",
          "lambda:InvokeFunction",
          "lambda:DeleteFunction",
          "lambda:GetFunction",
          "lambda:ListVersionsByFunction"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          # S3 permissions (nếu cần)
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_policy_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}