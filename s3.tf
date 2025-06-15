# --- s3.tf ---

resource "aws_s3_bucket" "upload_bucket" {
  bucket = var.upload_bucket_name
  tags   = var.common_tags
}
resource "aws_s3_bucket_versioning" "upload_bucket_versioning" {
  bucket = aws_s3_bucket.upload_bucket.id
  versioning_configuration { status = "Enabled" }
}
resource "aws_s3_bucket_cors_configuration" "upload_bucket_cors" {
  bucket = aws_s3_bucket.upload_bucket.id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
  }
}

# --- S3 Event Trigger & Permission ---
resource "aws_s3_bucket_notification" "upload_notification" {
  bucket = aws_s3_bucket.upload_bucket.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.save_metadata_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_lambda_permission.allow_s3_invoke_save_metadata_lambda]
}
resource "aws_lambda_permission" "allow_s3_invoke_save_metadata_lambda" {
  statement_id  = "AllowS3InvokeSaveMetadata"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.save_metadata_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.upload_bucket.arn
}