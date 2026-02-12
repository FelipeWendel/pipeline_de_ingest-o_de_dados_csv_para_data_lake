# Exemplo de arquivo terraform.tfvars
# Copie este arquivo para terraform.tfvars e ajuste os valores

aws_region = "us-east-1"
environment = "dev"
project_name = "csv-data-lake-pipeline"

# IMPORTANTE: Nomes de buckets S3 devem ser globalmente únicos
raw_bucket_name = "meu-raw-data-bucket-123456"
data_lake_bucket_name = "meu-data-lake-bucket-123456"

lambda_memory_size = 512
lambda_timeout = 300

enable_xray = true
log_retention_days = 7
