# Grupo de Logs CloudWatch para Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.project_name}-csv-ingestor"
  retention_in_days = 7
}

# Alarme para erros na Lambda
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.project_name}-lambda-erros"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  
  dimensions = {
    FunctionName = aws_lambda_function.csv_ingestor.function_name
  }
}
