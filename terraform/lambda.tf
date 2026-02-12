# Arquivo ZIP com o código Lambda
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src"
  output_path = "${path.module}/lambda_function.zip"
  excludes    = ["__pycache__", "*.pyc", ".pytest_cache"]
}

# Função Lambda para ingestão CSV
resource "aws_lambda_function" "csv_ingestor" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.project_name}-csv-ingestor"
  role            = aws_iam_role.lambda_execution.arn
  handler         = "lambda_functions.csv_ingestor.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime         = "python3.9"
  timeout         = 300
  memory_size     = 512
  
  environment {
    variables = {
      RAW_BUCKET_NAME       = aws_s3_bucket.raw_data.id
      DATA_LAKE_BUCKET_NAME = aws_s3_bucket.data_lake.id
      GLUE_DATABASE         = aws_glue_catalog_database.data_lake.name
    }
  }
  
  depends_on = [aws_cloudwatch_log_group.lambda_logs]
}

# Permissão S3 → Lambda
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.csv_ingestor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.raw_data.arn
}
