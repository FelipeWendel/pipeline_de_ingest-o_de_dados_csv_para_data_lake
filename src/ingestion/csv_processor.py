"""Processador de dados CSV."""
import pandas as pd
import pyarrow.parquet as pq
from datetime import datetime
from io import BytesIO
import logging

logger = logging.getLogger(__name__)


class ProcessadorCSV:
    """Processa arquivos CSV e converte para Parquet."""
    
    def __init__(self):
        self.df = None
    
    def ler_csv(self, dados: bytes, delimitador: str = ',') -> pd.DataFrame:
        """Lê CSV de bytes."""
        self.df = pd.read_csv(BytesIO(dados), sep=delimitador)
        logger.info(f"CSV lido: {len(self.df)} linhas")
        return self.df
    
    def limpar_dados(self) -> pd.DataFrame:
        """Remove duplicatas e linhas vazias."""
        self.df = self.df.drop_duplicates().dropna(how='all')
        return self.df
    
    def adicionar_colunas_metadados(self, arquivo_origem: str) -> pd.DataFrame:
        """Adiciona colunas de metadados e particionamento."""
        agora = datetime.now()
        self.df['data_ingestao'] = agora
        self.df['arquivo_origem'] = arquivo_origem
        self.df['ano'] = agora.year
        self.df['mes'] = agora.month
        self.df['dia'] = agora.day
        return self.df
    
    def converter_para_parquet(self) -> bytes:
        """Converte DataFrame para Parquet comprimido."""
        buffer = BytesIO()
        self.df.to_parquet(buffer, compression='snappy', index=False)
        return buffer.getvalue()
    
    def validar_dataframe(self, colunas_obrigatorias: list = None) -> bool:
        """Valida se DataFrame está OK e tem colunas obrigatórias."""
        if self.df is None or self.df.empty:
            return False
        
        if colunas_obrigatorias:
            colunas_faltantes = set(colunas_obrigatorias) - set(self.df.columns)
            if colunas_faltantes:
                logger.warning(f"Colunas obrigatórias faltantes: {colunas_faltantes}")
                return False
        
        return True
    
    def obter_estatisticas(self) -> dict:
        """Retorna estatísticas básicas do DataFrame."""
        if self.df is None:
            return {}
        
        return {
            'row_count': len(self.df),
            'column_count': len(self.df.columns),
            'columns': list(self.df.columns)
        }
