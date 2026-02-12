# Guia de Deploy

Este guia detalha como fazer o deploy completo do pipeline de ingestão de dados CSV para Data Lake na AWS.

## Pré-requisitos

### 1. Ferramentas Necessárias
- **AWS CLI** versão 2.x
- **Terraform** versão 1.0+
- **Python** versão 3.9+
- **Git**

### 2. Configuração da AWS CLI

```bash
# Configurar credenciais AWS
aws configure

# Verificar configuração
aws sts get-caller-identity
```

### 3. Variáveis de Ambiente

Copie o arquivo de exemplo e configure:

```bash
cp .env.example .env
```

Edite o arquivo `.env` com suas configurações:

```bash
AWS_REGION=us-east-1
AWS_ACCOUNT_ID=123456789012
RAW_BUCKET_NAME=meu-raw-bucket-unico
DATA_LAKE_BUCKET_NAME=meu-datalake-bucket-unico
```

**Importante**: Nomes de buckets S3 devem ser globalmente únicos!

## Passo 1: Preparação do Ambiente Local

### 1.1 Clonar/Criar o Projeto

```bash
cd pipeline_de_ingestão_de_dados_csv_para_data_lake
```

### 1.2 Criar Ambiente Virtual Python

No Windows PowerShell:
```powershell
python -m venv venv
.\venv\Scripts\Activate.ps1
```

No Linux/Mac:
```bash
python3 -m venv venv
source venv/bin/activate
```

### 1.3 Instalar Dependências

```bash
pip install -r requirements.txt
```

### 1.4 Executar Testes (Opcional)

```bash
pytest tests/ -v
```

## Passo 2: Deploy da Infraestrutura com Terraform

### 2.1 Configurar Variáveis do Terraform

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edite `terraform.tfvars`:

```hcl
aws_region = "us-east-1"
environment = "dev"
project_name = "csv-data-lake-pipeline"

# IMPORTANTE: Escolha nomes únicos
raw_bucket_name = "seu-raw-bucket-123456"
data_lake_bucket_name = "seu-datalake-bucket-123456"

lambda_memory_size = 512
lambda_timeout = 300
enable_xray = true
log_retention_days = 7
```

### 2.2 Inicializar Terraform

```bash
terraform init
```

### 2.3 Planejar Deploy

```bash
terraform plan
```

Revise cuidadosamente o plano para garantir que todos os recursos estão corretos.

### 2.4 Aplicar Infraestrutura

```bash
terraform apply
```

Digite `yes` quando solicitado.

**Tempo estimado**: 3-5 minutos

### 2.5 Verificar Outputs

```bash
terraform output
```

Você verá informações importantes como:
- Nomes dos buckets criados
- ARN da função Lambda
- Nome do Glue Crawler
- Dashboard do CloudWatch

## Passo 3: Deploy das Funções Lambda

### Opção A: Deploy Automático via Terraform

O Terraform já faz o deploy da Lambda! Pule para o Passo 4.

### Opção B: Deploy Manual (atualização)

Se você atualizou o código e quer fazer redeploy:

**No Windows PowerShell:**
```powershell
cd ..\src\lambda_functions
.\deploy.ps1
```

**No Linux/Mac:**
```bash
cd ../src/lambda_functions
chmod +x deploy.sh
./deploy.sh
```

## Passo 4: Configurar Notificações (Opcional)

### 4.1 Subscrever Email ao SNS

```bash
# Obter ARN do tópico SNS
SNS_TOPIC_ARN=$(terraform output -raw sns_topic_arn)

# Criar subscription
aws sns subscribe \
  --topic-arn $SNS_TOPIC_ARN \
  --protocol email \
  --notification-endpoint seu-email@exemplo.com
```

Você receberá um email de confirmação. Clique no link para confirmar.

## Passo 5: Testar o Pipeline

### 5.1 Criar Arquivo CSV de Teste

```bash
cat > test_data.csv << EOF
id,name,email,age,city
1,Alice,alice@email.com,30,São Paulo
2,Bob,bob@email.com,25,Rio de Janeiro
3,Charlie,charlie@email.com,35,Belo Horizonte
EOF
```

### 5.2 Upload para S3

```bash
# Obter nome do bucket raw
RAW_BUCKET=$(terraform output -raw raw_bucket_name)

# Upload do arquivo
aws s3 cp test_data.csv s3://${RAW_BUCKET}/input/test_data.csv
```

### 5.3 Monitorar Processamento

