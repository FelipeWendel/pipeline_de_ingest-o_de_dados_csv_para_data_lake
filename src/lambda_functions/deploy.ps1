# Script PowerShell para implantação das funções Lambda no Windows

Write-Host "🚀 Implantação das Funções Lambda" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green

# Configurações
$FUNCTION_NAME = "csv-ingestor"
$REGION = if ($env:AWS_REGION) { $env:AWS_REGION } else { "us-east-1" }
$ACCOUNT_ID = $env:AWS_ACCOUNT_ID

if (-not $ACCOUNT_ID) {
    Write-Host "❌ Erro: AWS_ACCOUNT_ID não definido" -ForegroundColor Red
    exit 1
}

# Criar diretório de build
Write-Host "📦 Criando pacote de implantação..." -ForegroundColor Cyan
$BUILD_DIR = "build"
if (Test-Path $BUILD_DIR) {
    Remove-Item -Recurse -Force $BUILD_DIR
}
New-Item -ItemType Directory -Path $BUILD_DIR | Out-Null

# Copiar código fonte
Write-Host "📂 Copiando arquivos fonte..." -ForegroundColor Cyan
Copy-Item -Recurse -Path "../config" -Destination "$BUILD_DIR/config"
Copy-Item -Recurse -Path "../ingestion" -Destination "$BUILD_DIR/ingestion"
Copy-Item -Recurse -Path "../utils" -Destination "$BUILD_DIR/utils"
Copy-Item -Path "csv_ingestor.py" -Destination "$BUILD_DIR/"

# Instalar dependências
Write-Host "📚 Instalando dependências..." -ForegroundColor Cyan
pip install -r ../../requirements.txt -t $BUILD_DIR/ --quiet

# Criar arquivo zip
Write-Host "🗜️ Criando arquivo ZIP..." -ForegroundColor Cyan
$zipFile = "lambda-function.zip"
if (Test-Path $zipFile) {
    Remove-Item $zipFile
}

# Comprimir usando .NET
Add-Type -Assembly System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory(
    (Resolve-Path $BUILD_DIR).Path,
    (Join-Path (Get-Location) $zipFile)
)

# Verificar se a função Lambda existe
Write-Host "🔍 Verificando função Lambda..." -ForegroundColor Cyan
try {
    aws lambda get-function --function-name $FUNCTION_NAME --region $REGION 2>$null
    $functionExists = $true
}
catch {
    $functionExists = $false
}

if ($functionExists) {
    # Atualizar função existente
    Write-Host "♻️ Atualizando função Lambda..." -ForegroundColor Yellow
    aws lambda update-function-code `
        --function-name $FUNCTION_NAME `
        --zip-file fileb://$zipFile `
        --region $REGION
}
else {
    # Criar nova função
    Write-Host "✨ Criando função Lambda..." -ForegroundColor Green
    aws lambda create-function `
        --function-name $FUNCTION_NAME `
        --runtime python3.9 `
        --role "arn:aws:iam::${ACCOUNT_ID}:role/lambda-execution-role" `
        --handler csv_ingestor.lambda_handler `
        --zip-file fileb://$zipFile `
        --timeout 300 `
        --memory-size 512 `
        --region $REGION `
        --environment "Variables={RAW_BUCKET_NAME=$env:RAW_BUCKET_NAME,DATA_LAKE_BUCKET_NAME=$env:DATA_LAKE_BUCKET_NAME}"
}

# Limpeza
Write-Host "🧹 Limpando arquivos temporários..." -ForegroundColor Cyan
Remove-Item -Recurse -Force $BUILD_DIR
Remove-Item $zipFile

Write-Host ""
Write-Host "✅ Implantação concluída com sucesso!" -ForegroundColor Green
Write-Host ""
Write-Host "Para testar:" -ForegroundColor Cyan
Write-Host "aws lambda invoke --function-name $FUNCTION_NAME --region $REGION output.json" -ForegroundColor White
