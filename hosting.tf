# --- hosting.tf ---

# --- Static Site Hosting Bucket ---
resource "aws_s3_bucket" "site_bucket" {
  bucket = var.site_bucket_name
  tags   = var.common_tags
}

# --- 静的サイトホスティング設定 ---
resource "aws_s3_bucket_website_configuration" "site_website_config" {
  bucket = aws_s3_bucket.site_bucket.id
  index_document {
    suffix = "index.html"
  }
}

# --- パブリックアクセスを許可するための設定 ---
resource "aws_s3_bucket_public_access_block" "site_public_access_block" {
  bucket                  = aws_s3_bucket.site_bucket.id
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "site_bucket_policy" {
  bucket = aws_s3_bucket.site_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "s3:GetObject",
      Effect    = "Allow",
      Principal = "*",
      Resource  = "${aws_s3_bucket.site_bucket.arn}/*",
    }]
  })
    # ↓↓↓ このブロックを追記してください ↓↓↓
  depends_on = [
    aws_s3_bucket_public_access_block.site_public_access_block
  ]
}

# --- フロントエンドのファイルをS3にアップロード ---
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.site_bucket.id
  key          = "index.html"
  source       = "${path.module}/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/index.html")
}

resource "aws_s3_object" "style_css" {
  bucket       = aws_s3_bucket.site_bucket.id
  key          = "style.css"
  source       = "${path.module}/style.css"
  content_type = "text/css"
  etag         = filemd5("${path.module}/style.css")
}

# --- hosting.tf の uploader.js のリソースをこれで置き換え ---

resource "aws_s3_object" "uploader_js" {
  bucket       = aws_s3_bucket.site_bucket.id
  key          = "uploader.js"
  source       = "${path.module}/uploader.js" # ローカルの uploader.js を直接指定
  content_type = "application/javascript"
  etag         = filemd5("${path.module}/uploader.js")
}