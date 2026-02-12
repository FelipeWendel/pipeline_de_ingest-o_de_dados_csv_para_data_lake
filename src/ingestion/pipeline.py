"""Pipeline de ingestão CSV para Data Lake."""
import logging
from datetime import datetime
from ..utils.s3_utils import ClienteS3
from ..config.settings import config
from .csv_processor import ProcessadorCSV

logger = logging.getLogger(__name__)


class PipelineIngestao:
    """Pipeline simples de ingestão."""
    
    def __init__(self):
        self.cliente_s3 = ClienteS3(regiao=config.aws.regiao)
        self.processador_csv = ProcessadorCSV()
    
    def processar_arquivo(self, bucket: str, chave: str) -> dict:
        """Processa arquivo CSV do S3."""
        resultado = {
            'sucesso': False,
            'origem': f"{bucket}/{chave}",
            'erro': None
        }
        
        try:
            logger.info(f"Processando {bucket}/{chave}")
            
            # Ler CSV do S3
            dados_csv = self.cliente_s3.ler_csv_do_s3(bucket, chave)
            
            # Processar: ler, limpar, adicionar metadados
            self.processador_csv.ler_csv(dados_csv)
            self.processador_csv.limpar_dados()
            self.processador_csv.adicionar_colunas_metadados(arquivo_origem=chave)
            
            # Converter para Parquet
            dados_parquet = self.processador_csv.converter_para_parquet()
            
            # Caminho particionado por data
            agora = datetime.now()
            nome_arquivo = chave.split('/')[-1].replace('.csv', '')
            chave_destino = f"data/ano={agora.year}/mes={agora.month:02d}/dia={agora.day:02d}/{nome_arquivo}.parquet"
            
            # Salvar no Data Lake
            sucesso = self.cliente_s3.escrever_no_s3(
                dados_parquet,
                config.s3.bucket_data_lake,
                chave_destino
            )
            
            if sucesso:
                resultado['sucesso'] = True
                resultado['destino'] = f"{config.s3.bucket_data_lake}/{chave_destino}"
                resultado['linhas'] = len(self.processador_csv.df)
                logger.info(f"Sucesso: {resultado['linhas']} linhas processadas")
            
        except Exception as e:
            logger.error(f"Erro: {e}")
            resultado['erro'] = str(e)
        
        return resultado
