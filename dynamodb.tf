# --- dynamodb.tf ---

# メタデータ保存用のDynamoDBテーブル
resource "aws_dynamodb_table" "metadata_table" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST" # オンデマンド課金
  hash_key     = "fileId"          # パーティションキー

  attribute {
    name = "fileId"
    type = "S" # String (文字列)
  }
}