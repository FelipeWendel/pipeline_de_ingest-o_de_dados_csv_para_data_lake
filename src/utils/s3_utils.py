"""Utilitários para AWS S3."""
import boto3
import logging

logger = logging.getLogger(__name__)


class ClienteS3:
    """Cliente simplificado para operações S3."""
    
    def __init__(self, regiao: str = "us-east-1"):
        self.s3 = boto3.client('s3', region_name=regiao)
    
    def ler_csv_do_s3(self, bucket: str, chave: str) -> bytes:
        """Lê arquivo do S3."""
        logger.info(f"Lendo s3://{bucket}/{chave}")
        resposta = self.s3.get_object(Bucket=bucket, Key=chave)
        return resposta['Body'].read()
    
    def escrever_no_s3(self, dados: bytes, bucket: str, chave: str) -> bool:
        """Escreve dados no S3."""
        try:
            logger.info(f"Escrevendo s3://{bucket}/{chave}")
            self.s3.put_object(Bucket=bucket, Key=chave, Body=dados)
            return True
        except Exception as e:
            logger.error(f"Erro ao escrever no S3: {e}")
            return False
    
    def copiar_objeto(self, bucket_origem: str, chave_origem: str, 
                     bucket_destino: str, chave_destino: str) -> bool:
        """Copia objeto de um local S3 para outro."""
        try:
            origem = {'Bucket': bucket_origem, 'Key': chave_origem}
            self.s3.copy(origem, bucket_destino, chave_destino)
            logger.info(f"Copiado de {bucket_origem}/{chave_origem} para {bucket_destino}/{chave_destino}")
            return True
        except Exception as e:
            logger.error(f"Erro ao copiar objeto: {e}")
            return False
    
    def deletar_objeto(self, bucket: str, chave: str) -> bool:
        """Deleta objeto do S3."""
        try:
            self.s3.delete_object(Bucket=bucket, Key=chave)
            logger.info(f"Deletado s3://{bucket}/{chave}")
            return True
        except Exception as e:
            logger.error(f"Erro ao deletar objeto: {e}")
            return False
    
    def listar_objetos(self, bucket: str, prefixo: str = "") -> list:
        """Lista objetos no bucket com prefixo opcional."""
        try:
            resposta = self.s3.list_objects_v2(Bucket=bucket, Prefix=prefixo)
            if 'Contents' in resposta:
                return [obj['Key'] for obj in resposta['Contents']]
            return []
        except Exception as e:
            logger.error(f"Erro ao listar objetos: {e}")
            return []
    
    def obter_metadados_objeto(self, bucket: str, chave: str) -> dict:
        """Obtém metadados de um objeto S3."""
        try:
            resposta = self.s3.head_object(Bucket=bucket, Key=chave)
            return {
                'size': resposta.get('ContentLength', 0),
                'last_modified': resposta.get('LastModified'),
                'content_type': resposta.get('ContentType', '')
            }
        except Exception as e:
            logger.error(f"Erro ao obter metadados: {e}")
            return None
