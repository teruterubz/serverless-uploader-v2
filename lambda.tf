# --- lambda.tf ---

data "archive_file" "presigned_url_lambda_zip" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "presigned_url_lambda.zip"
}
resource "aws_lambda_function" "presigned_url_lambda" {
  function_name    = var.presigned_url_lambda_name
  role             = aws_iam_role.presigned_url_lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  filename         = data.archive_file.presigned_url_lambda_zip.output_path
  source_code_hash = data.archive_file.presigned_url_lambda_zip.output_base64sha256
  environment { variables = { S3_BUCKET_NAME = var.upload_bucket_name } }
  tags = var.common_tags
}

data "archive_file" "save_metadata_lambda_zip" {
  type        = "zip"
  source_file = "save_metadata_lambda.py"
  output_path = "save_metadata_lambda.zip"
}
resource "aws_lambda_function" "save_metadata_lambda" {
  function_name    = var.save_metadata_lambda_name
  role             = aws_iam_role.save_metadata_lambda_role.arn
  handler          = "save_metadata_lambda.lambda_handler"
  runtime          = "python3.11"
  filename         = data.archive_file.save_metadata_lambda_zip.output_path
  source_code_hash = data.archive_file.save_metadata_lambda_zip.output_base64sha256
  environment { variables = { DYNAMODB_TABLE_NAME = var.dynamodb_table_name } }
  tags = var.common_tags
}

data "archive_file" "list_files_lambda_zip" {
  type        = "zip"
  source_file = "list_files_lambda.py"
  output_path = "list_files_lambda.zip"
}
resource "aws_lambda_function" "list_files_lambda" {
  function_name    = var.list_files_lambda_name
  role             = aws_iam_role.list_files_lambda_role.arn
  handler          = "list_files_lambda.lambda_handler"
  runtime          = "python3.11"
  filename         = data.archive_file.list_files_lambda_zip.output_path
  source_code_hash = data.archive_file.list_files_lambda_zip.output_base64sha256
  environment { variables = { DYNAMODB_TABLE_NAME = var.dynamodb_table_name } }
  tags = var.common_tags
}