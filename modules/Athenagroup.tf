resource "aws_athena_workgroup" "athena_workgroup" {
  name = "athena-workgroup-${var.env_name}-${var.project_name}"  
  force_destroy = true

  configuration {
    enforce_workgroup_configuration = true  

    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_results_bucket.bucket}/results/"
    }
  }
}