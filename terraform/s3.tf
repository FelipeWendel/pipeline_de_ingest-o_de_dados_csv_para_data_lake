# Bucket S3 para Dados Brutos
resource "aws_s3_bucket" "raw_data" {
  bucket = var.raw_bucket_name
}

# Criptografia Raw
resource "aws_s3_bucket_server_side_encryption_configuration" "raw_data" {
  bucket = aws_s3_bucket.raw_data.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bloqueio de acesso público Raw
resource "aws_s3_bucket_public_access_block" "raw_data" {
  bucket                  = aws_s3_bucket.raw_data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket S3 Data Lake
resource "aws_s3_bucket" "data_lake" {
  bucket = var.data_lake_bucket_name
}

# Criptografia Data Lake
resource "aws_s3_bucket_server_side_encryption_configuration" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bloqueio de acesso público Data Lake
resource "aws_s3_bucket_public_access_block" "data_lake" {
  bucket                  = aws_s3_bucket.data_lake.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Notificação S3 → Lambda
resource "aws_s3_bucket_notification" "raw_data_notification" {
  bucket = aws_s3_bucket.raw_data.id
  
  lambda_function {
    lambda_function_arn = aws_lambda_function.csv_ingestor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".csv"
  }
  
  depends_on = [aws_lambda_permission.allow_s3]
}
  lambda_function {
    lambda_function_arn = aws_lambda_function.csv_ingestor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "input/"
    filter_suffix       = ".csv"
  }
  
  depends_on = [aws_lambda_permission.allow_s3]
}
