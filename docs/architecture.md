# Arquitetura do Pipeline

## Visão Geral

Este documento descreve a arquitetura do pipeline de ingestão de dados CSV para Data Lake na AWS.

## Componentes Principais

### 1. S3 Raw Bucket
- **Propósito**: Armazenamento inicial de arquivos CSV
- **Estrutura**:
  ```
  raw-bucket/
  ├── input/              # Arquivos novos para processamento
  ├── processed/original/ # Arquivos já processados
  └── failed/             # Arquivos com erro no processamento
  ```

### 2. AWS Lambda
- **Função**: `csv-ingestor`
- **Runtime**: Python 3.9
- **Trigger**: S3 Event (ObjectCreated)
- **Memória**: 512 MB (configurável)
- **Timeout**: 300 segundos (configurável)

#### Fluxo de Execução:
1. Recebe evento S3 com informações do arquivo
2. Valida tamanho e formato do arquivo
3. Lê e processa o CSV
4. Valida e limpa os dados
5. Adiciona metadados (timestamp, origem, particionamento)
6. Converte para formato Parquet
7. Salva no Data Lake com particionamento
8. Move arquivo original para `processed/` ou `failed/`

### 3. S3 Data Lake Bucket
- **Propósito**: Armazenamento de dados processados
- **Formato**: Parquet (formato columnar otimizado)
- **Particionamento**: Por data (year/month/day)
- **Estrutura**:
  ```
  data-lake-bucket/
  └── processed/
      └── year=2024/
          └── month=01/
              └── day=15/
                  └── arquivo.parquet
  ```

### 4. AWS Glue Catalog
- **Database**: data_lake_db
- **Crawler**: Executa diariamente às 2 AM UTC
- **Função**: Catalogar automaticamente novos dados e partições

### 5. Monitoramento

#### CloudWatch Logs
- Todos os logs das funções Lambda
- Retenção configurável (padrão: 7 dias)

#### CloudWatch Metrics
- Invocações da Lambda
- Erros e Throttles
- Duração de execução
- Tamanho dos dados processados

#### CloudWatch Alarms
- Alarme de erros (> 5 em 5 minutos)
- Alarme de throttling (> 10 em 5 minutos)

#### SNS Topics
- Notificações de alarmes
- Notificações de falhas no processamento

## Fluxo de Dados

```
┌──────────────────────────────────────────────────────────────┐
│                    Fluxo do Pipeline                         │
└──────────────────────────────────────────────────────────────┘

1. Upload CSV
   ↓
   Usuario/Sistema → S3 Raw Bucket (input/)
   
2. Trigger Lambda
   ↓
   S3 Event → Lambda Function (csv-ingestor)
   
3. Processamento
   ↓
   Lambda processa:
   - Lê CSV
   - Valida dados
   - Limpa dados
   - Adiciona metadados
   - Converte para Parquet
   
4. Armazenamento
   ↓
   Lambda → S3 Data Lake (particionado)
   
5. Catalogação
   ↓
   Glue Crawler → Glue Catalog (metadados)
   
6. Consulta
   ↓
   Athena/Redshift Spectrum → Query dos dados
```

## Formato de Dados

### Entrada (CSV)
```csv
id,name,email,age,city
1,Alice,alice@email.com,30,São Paulo
2,Bob,bob@email.com,25,Rio de Janeiro
```

### Saída (Parquet + Metadados)
```
Colunas originais: id, name, email, age, city
Colunas adicionadas:
- ingestion_timestamp: timestamp do processamento
- source_file: nome do arquivo original
- year: ano (para particionamento)
- month: mês (para particionamento)
- day: dia (para particionamento)
```

## Segurança

### IAM Roles e Policies
- **Lambda Execution Role**:
  - Leitura/Escrita em S3 (raw e data lake)
  - Escrita em CloudWatch Logs
  - Acesso ao Glue Catalog
  - Publicação em SNS

- **Glue Crawler Role**:
  - Leitura do Data Lake
  - Escrita no Glue Catalog

### S3 Security
- Criptografia em repouso (SSE-S3)
- Bloqueio de acesso público
- Versionamento habilitado
- Lifecycle policies para arquivamento

### Network Security
- Lambda em VPC (opcional, para acesso a recursos privados)
- VPC Endpoints para S3 e Glue (opcional, reduz custos)

## Escalabilidade

### Limites Atuais
- Lambda: 512 MB RAM, 300s timeout
- Tamanho máximo de arquivo: 100 MB (configurável)
- Concorrência Lambda: Default AWS (pode ser aumentado)

### Otimizações
- Processamento em lote para arquivos grandes
- Uso de AWS Lambda Layers para dependências
- Reserva de concorrência para cargas previsíveis
- Uso de Step Functions para workflows complexos

## Custos

### Componentes de Custo
1. **S3**: Armazenamento + Requisições
2. **Lambda**: Invocações + Duration (GB-seconds)
3. **Glue Crawler**: DPU-hours
4. **CloudWatch**: Logs + Metrics
5. **Data Transfer**: Minimal (mesma região)

### Otimizações de Custo
- S3 Lifecycle policies (move para Glacier após 90 dias)
- Compressão Parquet (reduz tamanho ~80%)
- Logs com retenção limitada
- Uso de S3 Intelligent-Tiering

## Manutenção

### Tarefas Regulares
- Monitorar dashboard do CloudWatch
- Revisar alarmes e notificações
- Executar testes de carga
- Atualizar dependências Python
- Revisar políticas de lifecycle do S3

### Troubleshooting
- Logs disponíveis em CloudWatch
- X-Ray para tracing (se habilitado)
- Arquivos com erro em `failed/` folder
- Métricas em tempo real no dashboard
