# --- apigateway.tf ---

# --- API Gateway (HTTP API) 本体とステージ ---
resource "aws_apigatewayv2_api" "uploader_api" {
  name          = var.api_name
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["*"] # 本番ではフロントエンドのドメインに限定
    allow_methods = ["*"]
    allow_headers = ["*"]
  }
  tags = var.common_tags
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.uploader_api.id
  name        = var.api_stage_name
  auto_deploy = true
  tags        = var.common_tags
}

# --- 「署名付きURL生成」用のルートと接続設定 ---
resource "aws_apigatewayv2_integration" "presigned_url_integration" {
  api_id                 = aws_apigatewayv2_api.uploader_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.presigned_url_lambda.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "presigned_url_route" {
  api_id    = aws_apigatewayv2_api.uploader_api.id
  route_key = var.api_route_key_presigned_url
  target    = "integrations/${aws_apigatewayv2_integration.presigned_url_integration.id}"
}

resource "aws_lambda_permission" "api_gw_invoke_presigned_url_lambda" {
  statement_id  = "AllowAPIGatewayInvokePresignedUrl"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.presigned_url_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.uploader_api.execution_arn}/*/*"
}

# --- 「ファイル一覧取得」用のルートと接続設定 ---
resource "aws_apigatewayv2_integration" "list_files_integration" {
  api_id                 = aws_apigatewayv2_api.uploader_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.list_files_lambda.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "list_files_route" {
  api_id    = aws_apigatewayv2_api.uploader_api.id
  route_key = var.api_route_key_list_files
  target    = "integrations/${aws_apigatewayv2_integration.list_files_integration.id}"
}

resource "aws_lambda_permission" "api_gw_invoke_list_files_lambda" {
  statement_id  = "AllowAPIGatewayInvokeListFiles"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_files_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.uploader_api.execution_arn}/*/*"
}