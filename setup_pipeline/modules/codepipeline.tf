# create a CodePipeline
resource "aws_codepipeline" "codepipeline" {
  name     = "${var.project_name}-tf-test-pipeline-${var.env_name}"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  # build stage to trigger github for version control
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = "arn:aws:codeconnections:ap-southeast-2:851725259561:connection/fe73b3c4-4e09-458e-8d27-8dce3430530d"
        FullRepositoryId = "dean6969/airflow-deployment-with-codepipeline-and-ec2"
        BranchName       = "main"
      }
    }
  }

  # build stage to trigger codebuild
  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      output_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.my_codebuild_project.name
      }
    }
  }

  # deploy stage to trigger codedeploy
  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ApplicationName     = aws_codedeploy_app.my_app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.my_deployment_group.deployment_group_name
      }
    }
  }
}

# create a S3 bucket for CodePipeline
resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${var.project_name}-codepipeline-deploy-ec2-test-pipeline12-${var.env_name}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "codepipeline_bucket_pab" {
  bucket = aws_s3_bucket.codepipeline_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "${var.project_name}-pipeline-role-${var.env_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.codepipeline_bucket.arn,
      "${aws_s3_bucket.codepipeline_bucket.arn}/*"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["codestar-connections:UseConnection"]
    resources = ["arn:aws:codeconnections:ap-southeast-2:851725259561:connection/fe73b3c4-4e09-458e-8d27-8dce3430530d"]
  }

  statement {
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = ["*"]
  }

  # Thêm quyền CodeDeploy cho CodePipeline
  statement {
    effect = "Allow"

    actions = [
        "codedeploy:*"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "${var.project_name}-codepipeline-policy-${var.env_name}"
  role   = aws_iam_role.codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}