# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Versionamento Semântico](https://semver.org/lang/pt-BR/).

## [1.0.0] - 2024-02-15

### Adicionado
- Pipeline completo de ingestão de dados CSV para Data Lake AWS
- Função Lambda para processamento automático de arquivos CSV
- Conversão de CSV para formato Parquet com particionamento por data
- Infraestrutura como código usando Terraform
- Buckets S3 para dados raw e Data Lake
- AWS Glue Catalog para catalogação automática de dados
- CloudWatch Dashboard para monitoramento
- CloudWatch Alarms para erros e throttling
- SNS Topics para notificações
- Testes unitários com pytest
- Documentação completa (arquitetura e deployment)
- Scripts de deploy PowerShell e Bash
- Exemplos de dados CSV

### Funcionalidades Principais
- ✅ Leitura automática de arquivos CSV do S3
- ✅ Validação e limpeza de dados
- ✅ Remoção de duplicatas
- ✅ Adição de metadados (timestamp, origem, partições)
- ✅ Conversão para formato Parquet otimizado
- ✅ Particionamento por data (year/month/day)
- ✅ Catalogação automática com Glue Crawler
- ✅ Monitoramento e alertas
- ✅ Logs estruturados no CloudWatch
- ✅ Tratamento de erros robusto
- ✅ Arquivamento de arquivos processados e com falha

### Segurança
- ✅ Criptografia em repouso (S3 SSE)
- ✅ Bloqueio de acesso público aos buckets
- ✅ IAM Roles com princípio de menor privilégio
- ✅ Versionamento de buckets S3
- ✅ CloudTrail habilitado (via configuração AWS)

### Otimizações
- ✅ Compressão Parquet (snappy)
- ✅ S3 Lifecycle policies para arquivamento
- ✅ X-Ray tracing opcional
- ✅ Logs com retenção configurável

## [Não Lançado] - Recursos Futuros

### Planejado
- [ ] Suporte a formatos adicionais (JSON, Avro)
- [ ] Processamento de arquivos grandes em batch
- [ ] Step Functions para workflows complexos
- [ ] CI/CD com GitHub Actions
- [ ] Testes de integração end-to-end
- [ ] Suporte a Schema Evolution
- [ ] Data quality checks com Great Expectations
- [ ] Athena saved queries
- [ ] QuickSight dashboards
- [ ] Cost optimization dashboard
- [ ] Lambda Layers para dependências
- [ ] VPC endpoints para comunicação privada
- [ ] DLQ (Dead Letter Queue) para falhas
- [ ] Retry mechanism customizável
- [ ] Support for incremental loads
- [ ] Data lineage tracking

### Em Consideração
- [ ] Redshift Spectrum integration
- [ ] Real-time streaming com Kinesis
- [ ] Apache Spark para processamento pesado
- [ ] Delta Lake support
- [ ] Multi-region replication
- [ ] Backup e disaster recovery
- [ ] Governança de dados com Lake Formation
- [ ] Compliance com LGPD/GDPR

## Notas de Migração

### Para versão 1.0.0
- Primeira versão estável
- Requer Terraform >= 1.0
- Requer Python >= 3.9
- Requer AWS CLI configurado

---

## Formato

### Tipos de Mudanças
- **Adicionado**: para novas funcionalidades
- **Modificado**: para mudanças em funcionalidades existentes
- **Descontinuado**: para funcionalidades que serão removidas
- **Removido**: para funcionalidades removidas
- **Corrigido**: para correção de bugs
- **Segurança**: para vulnerabilidades

### Versionamento
- **MAJOR**: Mudanças incompatíveis na API
- **MINOR**: Novas funcionalidades compatíveis
- **PATCH**: Correções de bugs compatíveis
