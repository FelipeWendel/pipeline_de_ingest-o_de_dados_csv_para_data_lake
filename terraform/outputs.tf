output "raw_bucket_name" {
  description = "Nome do bucket S3 para dados brutos"
  value       = aws_s3_bucket.raw_data.id
}

output "raw_bucket_arn" {
  description = "ARN do bucket S3 para dados brutos"
  value       = aws_s3_bucket.raw_data.arn
}

output "data_lake_bucket_name" {
  description = "Nome do bucket S3 do Data Lake"
  value       = aws_s3_bucket.data_lake.id
}

output "data_lake_bucket_arn" {
  description = "ARN do bucket S3 do Data Lake"
  value       = aws_s3_bucket.data_lake.arn
}

output "lambda_function_name" {
  description = "Nome da função Lambda"
  value       = aws_lambda_function.csv_ingestor.function_name
}

output "lambda_function_arn" {
  description = "ARN da função Lambda"
  value       = aws_lambda_function.csv_ingestor.arn
}

output "glue_database_name" {
  description = "Nome do banco de dados no Catálogo Glue"
  value       = aws_glue_catalog_database.data_lake.name
}

output "glue_crawler_name" {
  description = "Nome do Glue Crawler"
  value       = aws_glue_crawler.data_lake_crawler.name
}

output "sns_topic_arn" {
  description = "ARN do tópico SNS para notificações"
  value       = aws_sns_topic.pipeline_notifications.arn
}

output "cloudwatch_dashboard_name" {
  description = "Nome do dashboard do CloudWatch"
  value       = aws_cloudwatch_dashboard.pipeline_dashboard.dashboard_name
}

output "deployment_instructions" {
  description = "Instruções para implantação"
  value = <<-EOT
    
    ========================================
    Pipeline de Ingestão CSV - Informações de Implantação
    ========================================
    
    1. Upload de arquivos CSV:
       aws s3 cp seu-arquivo.csv s3://${aws_s3_bucket.raw_data.id}/input/
    
    2. Monitorar logs:
       aws logs tail /aws/lambda/${aws_lambda_function.csv_ingestor.function_name} --follow
    
    3. Executar Crawler:
       aws glue start-crawler --name ${aws_glue_crawler.data_lake_crawler.name}
    
    4. Dashboard CloudWatch:
       https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.pipeline_dashboard.dashboard_name}
    
    5. Consultar dados no Athena:
       Banco de dados: ${aws_glue_catalog_database.data_lake.name}
       Tabelas criadas automaticamente após execução do Crawler
    
    ========================================
  EOT
}
