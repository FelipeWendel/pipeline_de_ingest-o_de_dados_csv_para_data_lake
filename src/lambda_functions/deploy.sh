#!/bin/bash
# Script para deploy das funções Lambda

set -e

echo "🚀 Deploy das Funções Lambda"
echo "=============================="

# Configurações
FUNCTION_NAME="csv-ingestor"
REGION="${AWS_REGION:-us-east-1}"
ACCOUNT_ID="${AWS_ACCOUNT_ID}"

if [ -z "$ACCOUNT_ID" ]; then
    echo "❌ Erro: AWS_ACCOUNT_ID não definido"
    exit 1
fi

# Criar diretório de build
echo "📦 Criando pacote de deployment..."
BUILD_DIR="build"
rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR

# Copiar código fonte
cp -r ../config $BUILD_DIR/
cp -r ../ingestion $BUILD_DIR/
cp -r ../utils $BUILD_DIR/
cp csv_ingestor.py $BUILD_DIR/

# Instalar dependências
echo "📚 Instalando dependências..."
pip install -r ../../requirements.txt -t $BUILD_DIR/ --quiet

# Criar zip
echo "🗜️  Criando arquivo ZIP..."
cd $BUILD_DIR
zip -r ../lambda-function.zip . -q
cd ..

# Verificar se a função Lambda existe
echo "🔍 Verificando função Lambda..."
if aws lambda get-function --function-name $FUNCTION_NAME --region $REGION 2>/dev/null; then
    # Atualizar função existente
    echo "♻️  Atualizando função Lambda..."
    aws lambda update-function-code \
        --function-name $FUNCTION_NAME \
        --zip-file fileb://lambda-function.zip \
        --region $REGION
else
    # Criar nova função
    echo "✨ Criando função Lambda..."
    aws lambda create-function \
        --function-name $FUNCTION_NAME \
        --runtime python3.9 \
        --role arn:aws:iam::${ACCOUNT_ID}:role/lambda-execution-role \
        --handler csv_ingestor.lambda_handler \
        --zip-file fileb://lambda-function.zip \
        --timeout 300 \
        --memory-size 512 \
        --region $REGION \
        --environment Variables="{RAW_BUCKET_NAME=${RAW_BUCKET_NAME},DATA_LAKE_BUCKET_NAME=${DATA_LAKE_BUCKET_NAME}}"
fi

# Configurar trigger S3
echo "🔗 Configurando trigger S3..."
# Nota: Isso normalmente seria feito via Terraform ou CloudFormation

# Cleanup
echo "🧹 Limpando arquivos temporários..."
rm -rf $BUILD_DIR
rm lambda-function.zip

echo "✅ Deploy concluído com sucesso!"
echo ""
echo "Para testar:"
echo "aws lambda invoke --function-name $FUNCTION_NAME --region $REGION output.json"
