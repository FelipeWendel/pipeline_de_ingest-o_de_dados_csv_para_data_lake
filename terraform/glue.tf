# Banco de Dados do Catálogo Glue
resource "aws_glue_catalog_database" "data_lake" {
  name        = "${var.project_name}_db"
  description = "Banco de dados para Data Lake de arquivos CSV"
  
  tags = {
    Name = "Banco de Dados Data Lake"
  }
}

# Glue Crawler para catalogar dados do Data Lake
resource "aws_glue_crawler" "data_lake_crawler" {
  name          = "${var.project_name}-crawler"
  role          = aws_iam_role.glue_crawler.arn
  database_name = aws_glue_catalog_database.data_lake.name
  
  s3_target {
    path = "s3://${aws_s3_bucket.data_lake.id}/processed/"
  }
  
  schedule = "cron(0 2 * * ? *)" # Executa diariamente às 2h da manhã UTC
  
  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }
  
  configuration = jsonencode({
    Version = 1.0
    CrawlerOutput = {
      Partitions = {
        AddOrUpdateBehavior = "InheritFromTable"
      }
    }
  })
  
  tags = {
    Name = "Crawler do Data Lake"
  }
}
