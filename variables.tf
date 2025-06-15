# --- variables.tf (最終版) ---

# -- General --
variable "aws_region" {
  type        = string
  description = "デプロイするAWSリージョン"
  default     = "ap-northeast-1"
}

variable "common_tags" {
  type        = map(string)
  description = "全てのリソースに適用する共通タグ"
  default     = {}
}

# -- S3 --
variable "upload_bucket_name" {
  type        = string
  description = "ファイルアップロード用のS3バケット名（全世界でユニークに）"
}

variable "site_bucket_name" {
  type        = string
  description = "静的サイトホスティング用のS3バケット名（全世界でユニークに）"
}

# -- DynamoDB --
variable "dynamodb_table_name" {
  type        = string
  description = "メタデータ保存用のDynamoDBテーブル名"
}

# -- IAM --
variable "presigned_url_lambda_role_name" {
  type        = string
  description = "署名付きURL生成Lambda用のIAMロール名"
}
variable "presigned_url_lambda_policy_name" {
  type        = string
  description = "署名付きURL生成Lambda用のIAMポリシー名"
}
variable "save_metadata_lambda_role_name" {
  type        = string
  description = "メタデータ保存Lambda用のIAMロール名"
}
variable "save_metadata_lambda_policy_name" {
  type        = string
  description = "メタデータ保存Lambda用のIAMポリシー名"
}
variable "list_files_lambda_role_name" {
  type        = string
  description = "ファイル一覧取得Lambda用のIAMロール名"
}
variable "list_files_lambda_policy_name" {
  type        = string
  description = "ファイル一覧取得Lambda用のIAMポリシー名"
}

# -- Lambda --
variable "presigned_url_lambda_name" {
  type        = string
  description = "署名付きURL生成Lambda関数の名前"
}
variable "save_metadata_lambda_name" {
  type        = string
  description = "メタデータ保存Lambda関数の名前"
}
variable "list_files_lambda_name" {
  type        = string
  description = "ファイル一覧取得Lambda関数の名前"
}

# -- API Gateway --
variable "api_name" {
  type        = string
  description = "API Gateway (HTTP API)の名前"
}
variable "api_route_key_presigned_url" {
  type        = string
  description = "署名付きURL生成APIのルートキー"
  default     = "POST /generate-presigned-url"
}
variable "api_route_key_list_files" {
  type        = string
  description = "ファイル一覧取得APIのルートキー"
  default     = "GET /files"
}
# variables.tf に追記
variable "api_stage_name" {
  description = "The name of the API Gateway stage"
  type        = string
  default     = "$default" # デフォルトのステージ名を使う場合
}