```bash
# Obter nome da função Lambda
LAMBDA_NAME=$(terraform output -raw lambda_function_name)

# Acompanhar logs em tempo real
aws logs tail /aws/lambda/${LAMBDA_NAME} --follow
```

### 5.4 Verificar Resultado

```bash
# Listar arquivos no Data Lake
DATA_LAKE_BUCKET=$(terraform output -raw data_lake_bucket_name)

aws s3 ls s3://${DATA_LAKE_BUCKET}/processed/ --recursive
```

## Passo 6: Executar Glue Crawler

### 6.1 Executar Manualmente

```bash
# Obter nome do crawler
CRAWLER_NAME=$(terraform output -raw glue_crawler_name)

# Iniciar crawler
aws glue start-crawler --name ${CRAWLER_NAME}

# Verificar status
aws glue get-crawler --name ${CRAWLER_NAME}
```

### 6.2 Verificar Catálogo

```bash
# Obter nome do database
DATABASE_NAME=$(terraform output -raw glue_database_name)

# Listar tabelas
aws glue get-tables --database-name ${DATABASE_NAME}
```

## Passo 7: Consultar Dados com Athena

### 7.1 Configurar Athena (primeira vez)

```bash
# Criar bucket para resultados do Athena
aws s3 mb s3://seu-athena-results-bucket

# Configurar localização dos resultados
aws athena update-work-group \
  --work-group primary \
  --configuration-updates \
  "ResultConfigurationUpdates={OutputLocation=s3://seu-athena-results-bucket/}"
```

### 7.2 Executar Query de Teste

Via AWS Console:
1. Acesse Amazon Athena
2. Selecione o database criado pelo Glue
3. Execute query:

```sql
SELECT * FROM sua_tabela LIMIT 10;
```

Via CLI:
```bash
aws athena start-query-execution \
  --query-string "SELECT * FROM sua_tabela LIMIT 10" \
  --query-execution-context Database=${DATABASE_NAME} \
  --result-configuration OutputLocation=s3://seu-athena-results-bucket/
```

## Passo 8: Configurar CloudWatch Dashboard

### 8.1 Acessar Dashboard

```bash
# URL do dashboard
echo "https://console.aws.amazon.com/cloudwatch/home?region=${AWS_REGION}#dashboards:name=$(terraform output -raw cloudwatch_dashboard_name)"
```

### 8.2 Configurar Alarmes Adicionais (Opcional)

Edite `terraform/monitoring.tf` e adicione alarmes customizados.

## Verificação Final

Execute este checklist para garantir que tudo está funcionando:

- [ ] Buckets S3 criados e configurados
- [ ] Função Lambda deployada e testada
- [ ] Evento S3 acionando Lambda corretamente
- [ ] Arquivos sendo processados e salvos no Data Lake
- [ ] Glue Crawler catalogando dados
- [ ] CloudWatch Dashboard mostrando métricas
- [ ] Alarmes configurados e funcionando
- [ ] Notificações SNS recebidas (se configurado)
- [ ] Athena consultando dados com sucesso

## Troubleshooting

### Erro: Bucket já existe
```
Error: Error creating S3 bucket: BucketAlreadyExists
```
**Solução**: Escolha nomes de buckets únicos no `terraform.tfvars`

### Erro: Lambda timeout
```
Task timed out after 300.00 seconds
```
**Solução**: Aumente `lambda_timeout` no `terraform.tfvars`

### Erro: Permissões negadas
```
An error occurred (AccessDenied)
```
**Solução**: Verifique IAM roles e policies. Execute `aws sts get-caller-identity`

### Logs não aparecem
**Solução**: Aguarde alguns segundos. Logs podem demorar 10-30 segundos para aparecer.

### Crawler não encontra dados
**Solução**: 
1. Verifique se o processamento Lambda foi bem-sucedido
2. Confirme que arquivos Parquet estão no caminho correto
3. Execute o crawler manualmente

## Rollback

Se algo der errado, você pode destruir toda a infraestrutura:

```bash
cd terraform
terraform destroy
```

Digite `yes` quando solicitado.

**Atenção**: Isso deletará todos os recursos, incluindo buckets S3 com dados!

## Próximos Passos

- Configurar CI/CD para deploys automatizados
- Implementar testes de integração end-to-end
- Configurar backup e disaster recovery
- Implementar monitoramento avançado com X-Ray
- Otimizar custos revisando métricas

## Suporte

Para problemas ou dúvidas:
1. Verifique os logs no CloudWatch
2. Revise a documentação em `/docs`
3. Abra uma issue no repositório
