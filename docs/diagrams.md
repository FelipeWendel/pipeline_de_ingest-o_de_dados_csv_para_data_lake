```mermaid
graph TB
    subgraph "Upload de Dados"
        USER[👤 Usuário/Sistema]
        CSV[📄 Arquivo CSV]
    end
    
    subgraph "AWS Cloud"
        subgraph "Camada de Ingestão"
            S3RAW[(🗄️ S3 Raw Bucket<br/>input/)]
            S3EVENT[📨 S3 Event<br/>ObjectCreated]
        end
        
        subgraph "Camada de Processamento"
            LAMBDA[⚡ Lambda Function<br/>csv-ingestor]
            PROCESS[🔄 Processamento:<br/>- Validação<br/>- Limpeza<br/>- Transformação<br/>- Conversão Parquet]
        end
        
        subgraph "Camada de Armazenamento"
            S3LAKE[(🗄️ S3 Data Lake<br/>processed/<br/>year/month/day/)]
        end
        
        subgraph "Camada de Catalogação"
            CRAWLER[🕷️ Glue Crawler]
            CATALOG[(📚 Glue Catalog<br/>Metadata)]
        end
        
        subgraph "Camada de Consulta"
            ATHENA[🔍 Amazon Athena]
            REDSHIFT[📊 Redshift Spectrum]
            QUICKSIGHT[📈 QuickSight]
        end
        
        subgraph "Monitoramento"
            CWLOGS[📋 CloudWatch Logs]
            CWMETRICS[📊 CloudWatch Metrics]
            ALARM[🚨 CloudWatch Alarms]
            SNS[📧 SNS Topic<br/>Notificações]
            DASHBOARD[📊 CloudWatch Dashboard]
        end
        
        subgraph "Arquivos Processados"
            S3PROC[(📂 processed/original/)]
            S3FAIL[(❌ failed/)]
        end
    end
    
    USER -->|Upload CSV| CSV
    CSV -->|PUT| S3RAW
    S3RAW -->|Trigger| S3EVENT
    S3EVENT -->|Invoke| LAMBDA
    LAMBDA -->|Processa| PROCESS
    PROCESS -->|Parquet particionado| S3LAKE
    PROCESS -->|Sucesso| S3PROC
    PROCESS -->|Erro| S3FAIL
    S3LAKE -->|Agendado diariamente| CRAWLER
    CRAWLER -->|Atualiza| CATALOG
    CATALOG -->|Query| ATHENA
    CATALOG -->|Query| REDSHIFT
    ATHENA -->|Visualiza| QUICKSIGHT
    
    LAMBDA -->|Logs| CWLOGS
    LAMBDA -->|Metrics| CWMETRICS
    CWMETRICS -->|Threshold| ALARM
    ALARM -->|Notify| SNS
    CWMETRICS -->|Display| DASHBOARD
    
    style USER fill:#e1f5ff
    style S3RAW fill:#ff9900
    style LAMBDA fill:#ff9900
    style S3LAKE fill:#ff9900
    style CATALOG fill:#945DF2
    style ATHENA fill:#232F3E
    style CWLOGS fill:#FF4F8B
    style SNS fill:#FF4F8B
```

## Fluxo Detalhado

### 1. Ingestão
```mermaid
sequenceDiagram
    participant User
    participant S3Raw
    participant Lambda
    participant S3Lake
    
    User->>S3Raw: Upload CSV
    S3Raw->>Lambda: Trigger (S3 Event)
    Lambda->>S3Raw: Read CSV
    Lambda->>Lambda: Process Data
    Lambda->>S3Lake: Write Parquet
    Lambda->>S3Raw: Move to processed/
```

### 2. Processamento Lambda
```mermaid
flowchart TD
    A[Lambda Trigger] --> B{Arquivo CSV?}
    B -->|Não| C[Ignorar]
    B -->|Sim| D[Ler S3]
    D --> E[Validar Tamanho]
    E --> F{Tamanho OK?}
    F -->|Não| G[Move para failed/]
    F -->|Sim| H[Parse CSV]
    H --> I[Validar Dados]
    I --> J{Válido?}
    J -->|Não| G
    J -->|Sim| K[Limpar Dados]
    K --> L[Adicionar Metadados]
    L --> M[Converter para Parquet]
    M --> N[Particionar por Data]
    N --> O[Salvar no Data Lake]
    O --> P[Move para processed/]
    P --> Q[Log Sucesso]
    G --> R[Log Erro]
    Q --> S[Notificar via SNS]
    R --> S
```

### 3. Catalogação
```mermaid
flowchart LR
    A[Glue Crawler] --> B[Scan S3 Data Lake]
    B --> C[Detect Schema]
    C --> D[Create/Update Tables]
    D --> E[Update Partitions]
    E --> F[Glue Catalog]
    F --> G[Athena]
    F --> H[Redshift Spectrum]
    F --> I[QuickSight]
```

## Componentes AWS

| Componente | Função | Custo Estimado |
|------------|--------|----------------|
| S3 Raw Bucket | Armazenamento temporário | $0.023/GB/mês |
| S3 Data Lake | Armazenamento permanente | $0.023/GB/mês |
| Lambda | Processamento | $0.20/1M requests |
| Glue Crawler | Catalogação | $0.44/DPU-hour |
| CloudWatch | Logs e monitoramento | $0.50/GB |
| SNS | Notificações | $0.50/1M requests |

## Particionamento de Dados

```
s3://data-lake-bucket/processed/
└── year=2024/
    └── month=01/
        └── day=15/
            ├── vendas.parquet
            ├── produtos.parquet
            └── clientes.parquet
```

## Segurança

```mermaid
graph TD
    subgraph "IAM Roles"
        A[Lambda Execution Role]
        B[Glue Crawler Role]
    end
    
    subgraph "Permissions"
        C[S3 Read/Write]
        D[CloudWatch Logs]
        E[Glue Catalog Access]
        F[SNS Publish]
    end
    
    subgraph "Encryption"
        G[S3 SSE-S3]
        H[Data in Transit TLS]
    end
    
    A --> C
    A --> D
    A --> E
    A --> F
    B --> C
    B --> E
    C --> G
    E --> G
    C --> H
```
