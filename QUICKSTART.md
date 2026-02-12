# 🚀 Guia Rápido de Início

Comece a usar o Pipeline de Ingestão de Dados CSV em minutos!

## ⚡ Início Rápido (5 minutos)

### 1. Pré-requisitos

```bash
# Verificar instalações
python --version        # Python 3.9+
terraform --version     # Terraform 1.0+
aws --version          # AWS CLI 2.x

# Verificar credenciais AWS
aws sts get-caller-identity
```

### 2. Configuração Inicial

```powershell
# No Windows PowerShell

# Clonar/navegar para o projeto
cd pipeline_de_ingestão_de_dados_csv_para_data_lake

# Configurar ambiente virtual
python -m venv venv
.\venv\Scripts\Activate.ps1

# Instalar dependências
pip install -r requirements.txt

# Copiar arquivo de configuração
Copy-Item .env.example .env

# Editar .env com suas configurações
notepad .env
```

**Edite o arquivo `.env`:**
```bash
AWS_REGION=us-east-1
AWS_ACCOUNT_ID=SEU_ACCOUNT_ID
RAW_BUCKET_NAME=seu-raw-bucket-unico-123456
DATA_LAKE_BUCKET_NAME=seu-datalake-bucket-unico-123456
```

### 3. Deploy da Infraestrutura

```powershell
# Navegar para terraform
cd terraform

# Copiar e editar variáveis
Copy-Item terraform.tfvars.example terraform.tfvars
notepad terraform.tfvars

# Deploy
terraform init
terraform plan
terraform apply
# Digite 'yes' para confirmar
```

⏱️ **Aguarde 3-5 minutos** para o deploy completar.

### 4. Teste o Pipeline

```powershell
# Voltar para raiz do projeto
cd ..

# Upload de arquivo de teste
aws s3 cp data\sample\test_data.csv s3://seu-raw-bucket/input/

# Monitorar logs (em nova janela)
aws logs tail /aws/lambda/csv-data-lake-pipeline-csv-ingestor --follow

# Verificar resultado
aws s3 ls s3://seu-datalake-bucket/processed/ --recursive
```

🎉 **Pronto!** Seu pipeline está funcionando!

---

## 📚 Próximos Passos

### Consultar Dados com Athena

