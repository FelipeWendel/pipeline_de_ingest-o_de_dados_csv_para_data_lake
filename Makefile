# Makefile para comandos comuns do projeto
# Use: make <comando>

.PHONY: help install test clean deploy-terraform deploy-lambda destroy logs

# Variáveis
PYTHON := python
PIP := pip
TERRAFORM_DIR := terraform
LAMBDA_DIR := src/lambda_functions

help: ## Mostra esta mensagem de ajuda
	@echo "Comandos disponíveis:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

install: ## Instala dependências Python
	$(PIP) install -r requirements.txt

test: ## Executa testes
	pytest tests/ -v --cov=src --cov-report=html

test-unit: ## Executa apenas testes unitários
	pytest tests/ -v -m unit

test-integration: ## Executa testes de integração
	pytest tests/ -v -m integration

clean: ## Remove arquivos temporários e cache
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	find . -type d -name "*.egg-info" -exec rm -rf {} +
	find . -type d -name ".pytest_cache" -exec rm -rf {} +
	find . -type d -name "htmlcov" -exec rm -rf {} +
	rm -f .coverage
	rm -rf build/
	rm -rf dist/

lint: ## Executa linting no código
	flake8 src/ tests/
	black --check src/ tests/

format: ## Formata código com black
	black src/ tests/

type-check: ## Verifica tipos com mypy
	mypy src/

terraform-init: ## Inicializa Terraform
	cd $(TERRAFORM_DIR) && terraform init

terraform-plan: ## Planeja deployment Terraform
	cd $(TERRAFORM_DIR) && terraform plan

terraform-apply: ## Aplica infraestrutura Terraform
	cd $(TERRAFORM_DIR) && terraform apply

terraform-destroy: ## Destroi infraestrutura Terraform
	cd $(TERRAFORM_DIR) && terraform destroy

deploy-lambda: ## Deploy manual da função Lambda
	cd $(LAMBDA_DIR) && chmod +x deploy.sh && ./deploy.sh

logs: ## Mostra logs da Lambda (requer AWS CLI configurado)
	@if [ -z "$(FUNCTION_NAME)" ]; then \
		echo "Erro: Defina FUNCTION_NAME, ex: make logs FUNCTION_NAME=csv-ingestor"; \
	else \
		aws logs tail /aws/lambda/$(FUNCTION_NAME) --follow; \
	fi

upload-test-csv: ## Upload de arquivo CSV de teste
	@if [ -z "$(BUCKET)" ]; then \
		echo "Erro: Defina BUCKET, ex: make upload-test-csv BUCKET=meu-bucket"; \
	else \
		aws s3 cp data/sample/test_data.csv s3://$(BUCKET)/input/; \
	fi

list-datalake: ## Lista arquivos no Data Lake
	@if [ -z "$(BUCKET)" ]; then \
		echo "Erro: Defina BUCKET, ex: make list-datalake BUCKET=meu-datalake"; \
	else \
		aws s3 ls s3://$(BUCKET)/processed/ --recursive; \
	fi

setup-dev: install ## Configura ambiente de desenvolvimento
	@echo "Ambiente de desenvolvimento configurado!"
	@echo "Execute 'source venv/bin/activate' para ativar o ambiente virtual"

docker-build: ## Constrói imagem Docker (se aplicável)
	docker build -t csv-pipeline:latest .

docker-run: ## Executa container Docker localmente
	docker run --rm -it csv-pipeline:latest

all: clean install test ## Executa limpeza, instalação e testes
