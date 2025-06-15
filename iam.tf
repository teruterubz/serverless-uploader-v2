# --- iam.tf (最終修正版) ---

locals {
  # 繰り返し使うAssume Role Policyをここで定義
  lambda_assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# --- 1. "Presigned URL Generator" Lambda用 ---
resource "aws_iam_role" "presigned_url_lambda_role" {
  name               = var.presigned_url_lambda_role_name
  assume_role_policy = local.lambda_assume_role_policy
  tags               = var.common_tags
}
resource "aws_iam_policy" "presigned_url_lambda_policy" {
  name   = var.presigned_url_lambda_policy_name
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"],
        Resource = ["${aws_s3_bucket.upload_bucket.arn}/*"]
      }
    ]
  })
  tags = var.common_tags
}
resource "aws_iam_role_policy_attachment" "presigned_url_lambda_attachment" {
  role       = aws_iam_role.presigned_url_lambda_role.name
  policy_arn = aws_iam_policy.presigned_url_lambda_policy.arn
}

# --- 2. "Save Metadata" Lambda用 ---
resource "aws_iam_role" "save_metadata_lambda_role" {
  name               = var.save_metadata_lambda_role_name
  assume_role_policy = local.lambda_assume_role_policy
  tags               = var.common_tags
}
resource "aws_iam_policy" "save_metadata_lambda_policy" {
  name   = var.save_metadata_lambda_policy_name
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect   = "Allow",
        Action   = ["dynamodb:PutItem"],
        Resource = aws_dynamodb_table.metadata_table.arn
      }
    ]
  })
  tags = var.common_tags
}
resource "aws_iam_role_policy_attachment" "save_metadata_lambda_attachment" {
  role       = aws_iam_role.save_metadata_lambda_role.name
  policy_arn = aws_iam_policy.save_metadata_lambda_policy.arn
}

# --- 3. "List Files" Lambda用 ---
resource "aws_iam_role" "list_files_lambda_role" {
  name               = var.list_files_lambda_role_name
  assume_role_policy = local.lambda_assume_role_policy
  tags               = var.common_tags
}
resource "aws_iam_policy" "list_files_lambda_policy" {
  name   = var.list_files_lambda_policy_name
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect   = "Allow",
        Action   = ["dynamodb:Scan"],
        Resource = aws_dynamodb_table.metadata_table.arn
      }
    ]
  })
  tags = var.common_tags
}
resource "aws_iam_role_policy_attachment" "list_files_lambda_attachment" {
  role       = aws_iam_role.list_files_lambda_role.name
  policy_arn = aws_iam_policy.list_files_lambda_policy.arn
}