1. Acesse o [AWS Athena Console](https://console.aws.amazon.com/athena/)
2. Execute o Glue Crawler:
   ```powershell
   aws glue start-crawler --name csv-data-lake-pipeline-crawler
   ```
3. Aguarde o crawler finalizar (~2 minutos)
4. No Athena, selecione o database: `csv_data_lake_pipeline_db`
5. Execute query:
   ```sql
   SELECT * FROM sua_tabela LIMIT 10;
   ```

### Monitoramento

```powershell
# Ver dashboard
echo "https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:"

# Ver logs em tempo real
aws logs tail /aws/lambda/csv-data-lake-pipeline-csv-ingestor --follow

# Verificar métricas
aws cloudwatch get-metric-statistics `
  --namespace AWS/Lambda `
  --metric-name Invocations `
  --dimensions Name=FunctionName,Value=csv-data-lake-pipeline-csv-ingestor `
  --start-time 2024-01-01T00:00:00Z `
  --end-time 2024-12-31T23:59:59Z `
  --period 3600 `
  --statistics Sum
```

---

## 🛠️ Comandos Úteis

### Usando scripts.ps1 (Windows)

```powershell
# Ver todos os comandos
.\scripts.ps1 help

# Executar testes
.\scripts.ps1 test

# Limpar projeto
.\scripts.ps1 clean

# Upload de CSV
.\scripts.ps1 upload-csv seu-raw-bucket

# Listar Data Lake
.\scripts.ps1 list-datalake seu-datalake-bucket

# Ver logs
.\scripts.ps1 logs csv-data-lake-pipeline-csv-ingestor
```

### Terraform

```powershell
# Ver outputs
cd terraform
terraform output

# Ver estado
terraform show

# Atualizar infraestrutura
terraform apply

# Destruir tudo
terraform destroy
```

---

## 📁 Estrutura do Projeto

```
pipeline_de_ingestão_de_dados_csv_para_data_lake/
├── src/                          # Código fonte
│   ├── config/                  # Configurações
│   ├── ingestion/               # Lógica de ingestão
│   │   ├── csv_processor.py    # Processador CSV
│   │   └── pipeline.py         # Orquestrador
│   ├── lambda_functions/        # Funções Lambda
│   │   └── csv_ingestor.py     # Handler Lambda
│   └── utils/                   # Utilitários
│       ├── s3_utils.py         # Cliente S3
│       └── logger.py           # Logging
├── terraform/                    # Infraestrutura
│   ├── main.tf                 # Configuração principal
│   ├── s3.tf                   # Buckets S3
│   ├── lambda.tf               # Lambda functions
│   ├── glue.tf                 # Glue catalog
│   └── monitoring.tf           # CloudWatch
├── tests/                        # Testes
├── docs/                         # Documentação
│   ├── architecture.md         # Arquitetura
│   └── deployment.md           # Guia de deploy
├── data/sample/                  # Dados de exemplo
├── README.md                     # Documentação principal
└── requirements.txt              # Dependências Python
```

---

## 🔧 Troubleshooting Rápido

### Erro: Bucket já existe
```
Error: BucketAlreadyExists
```
**Solução**: Escolha nomes únicos em `terraform.tfvars`

### Lambda timeout
```
Task timed out after 300.00 seconds
```
**Solução**: Aumente `lambda_timeout` em `terraform.tfvars`

### Permissão negada
```
AccessDenied
```
**Solução**: Verifique IAM roles e AWS credentials
```powershell
aws sts get-caller-identity
aws iam list-roles
```

### Logs não aparecem
**Solução**: Aguarde 10-30 segundos. Logs podem demorar.

### Crawler não encontra dados
**Solução**: 
1. Verifique se Lambda processou o arquivo
2. Execute crawler manualmente
3. Verifique path no S3

---

## 📊 Workflow do Pipeline

```
1. Upload CSV → S3 Raw Bucket (input/)
           ↓
2. S3 Event → Trigger Lambda
           ↓
3. Lambda → Processa CSV
           ↓
4. Lambda → Salva Parquet no Data Lake (particionado)
           ↓
5. Glue Crawler → Cataloga dados
           ↓
6. Athena/Redshift → Consulta dados
```

---

## 🎯 Casos de Uso

### 1. Ingestão Diária de Vendas
```powershell
# Upload diário
aws s3 cp vendas_$(Get-Date -Format "yyyyMMdd").csv s3://seu-raw-bucket/input/
```

### 2. Processamento em Lote
```powershell
# Upload múltiplos arquivos
aws s3 sync ./arquivos_csv/ s3://seu-raw-bucket/input/
```

### 3. Integração com BI
- Configure Athena como data source no Power BI/Tableau
- Use Glue Catalog como metastore
- Consulte dados particionados para performance

---

## 📖 Documentação Completa

- [Arquitetura Detalhada](docs/architecture.md)
- [Guia de Deploy Completo](docs/deployment.md)
- [Como Contribuir](CONTRIBUTING.md)
- [Changelog](CHANGELOG.md)

---

## 🆘 Precisa de Ajuda?

1. Verifique os logs: `.\scripts.ps1 logs nome-da-funcao`
2. Consulte a [documentação completa](docs/)
3. Abra uma [issue](../../issues)

---

## ✅ Checklist de Validação

- [ ] AWS CLI configurado e funcionando
- [ ] Terraform instalado (versão 1.0+)
- [ ] Python 3.9+ instalado
- [ ] Arquivo `.env` configurado
- [ ] Arquivo `terraform.tfvars` configurado
- [ ] Infraestrutura deployada com sucesso
- [ ] Teste de upload de CSV bem-sucedido
- [ ] Lambda processou o arquivo
- [ ] Arquivo Parquet no Data Lake
- [ ] Glue Crawler executado
- [ ] Dados visíveis no Athena

---

**Bom uso do pipeline! 🚀**

Para dúvidas, consulte a [documentação completa](docs/) ou abra uma issue.
