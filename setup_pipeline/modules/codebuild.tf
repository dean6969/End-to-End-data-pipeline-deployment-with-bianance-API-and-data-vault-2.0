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
    type      = "CODEPIPELINE"  
    buildspec = "buildspec.yml" 
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

# attach policy to codebuild role
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

# attach policy for codebuild to access kinesis
resource "aws_iam_role_policy_attachment" "codebuild_kinesis_policy_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisFullAccess"
}

# attach policy for codebuild to access lambda and cloudwatch
resource "aws_iam_role_policy_attachment" "codebuild_policy_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# attach policy for codebuild to access IAM role
resource "aws_iam_role_policy_attachment" "codebuild_IAM_access" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

# attach policy for codebuild to access lambda
resource "aws_iam_role_policy_attachment" "codebuild_lambda_policy_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}

# attach policy for codebuild to access lambda
resource "aws_iam_role_policy_attachment" "Glue_policy_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# attach policy for codebuild to access lambda
resource "aws_iam_role_policy_attachment" "Athena_policy_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAthenaFullAccess"
}

# attach policy for codebuild to access lambda
resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}