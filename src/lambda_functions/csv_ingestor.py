"""Função Lambda para processar CSV do S3."""
import json
import logging
import sys
import os

# Configurar caminho para imports locais
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../..'))

from src.ingestion.pipeline import PipelineIngestao

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(evento, contexto):
    """Handler Lambda - processa eventos S3."""
    logger.info(f"Evento recebido: {json.dumps(evento)}")
    
    resultados = []
    
    try:
        # Processar cada arquivo do evento S3
        for registro in evento.get('Records', []):
            bucket = registro['s3']['bucket']['name']
            chave = registro['s3']['object']['key']
            
            # Ignorar arquivos não-CSV
            if not chave.lower().endswith('.csv'):
                logger.info(f"Ignorando arquivo não-CSV: {chave}")
                continue
            
            logger.info(f"Processando {bucket}/{chave}")
            
            # Processar arquivo
            pipeline = PipelineIngestao()
            resultado = pipeline.processar_arquivo(bucket, chave)
            resultados.append(resultado)
            
            if resultado['sucesso']:
                logger.info(f"Sucesso: {resultado['destino']}")
            else:
                logger.error(f"Falha: {resultado['erro']}")
        
        # Resposta
        contador_sucesso = sum(1 for r in resultados if r['sucesso'])
        
        return {
            'statusCode': 200 if contador_sucesso == len(resultados) else 207,
            'body': json.dumps({
                'processados': len(resultados),
                'sucesso': contador_sucesso,
                'resultados': resultados
            })
        }
        
    except Exception as e:
        logger.exception("Erro no handler Lambda")
        return {
            'statusCode': 500,
            'body': json.dumps({'erro': str(e)})
        }
