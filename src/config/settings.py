"""
Configurações do pipeline de ingestão de dados.
"""
import os
from dataclasses import dataclass
from typing import List
from dotenv import load_dotenv

load_dotenv()


@dataclass
class ConfigAWS:
    """Configurações AWS."""
    regiao: str = os.getenv("AWS_REGION", "us-east-1")
    id_conta: str = os.getenv("AWS_ACCOUNT_ID", "")
    

@dataclass
class ConfigS3:
    """Configurações S3."""
    bucket_raw: str = os.getenv("RAW_BUCKET_NAME", "my-raw-data-bucket")
    bucket_data_lake: str = os.getenv("DATA_LAKE_BUCKET_NAME", "my-data-lake-bucket")
    prefixo_processados: str = os.getenv("PROCESSED_PREFIX", "processed/")
    prefixo_falhas: str = os.getenv("FAILED_PREFIX", "failed/")
    

@dataclass
class ConfigProcessamento:
    """Configurações de processamento."""
    tamanho_max_arquivo_mb: int = int(os.getenv("MAX_FILE_SIZE_MB", "100"))
    tamanho_lote: int = int(os.getenv("BATCH_SIZE", "1000"))
    colunas_particao: List[str] = None
    
    def __post_init__(self):
        if self.colunas_particao is None:
            colunas_str = os.getenv("PARTITION_COLS", "ano,mes,dia")
            self.colunas_particao = [col.strip() for col in colunas_str.split(",")]


@dataclass
class ConfigGlue:
    """Configurações AWS Glue."""
    banco_dados: str = os.getenv("DATA_LAKE_DATABASE", "datalake_db")
    prefixo_tabela: str = os.getenv("DATA_LAKE_TABLE_PREFIX", "csv_")
    nome_crawler: str = os.getenv("GLUE_CRAWLER_NAME", "csv-data-crawler")


@dataclass
class ConfigNotificacao:
    """Configurações de notificação."""
    arn_topico_sns: str = os.getenv("SNS_TOPIC_ARN", "")


@dataclass
class ConfigLogging:
    """Configurações de logging."""
    nivel_log: str = os.getenv("LOG_LEVEL", "INFO")
    habilitar_xray: bool = os.getenv("ENABLE_XRAY", "true").lower() == "true"


class Configuracao:
    """Classe principal de configurações."""
    
    def __init__(self):
        self.aws = ConfigAWS()
        self.s3 = ConfigS3()
        self.processamento = ConfigProcessamento()
        self.glue = ConfigGlue()
        self.notificacao = ConfigNotificacao()
        self.logging = ConfigLogging()
    
    def validar(self) -> bool:
        """Valida se todas as configurações necessárias estão presentes."""
        configs_obrigatorias = [
            (self.s3.bucket_raw, "RAW_BUCKET_NAME"),
            (self.s3.bucket_data_lake, "DATA_LAKE_BUCKET_NAME"),
            (self.aws.id_conta, "AWS_ACCOUNT_ID"),
        ]
        
        for valor, nome in configs_obrigatorias:
            if not valor:
                raise ValueError(f"Configuração obrigatória ausente: {nome}")
        
        return True


# Instância global de configuração
config = Configuracao()
