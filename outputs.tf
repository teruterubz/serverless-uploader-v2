# --- outputs.tf ---

output "portfolio_website_url" {
  description = "公開ウェブサイトのURL"
  value       = aws_s3_bucket_website_configuration.site_website_config.website_endpoint
}

output "api_endpoint" {
  description = "API GatewayのベースURL"
  value       = aws_apigatewayv2_stage.default_stage.invoke_url
}

output "upload_bucket_name" {
  description = "アップロード用S3バケット名"
  value       = aws_s3_bucket.upload_bucket.id
}

output "metadata_table_name" {
  description = "メタデータ用DynamoDBテーブル名"
  value       = aws_dynamodb_table.metadata_table.name
}