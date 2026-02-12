variable "aws_region" {
  description = "Região AWS para implantação"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "csv-data-lake-pipeline"
}

variable "raw_bucket_name" {
  description = "Nome do bucket S3 para dados brutos"
  type        = string
}

variable "data_lake_bucket_name" {
  description = "Nome do bucket S3 para Data Lake"
  type        = string
}

variable "lambda_memory_size" {
  description = "Memória da função Lambda em MB"
  type        = number
  default     = 512
}

variable "lambda_timeout" {
  description = "Timeout da função Lambda em segundos"
  type        = number
  default     = 300
}

variable "enable_xray" {
  description = "Habilitar AWS X-Ray para tracing"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Dias de retenção dos logs no CloudWatch"
  type        = number
  default     = 7
}
