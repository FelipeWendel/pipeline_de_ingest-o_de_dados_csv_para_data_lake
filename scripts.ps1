# Script PowerShell com comandos úteis do projeto
# Use: .\scripts.ps1 <comando>

param(
    [Parameter(Position = 0)]
    [string]$Command = "help",
    
    [Parameter(Position = 1)]
    [string]$Arg1,
    
    [Parameter(Position = 2)]
    [string]$Arg2
)

function Show-Help {
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host "Pipeline CSV - Comandos Úteis" -ForegroundColor Cyan
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Uso: .\scripts.ps1 <comando> [argumentos]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Comandos disponíveis:" -ForegroundColor Green
    Write-Host "  install              - Instala dependências Python"
    Write-Host "  test                 - Executa testes"
    Write-Host "  clean                - Remove arquivos temporários"
    Write-Host "  format               - Formata código com black"
    Write-Host "  terraform-init       - Inicializa Terraform"
    Write-Host "  terraform-plan       - Planeja deployment"
    Write-Host "  terraform-apply      - Aplica infraestrutura"
    Write-Host "  terraform-destroy    - Destroi infraestrutura"
    Write-Host "  deploy-lambda        - Deploy da função Lambda"
    Write-Host "  logs <function-name> - Mostra logs da Lambda"
    Write-Host "  upload-csv <bucket>  - Upload de CSV de teste"
    Write-Host "  list-datalake <bucket> - Lista arquivos no Data Lake"
    Write-Host ""
}

function Install-Dependencies {
    Write-Host "📦 Instalando dependências..." -ForegroundColor Cyan
    pip install -r requirements.txt
    Write-Host "✅ Dependências instaladas!" -ForegroundColor Green
}

function Run-Tests {
    Write-Host "🧪 Executando testes..." -ForegroundColor Cyan
    pytest tests/ -v --cov=src --cov-report=html
}

function Clean-Project {
    Write-Host "🧹 Limpando arquivos temporários..." -ForegroundColor Cyan
    
    # Remove __pycache__
    Get-ChildItem -Path . -Recurse -Directory -Filter "__pycache__" | Remove-Item -Recurse -Force
    
    # Remove .pyc
    Get-ChildItem -Path . -Recurse -Filter "*.pyc" | Remove-Item -Force
    
    # Remove .pytest_cache
    Get-ChildItem -Path . -Recurse -Directory -Filter ".pytest_cache" | Remove-Item -Recurse -Force
    
    # Remove htmlcov
    if (Test-Path "htmlcov") {
        Remove-Item -Recurse -Force "htmlcov"
    }
    
    # Remove .coverage
    if (Test-Path ".coverage") {
        Remove-Item -Force ".coverage"
    }
    
    Write-Host "✅ Limpeza concluída!" -ForegroundColor Green
}

function Format-Code {
    Write-Host "✨ Formatando código..." -ForegroundColor Cyan
    black src/ tests/
    Write-Host "✅ Código formatado!" -ForegroundColor Green
}

function Initialize-Terraform {
    Write-Host "🏗️  Inicializando Terraform..." -ForegroundColor Cyan
    Push-Location terraform
    terraform init
    Pop-Location
    Write-Host "✅ Terraform inicializado!" -ForegroundColor Green
}

function Plan-Terraform {
    Write-Host "📋 Planejando deployment..." -ForegroundColor Cyan
    Push-Location terraform
    terraform plan
    Pop-Location
}

function Apply-Terraform {
    Write-Host "🚀 Aplicando infraestrutura..." -ForegroundColor Cyan
    Push-Location terraform
    terraform apply
    Pop-Location
}

function Destroy-Terraform {
    Write-Host "⚠️  Destruindo infraestrutura..." -ForegroundColor Yellow
    $confirmation = Read-Host "Tem certeza? (yes/no)"
    if ($confirmation -eq "yes") {
        Push-Location terraform
        terraform destroy
        Pop-Location
    }
    else {
        Write-Host "❌ Operação cancelada" -ForegroundColor Red
    }
}

function Deploy-Lambda {
    Write-Host "🚀 Deploy da função Lambda..." -ForegroundColor Cyan
    Push-Location src\lambda_functions
    .\deploy.ps1
    Pop-Location
}

function Show-Logs {
    param([string]$FunctionName)
    
    if (-not $FunctionName) {
        Write-Host "❌ Erro: Nome da função não especificado" -ForegroundColor Red
        Write-Host "Uso: .\scripts.ps1 logs <nome-da-funcao>" -ForegroundColor Yellow
        return
    }
    
    Write-Host "📋 Mostrando logs de $FunctionName..." -ForegroundColor Cyan
    aws logs tail "/aws/lambda/$FunctionName" --follow
}

function Upload-TestCSV {
    param([string]$Bucket)
    
    if (-not $Bucket) {
        Write-Host "❌ Erro: Nome do bucket não especificado" -ForegroundColor Red
        Write-Host "Uso: .\scripts.ps1 upload-csv <nome-do-bucket>" -ForegroundColor Yellow
        return
    }
    
    Write-Host "📤 Fazendo upload de CSV de teste para $Bucket..." -ForegroundColor Cyan
    aws s3 cp data\sample\test_data.csv "s3://$Bucket/input/"
    Write-Host "✅ Upload concluído!" -ForegroundColor Green
}

function List-DataLake {
    param([string]$Bucket)
    
    if (-not $Bucket) {
        Write-Host "❌ Erro: Nome do bucket não especificado" -ForegroundColor Red
        Write-Host "Uso: .\scripts.ps1 list-datalake <nome-do-bucket>" -ForegroundColor Yellow
        return
    }
    
    Write-Host "📂 Listando arquivos no Data Lake ($Bucket)..." -ForegroundColor Cyan
    aws s3 ls "s3://$Bucket/processed/" --recursive
}

# Executar comando
switch ($Command.ToLower()) {
    "help" { Show-Help }
    "install" { Install-Dependencies }
    "test" { Run-Tests }
    "clean" { Clean-Project }
    "format" { Format-Code }
    "terraform-init" { Initialize-Terraform }
    "terraform-plan" { Plan-Terraform }
    "terraform-apply" { Apply-Terraform }
    "terraform-destroy" { Destroy-Terraform }
    "deploy-lambda" { Deploy-Lambda }
    "logs" { Show-Logs -FunctionName $Arg1 }
    "upload-csv" { Upload-TestCSV -Bucket $Arg1 }
    "list-datalake" { List-DataLake -Bucket $Arg1 }
    default {
        Write-Host "❌ Comando desconhecido: $Command" -ForegroundColor Red
        Write-Host ""
        Show-Help
    }
}
