# Create zip file for lambda function source code
data "archive_file" "lambda_function_file" {
  type = "zip"
  source_file = "src/lambda_function/consumer.py"
  output_path = "src/lambda_function/consumer.zip"
}
# create lambda function 
resource "aws_lambda_function" "binance_consumer" {
  function_name = "binance_consumer"
  handler       = "consumer.lambda_handler"
  role          = aws_iam_role.binance_consumer_Role.arn
  runtime       = "python3.8"
  # Add the environment variable for the stage
  environment {
    variables = {
      STAGE = "dev"
    }
  }
  # Use the output_path of the archive_file data source
  filename         = data.archive_file.lambda_function_file.output_path  # Use the output_path of the archive_file data source
  source_code_hash = data.archive_file.lambda_function_file.output_base64sha256
}

# create lambda event trigger by kinesis stream
resource "aws_lambda_event_source_mapping" "binance_consumer_mapping" {
  event_source_arn  = aws_kinesis_stream.binance_stream.arn
  function_name     = aws_lambda_function.binance_consumer.arn
  starting_position = "LATEST"
  batch_size        = 1
  maximum_batching_window_in_seconds = 2
}

