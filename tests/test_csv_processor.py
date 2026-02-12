"""
Testes para o processador CSV.
"""
import pytest
import pandas as pd
from io import BytesIO
from src.ingestion.csv_processor import ProcessadorCSV


@pytest.fixture
def processador_csv():
    """Fixture para criar instância do processador."""
    return ProcessadorCSV()


@pytest.fixture
def dados_csv_exemplo():
    """Fixture com dados CSV de exemplo."""
    conteudo_csv = """id,name,value,date
1,Alice,100,2024-01-01
2,Bob,200,2024-01-02
3,Charlie,300,2024-01-03
2,Bob,200,2024-01-02
"""
    return conteudo_csv.encode('utf-8')


def teste_ler_csv_sucesso(processador_csv, dados_csv_exemplo):
    """Testa leitura bem-sucedida de CSV."""
    df = processador_csv.ler_csv(dados_csv_exemplo)
    
    assert df is not None
    assert len(df) == 4  # 3 linhas + 1 duplicada
    assert list(df.columns) == ['id', 'name', 'value', 'date']


def teste_ler_csv_com_delimitador_customizado(processador_csv):
    """Testa leitura de CSV com delimitador customizado."""
    conteudo_csv = b"id;name;value\n1;Alice;100\n2;Bob;200"
    
    df = processador_csv.ler_csv(conteudo_csv, delimitador=';')
    
    assert len(df) == 2
    assert 'name' in df.columns


def teste_validar_dataframe_vazio(processador_csv):
    """Testa validação de DataFrame vazio."""
    processador_csv.df = pd.DataFrame()
    
    assert not processador_csv.validar_dataframe()


def teste_validar_dataframe_com_colunas_obrigatorias(processador_csv, dados_csv_exemplo):
    """Testa validação com colunas obrigatórias."""
    processador_csv.ler_csv(dados_csv_exemplo)
    
    # Deve passar com colunas presentes
    assert processador_csv.validar_dataframe(colunas_obrigatorias=['id', 'name'])
    
    # Deve falhar com colunas ausentes
    assert not processador_csv.validar_dataframe(colunas_obrigatorias=['id', 'missing_column'])


def teste_limpar_dados_remove_duplicatas(processador_csv, dados_csv_exemplo):
    """Testa remoção de duplicatas."""
    processador_csv.ler_csv(dados_csv_exemplo)
    
    contagem_inicial = len(processador_csv.df)
    processador_csv.limpar_dados()
    contagem_final = len(processador_csv.df)
    
    assert contagem_final < contagem_inicial
    assert contagem_final == 3  # Removeu 1 duplicata


def teste_limpar_dados_remove_linhas_vazias(processador_csv):
    """Testa remoção de linhas vazias."""
    conteudo_csv = b"id,name,value\n1,Alice,100\n,,\n2,Bob,200"
    processador_csv.ler_csv(conteudo_csv)
    
    processador_csv.limpar_dados()
    
    assert len(processador_csv.df) == 2


def teste_adicionar_colunas_metadados(processador_csv, dados_csv_exemplo):
    """Testa adição de colunas de metadados."""
    processador_csv.ler_csv(dados_csv_exemplo)
    processador_csv.adicionar_colunas_metadados(arquivo_origem="test.csv")
    
    assert 'data_ingestao' in processador_csv.df.columns
    assert 'arquivo_origem' in processador_csv.df.columns
    assert 'ano' in processador_csv.df.columns
    assert 'mes' in processador_csv.df.columns
    assert 'dia' in processador_csv.df.columns
    
    assert processador_csv.df['arquivo_origem'].iloc[0] == "test.csv"


def teste_converter_para_parquet(processador_csv, dados_csv_exemplo):
    """Testa conversão para formato Parquet."""
    processador_csv.ler_csv(dados_csv_exemplo)
    
    dados_parquet = processador_csv.converter_para_parquet()
    
    assert dados_parquet is not None
    assert len(dados_parquet) > 0
    assert isinstance(dados_parquet, bytes)


def teste_obter_estatisticas(processador_csv, dados_csv_exemplo):
    """Testa obtenção de estatísticas."""
    processador_csv.ler_csv(dados_csv_exemplo)
    
    estatisticas = processador_csv.obter_estatisticas()
    
    assert 'row_count' in estatisticas
    assert 'column_count' in estatisticas
    assert 'columns' in estatisticas
    assert estatisticas['row_count'] == 4
    assert estatisticas['column_count'] == 4


def teste_workflow_completo(processador_csv, dados_csv_exemplo):
    """Testa workflow completo de processamento."""
    # 1. Ler CSV
    df = processador_csv.ler_csv(dados_csv_exemplo)
    assert df is not None
    
    # 2. Validar
    assert processador_csv.validar_dataframe()
    
    # 3. Limpar
    processador_csv.limpar_dados()
    assert len(processador_csv.df) == 3  # Removeu duplicata
    
    # 4. Adicionar metadados
    processador_csv.adicionar_colunas_metadados("test.csv")
    assert 'arquivo_origem' in processador_csv.df.columns
    
    # 5. Converter para Parquet
    dados_parquet = processador_csv.converter_para_parquet()
    assert len(dados_parquet) > 0
    
    # 6. Obter estatísticas
    estatisticas = processador_csv.obter_estatisticas()
    assert estatisticas['row_count'] == 3
