"""
Testes para o cliente S3.
"""
import pytest
from moto import mock_s3
import boto3
from src.utils.s3_utils import ClienteS3


@pytest.fixture
def cliente_s3():
    """Fixture para criar cliente S3 mockado."""
    with mock_s3():
        yield ClienteS3(regiao='us-east-1')


@pytest.fixture
def bucket_mock(cliente_s3):
    """Fixture para criar bucket mockado."""
    nome_bucket = "test-bucket"
    s3 = boto3.client('s3', region_name='us-east-1')
    s3.create_bucket(Bucket=nome_bucket)
    return nome_bucket


def teste_escrever_no_s3(cliente_s3, bucket_mock):
    """Testa escrita no S3."""
    dados = b"test data content"
    chave = "test/file.txt"
    
    sucesso = cliente_s3.escrever_no_s3(dados, bucket_mock, chave)
    
    assert sucesso


def teste_ler_csv_do_s3(cliente_s3, bucket_mock):
    """Testa leitura de CSV do S3."""
    # Primeiro escrever dados
    dados_csv = b"id,name,value\n1,Alice,100\n2,Bob,200"
    chave = "test/data.csv"
    cliente_s3.escrever_no_s3(dados_csv, bucket_mock, chave)
    
    # Depois ler
    conteudo = cliente_s3.ler_csv_do_s3(bucket_mock, chave)
    
    assert conteudo == dados_csv


def teste_copiar_objeto(cliente_s3, bucket_mock):
    """Testa cópia de objeto."""
    # Criar objeto original
    dados = b"original data"
    chave_origem = "source/file.txt"
    cliente_s3.escrever_no_s3(dados, bucket_mock, chave_origem)
    
    # Copiar objeto
    chave_destino = "destination/file.txt"
    sucesso = cliente_s3.copiar_objeto(bucket_mock, chave_origem, bucket_mock, chave_destino)
    
    assert sucesso
    
    # Verificar que ambos existem
    conteudo_origem = cliente_s3.ler_csv_do_s3(bucket_mock, chave_origem)
    conteudo_destino = cliente_s3.ler_csv_do_s3(bucket_mock, chave_destino)
    
    assert conteudo_origem == conteudo_destino


def teste_deletar_objeto(cliente_s3, bucket_mock):
    """Testa deleção de objeto."""
    # Criar objeto
    dados = b"test data"
    chave = "test/file.txt"
    cliente_s3.escrever_no_s3(dados, bucket_mock, chave)
    
    # Deletar objeto
    sucesso = cliente_s3.deletar_objeto(bucket_mock, chave)
    
    assert sucesso


def teste_listar_objetos(cliente_s3, bucket_mock):
    """Testa listagem de objetos."""
    # Criar múltiplos objetos
    chaves = ["file1.txt", "file2.txt", "folder/file3.txt"]
    for chave in chaves:
        cliente_s3.escrever_no_s3(b"data", bucket_mock, chave)
    
    # Listar todos
    todos_objetos = cliente_s3.listar_objetos(bucket_mock)
    assert len(todos_objetos) == 3
    
    # Listar com prefixo
    objetos_pasta = cliente_s3.listar_objetos(bucket_mock, prefixo="folder/")
    assert len(objetos_pasta) == 1


def teste_obter_metadados_objeto(cliente_s3, bucket_mock):
    """Testa obtenção de metadados."""
    dados = b"test data content"
    chave = "test/file.txt"
    cliente_s3.escrever_no_s3(dados, bucket_mock, chave)
    
    metadados = cliente_s3.obter_metadados_objeto(bucket_mock, chave)
    
    assert metadados is not None
    assert 'size' in metadados
    assert metadados['size'] == len(dados)
    assert 'last_modified' in metadados
