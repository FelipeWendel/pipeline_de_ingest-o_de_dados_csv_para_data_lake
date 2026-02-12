# Contributing

Obrigado pelo interesse em contribuir com o Pipeline de Ingestão de Dados CSV!

## Como Contribuir

### Reportar Bugs

Se você encontrou um bug:

1. Verifique se o bug já foi reportado nas [Issues](../../issues)
2. Se não foi reportado, crie uma nova issue incluindo:
   - Descrição clara do problema
   - Passos para reproduzir
   - Comportamento esperado vs atual
   - Logs relevantes
   - Informações do ambiente (versão Python, AWS, etc.)

### Sugerir Melhorias

Para sugerir novas funcionalidades:

1. Crie uma issue descrevendo:
   - O problema que a funcionalidade resolveria
   - Como você imagina a solução
   - Alternativas consideradas

### Pull Requests

1. **Fork** o repositório
2. **Crie** uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. **Commit** suas mudanças (`git commit -m 'Adiciona MinhaFeature'`)
4. **Push** para a branch (`git push origin feature/MinhaFeature`)
5. **Abra** um Pull Request

### Padrões de Código

#### Python
- Siga PEP 8
- Use type hints
- Docstrings em formato Google
- Máximo 100 caracteres por linha
- Use black para formatação

```bash
# Formatar código
black src/ tests/

# Verificar linting
flake8 src/ tests/

# Verificar tipos
mypy src/
```

#### Terraform
- Use formatação consistente (`terraform fmt`)
- Nomes descritivos para recursos
- Comentários para lógica complexa
- Tags em todos os recursos

```bash
# Formatar Terraform
cd terraform
terraform fmt -recursive
```

### Testes

Toda nova funcionalidade deve incluir testes:

```bash
# Executar todos os testes
pytest tests/ -v

# Com coverage
pytest tests/ --cov=src --cov-report=html

# Testes específicos
pytest tests/test_csv_processor.py -v
```

Mantenha coverage acima de 80%.

### Documentação

- Atualize README.md se necessário
- Documente novas funcionalidades em `/docs`
- Atualize CHANGELOG.md

### Commit Messages

Use mensagens claras e descritivas:

```
Tipo: Descrição curta (máx 50 caracteres)

Descrição detalhada do que foi mudado e por quê.
Pode ter múltiplas linhas.

Fixes #123
```

**Tipos de commit:**
- `feat`: Nova funcionalidade
- `fix`: Correção de bug
- `docs`: Documentação
- `style`: Formatação
- `refactor`: Refatoração
- `test`: Testes
- `chore`: Manutenção

### Code Review

- Seja respeitoso e construtivo
- Responda a todos os comentários
- Faça pequenas mudanças incrementais
- Teste localmente antes de submeter

## Ambiente de Desenvolvimento

### Setup Local

```bash
# Clone o repositório
git clone <repo-url>
cd pipeline_de_ingestão_de_dados_csv_para_data_lake

# Criar ambiente virtual
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Instalar dependências
pip install -r requirements.txt

# Instalar ferramentas de desenvolvimento
pip install black flake8 mypy pytest pytest-cov

# Configurar pre-commit hooks (opcional)
pip install pre-commit
pre-commit install
```

### Estrutura do Projeto

```
.
├── src/                    # Código fonte
│   ├── config/            # Configurações
│   ├── ingestion/         # Lógica de ingestão
│   ├── lambda_functions/  # Funções Lambda
│   └── utils/             # Utilitários
├── terraform/             # Infraestrutura
├── tests/                 # Testes
├── docs/                  # Documentação
└── data/sample/           # Dados de exemplo
```

## Dúvidas?

Abra uma issue ou entre em contato com os mantenedores.

Obrigado pela contribuição! 🎉
