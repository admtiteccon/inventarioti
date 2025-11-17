# ☁️ Guia de Instalação - Azure App Service

## 📋 Sobre o Azure App Service

O **Azure App Service** é uma plataforma totalmente gerenciada (PaaS) que permite implantar aplicações web sem se preocupar com infraestrutura. Ideal para aplicações Python/Flask em produção.

**Vantagens:**
- ✅ Infraestrutura totalmente gerenciada
- ✅ Escalabilidade automática
- ✅ SSL gratuito incluído
- ✅ Backup automático
- ✅ Monitoramento integrado
- ✅ CI/CD integrado
- ✅ Alta disponibilidade (99.95% SLA)

---

## 💰 Custos Estimados

### Plano Básico (B1)
- **Preço:** ~$13/mês (~R$ 65/mês)
- **Recursos:** 1 core, 1.75GB RAM, 10GB storage
- **Ideal para:** Pequenas empresas, até 50 usuários

### Plano Standard (S1)
- **Preço:** ~$70/mês (~R$ 350/mês)
- **Recursos:** 1 core, 1.75GB RAM, 50GB storage
- **Ideal para:** Médias empresas, até 200 usuários
- **Extras:** Backup automático, slots de deployment

### Banco de Dados PostgreSQL
- **Preço:** ~$30/mês (~R$ 150/mês)
- **Recursos:** 2 vCores, 5GB storage
- **Backup:** Automático incluído

**Total Estimado:** $43-100/mês (R$ 215-500/mês)

---

## 🎯 Pré-requisitos

### Conta Azure
- Conta ativa no Azure
- Cartão de crédito para cobrança
- Crédito gratuito de $200 (novos usuários)

### Ferramentas Locais
- Azure CLI instalado
- Git instalado
- Python 3.9+ instalado

---

## 🚀 Instalação Passo a Passo

### Passo 1: Preparar o Projeto Localmente

**1.1. Criar arquivo `requirements.txt` otimizado:**

```bash
# Já existe no projeto, mas verificar se está completo
cat requirements.txt
```

**1.2. Criar arquivo `startup.sh`:**

```bash
# Criar arquivo
nano startup.sh
```

**Conteúdo:**
```bash
#!/bin/bash

# Instalar dependências
pip install -r requirements.txt

# Criar tabelas do banco de dados
python -c "from app import create_app, db; app = create_app('production'); app.app_context().push(); db.create_all(); print('Database initialized')"

# Criar tabela de configurações da empresa
python create_company_settings_table.py

# Iniciar Gunicorn
gunicorn --bind=0.0.0.0:8000 --timeout 600 --workers 4 run:app
```

**1.3. Criar arquivo `.deployment`:**

```bash
nano .deployment
```

**Conteúdo:**
```ini
[config]
SCM_DO_BUILD_DURING_DEPLOYMENT=true
```

**1.4. Criar arquivo `runtime.txt`:**

```bash
echo "python-3.11" > runtime.txt
```

**1.5. Criar arquivo `.gitignore` (se não existir):**

```bash
nano .gitignore
```

**Conteúdo:**
```
venv/
__pycache__/
*.pyc
*.pyo
*.db
.env
.DS_Store
logs/
uploads/
*.log
```

---

### Passo 2: Criar Recursos no Azure Portal

**2.1. Acessar Azure Portal:**
```
https://portal.azure.com
```

**2.2. Criar Resource Group:**

1. Pesquisar "Resource groups"
2. Clicar em "+ Create"
3. Configurar:
   - **Subscription:** Sua assinatura
   - **Resource group:** `rg-inventory-prod`
   - **Region:** `Brazil South` ou `East US`
4. Clicar em "Review + create"
5. Clicar em "Create"

---

### Passo 3: Criar Banco de Dados PostgreSQL

**3.1. Criar Azure Database for PostgreSQL:**

1. Pesquisar "Azure Database for PostgreSQL"
2. Clicar em "+ Create"
3. Selecionar "Flexible server"
4. Configurar:
   - **Resource group:** `rg-inventory-prod`
   - **Server name:** `inventory-db-prod` (deve ser único)
   - **Region:** Mesma do Resource Group
   - **PostgreSQL version:** 15
   - **Workload type:** Development
   - **Compute + storage:** Burstable, B1ms (1 vCore, 2GB RAM)
   - **Admin username:** `inventoryadmin`
   - **Password:** Senha forte (anotar!)
5. Aba "Networking":
   - **Connectivity method:** Public access
   - ✅ Allow public access from any Azure service
6. Clicar em "Review + create"
7. Clicar em "Create"
8. Aguardar criação (~5 minutos)

**3.2. Configurar Firewall:**

1. Ir para o recurso criado
2. Menu lateral → "Networking"
3. Adicionar regra:
   - **Rule name:** `AllowAll` (temporário)
   - **Start IP:** `0.0.0.0`
   - **End IP:** `255.255.255.255`
4. Clicar em "Save"

**3.3. Criar Banco de Dados:**

1. Menu lateral → "Databases"
2. Clicar em "+ Add"
3. **Database name:** `inventory_db`
4. Clicar em "Save"

**3.4. Anotar Connection String:**

```
Server: inventory-db-prod.postgres.database.azure.com
Database: inventory_db
Username: inventoryadmin
Password: [sua-senha]
Port: 5432
SSL: Required
```

---

### Passo 4: Criar App Service

**4.1. Criar Web App:**

1. Pesquisar "App Services"
2. Clicar em "+ Create"
3. Aba "Basics":
   - **Resource Group:** `rg-inventory-prod`
   - **Name:** `inventory-app-prod` (deve ser único)
   - **Publish:** Code
   - **Runtime stack:** Python 3.11
   - **Operating System:** Linux
   - **Region:** Mesma do Resource Group
   - **Pricing plan:** Criar novo
     - **Name:** `ASP-inventory-prod`
     - **Pricing tier:** B1 (Basic)
4. Aba "Deployment":
   - **Continuous deployment:** Disable (configurar depois)
5. Aba "Monitoring":
   - **Enable Application Insights:** Yes
   - **Application Insights:** Criar novo
6. Clicar em "Review + create"
7. Clicar em "Create"
8. Aguardar criação (~2 minutos)

---

### Passo 5: Configurar Variáveis de Ambiente

**5.1. Acessar Configuration:**

1. Ir para o App Service criado
2. Menu lateral → "Configuration"
3. Aba "Application settings"

**5.2. Adicionar variáveis:**

Clicar em "+ New application setting" para cada:

```
SCM_DO_BUILD_DURING_DEPLOYMENT = true
WEBSITES_PORT = 8000
FLASK_ENV = production

SECRET_KEY = [gerar com: python -c "import secrets; print(secrets.token_hex(32))"]

DATABASE_URL = postgresql://inventoryadmin:[senha]@inventory-db-prod.postgres.database.azure.com:5432/inventory_db?sslmode=require

MAIL_SERVER = smtp.gmail.com
MAIL_PORT = 587
MAIL_USE_TLS = true
MAIL_USERNAME = seu-email@gmail.com
MAIL_PASSWORD = sua-senha-de-app
MAIL_DEFAULT_SENDER = noreply@seudominio.com

APP_NAME = IT Inventory System
APP_ADMIN_EMAIL = admin@seudominio.com

FOOTER_COMPANY_NAME = Sua Empresa LTDA
FOOTER_YEAR = 2025
FOOTER_VERSION = 1.0.0
FOOTER_DOCS_URL = https://docs.seudominio.com
FOOTER_SUPPORT_EMAIL = suporte@seudominio.com

SESSION_LIFETIME_HOURS = 24
UPLOAD_FOLDER = /home/site/wwwroot/uploads
MAX_CONTENT_LENGTH = 16777216
SCHEDULER_TIMEZONE = America/Sao_Paulo
```

**5.3. Salvar:**
- Clicar em "Save"
- Clicar em "Continue" para reiniciar

---

### Passo 6: Configurar Startup Command

**6.1. Configurar comando de inicialização:**

1. Menu lateral → "Configuration"
2. Aba "General settings"
3. **Startup Command:**
   ```bash
   bash startup.sh
   ```
4. Clicar em "Save"

---

### Passo 7: Implantar Código

**Opção A: Via Git Local (Recomendado)**

**7.1. Obter credenciais de deployment:**

1. Menu lateral → "Deployment Center"
2. Aba "FTPS credentials"
3. Anotar:
   - Username
   - Password

**7.2. Configurar Git remoto:**

```bash
# No diretório do projeto local
cd C:\Users\ADM.TECCON\CODIGOS PYTHON\INVENTARIO

# Inicializar Git (se não estiver)
git init

# Adicionar arquivos
git add .
git commit -m "Initial commit"

# Adicionar remote do Azure
git remote add azure https://inventory-app-prod.scm.azurewebsites.net:443/inventory-app-prod.git

# Push para Azure
git push azure master
```

**Opção B: Via Azure CLI**

```bash
# Instalar Azure CLI
# https://docs.microsoft.com/cli/azure/install-azure-cli

# Login
az login

# Deploy
az webapp up --name inventory-app-prod --resource-group rg-inventory-prod --runtime "PYTHON:3.11"
```

**Opção C: Via GitHub Actions (CI/CD)**

1. Menu lateral → "Deployment Center"
2. **Source:** GitHub
3. Autorizar GitHub
4. Selecionar:
   - **Organization:** Seu usuário
   - **Repository:** Seu repositório
   - **Branch:** main
5. Clicar em "Save"

---

### Passo 8: Verificar Deployment

**8.1. Ver logs de deployment:**

1. Menu lateral → "Deployment Center"
2. Aba "Logs"
3. Verificar se deployment foi bem-sucedido

**8.2. Ver logs da aplicação:**

1. Menu lateral → "Log stream"
2. Verificar se aplicação iniciou sem erros

---

### Passo 9: Configurar Domínio Personalizado (Opcional)

**9.1. Adicionar domínio:**

1. Menu lateral → "Custom domains"
2. Clicar em "+ Add custom domain"
3. **Domain:** `inventory.seudominio.com`
4. Seguir instruções para validar domínio
5. Adicionar registro CNAME no seu DNS:
   ```
   CNAME: inventory
   Value: inventory-app-prod.azurewebsites.net
   ```

**9.2. Configurar SSL:**

1. Após validar domínio
2. Clicar em "Add binding"
3. **TLS/SSL type:** App Service Managed Certificate (Free)
4. Clicar em "Add"

---

### Passo 10: Criar Usuário Administrador

**10.1. Acessar Console SSH:**

1. Menu lateral → "SSH"
2. Clicar em "Go"
3. Aguardar terminal abrir

**10.2. Criar admin:**

```bash
cd /home/site/wwwroot
python run.py create-admin
```

Preencher:
```
Full Name: Administrador
Email: admin@seudominio.com
Password: ********
Confirm Password: ********
```

---

### Passo 11: Configurar Backup Automático

**11.1. Habilitar backup:**

1. Menu lateral → "Backups"
2. Clicar em "Configure"
3. **Storage:** Criar nova conta de storage
4. **Backup schedule:**
   - **Frequency:** Daily
   - **Time:** 02:00
   - **Retention:** 7 days
5. ✅ Backup database
6. Selecionar banco PostgreSQL
7. Clicar em "Save"

---

### Passo 12: Configurar Monitoramento

**12.1. Application Insights:**

1. Menu lateral → "Application Insights"
2. Verificar se está habilitado
3. Clicar em "View Application Insights data"

**12.2. Configurar alertas:**

1. No Application Insights
2. Menu lateral → "Alerts"
3. Criar alertas para:
   - CPU > 80%
   - Memory > 80%
   - Response time > 5s
   - Failed requests > 10

---

### Passo 13: Configurar Escalabilidade

**13.1. Scale up (Vertical):**

1. Menu lateral → "Scale up (App Service plan)"
2. Escolher plano conforme necessidade
3. Clicar em "Apply"

**13.2. Scale out (Horizontal):**

1. Menu lateral → "Scale out (App Service plan)"
2. **Instance count:** Manual ou Auto scale
3. Se Auto scale:
   - **Minimum:** 1
   - **Maximum:** 3
   - **Default:** 1
   - **Rules:** CPU > 70% → Add 1 instance

---

## ✅ Verificação Final

**Acessar aplicação:**
```
https://inventory-app-prod.azurewebsites.net
```

Ou com domínio personalizado:
```
https://inventory.seudominio.com
```

**Verificar:**
- ✅ Página de login carrega
- ✅ SSL ativo (cadeado verde)
- ✅ Login funciona
- ✅ Upload de arquivos funciona
- ✅ Banco de dados conectado

---

## 🔧 Comandos Úteis

### Azure CLI

```bash
# Ver logs em tempo real
az webapp log tail --name inventory-app-prod --resource-group rg-inventory-prod

# Reiniciar app
az webapp restart --name inventory-app-prod --resource-group rg-inventory-prod

# Ver configurações
az webapp config appsettings list --name inventory-app-prod --resource-group rg-inventory-prod

# SSH no container
az webapp ssh --name inventory-app-prod --resource-group rg-inventory-prod
```

### Via Portal

```
# Ver logs
App Service → Log stream

# Reiniciar
App Service → Overview → Restart

# SSH
App Service → SSH → Go
```

---

## 📊 Monitoramento

### Métricas Importantes

**App Service:**
- CPU Percentage
- Memory Percentage
- Response Time
- HTTP Server Errors
- Data In/Out

**PostgreSQL:**
- CPU Percent
- Memory Percent
- Storage Percent
- Active Connections
- Failed Connections

### Application Insights

```
# Ver no portal
Application Insights → Performance
Application Insights → Failures
Application Insights → Users
```

---

## 🔄 Atualizar Aplicação

### Via Git

```bash
# Fazer alterações no código
git add .
git commit -m "Update feature"
git push azure master
```

### Via GitHub Actions

```bash
# Fazer alterações
git add .
git commit -m "Update feature"
git push origin main

# Deploy automático via GitHub Actions
```

---

## 💰 Otimização de Custos

### Dicas para Reduzir Custos

1. **Usar plano compartilhado para desenvolvimento:**
   - Free tier ou Shared tier
   - Trocar para Basic/Standard em produção

2. **Desligar em horários ociosos:**
   - Configurar auto-shutdown
   - Usar Azure Automation

3. **Otimizar banco de dados:**
   - Usar tier Burstable para cargas leves
   - Escalar apenas quando necessário

4. **Usar Azure Reserved Instances:**
   - Desconto de até 72% com compromisso de 1-3 anos

5. **Monitorar custos:**
   - Cost Management + Billing
   - Configurar alertas de custo

---

## 🐛 Solução de Problemas

### Aplicação não inicia

```bash
# Ver logs
az webapp log tail --name inventory-app-prod --resource-group rg-inventory-prod

# Verificar startup command
# Portal → Configuration → General settings → Startup Command
```

### Erro de banco de dados

```bash
# Verificar connection string
# Portal → Configuration → Application settings → DATABASE_URL

# Testar conexão
# SSH → python -c "from app import create_app, db; app = create_app('production'); app.app_context().push(); print('OK')"
```

### Erro 500

```bash
# Ver logs detalhados
# Portal → Log stream

# Habilitar debug temporariamente
# Configuration → Application settings → FLASK_DEBUG = 1
```

### Upload não funciona

```bash
# Verificar permissões
# SSH → ls -la /home/site/wwwroot/uploads

# Criar diretório se não existir
# SSH → mkdir -p /home/site/wwwroot/app/static/uploads
```

---

## 🔒 Segurança

### Boas Práticas

1. **Usar Managed Identity:**
   - Evitar senhas em connection strings
   - Usar Azure AD authentication

2. **Restringir acesso ao banco:**
   - Remover regra AllowAll
   - Adicionar apenas IPs necessários

3. **Habilitar HTTPS only:**
   - Configuration → General settings → HTTPS Only = On

4. **Usar Key Vault:**
   - Armazenar secrets no Azure Key Vault
   - Referenciar no App Service

5. **Configurar WAF:**
   - Usar Azure Front Door ou Application Gateway
   - Proteção contra ataques comuns

---

## 📈 Escalabilidade

### Quando Escalar

**Scale Up (Vertical):**
- CPU > 80% consistentemente
- Memory > 80% consistentemente
- Precisa mais recursos por instância

**Scale Out (Horizontal):**
- Muitos usuários simultâneos
- Precisa alta disponibilidade
- Distribuir carga

### Limites

**Basic (B1):**
- Máximo: 3 instâncias

**Standard (S1):**
- Máximo: 10 instâncias

**Premium (P1V2):**
- Máximo: 30 instâncias

---

## 🎯 Próximos Passos

1. **Configurar empresa** - Upload logo e dados
2. **Criar usuários** - Adicionar equipe
3. **Importar dados** - Se tiver inventário existente
4. **Configurar alertas** - Monitoramento proativo
5. **Testar backup** - Garantir recuperação
6. **Documentar** - Processos e configurações

---

## 📞 Suporte Azure

**Documentação:**
- https://docs.microsoft.com/azure/app-service/

**Suporte:**
- Portal Azure → Help + support
- Fóruns: https://docs.microsoft.com/answers/

**Preços:**
- https://azure.microsoft.com/pricing/calculator/

---

## ✨ Vantagens do Azure App Service

- ✅ **Gerenciamento Zero:** Sem servidores para gerenciar
- ✅ **Alta Disponibilidade:** SLA 99.95%
- ✅ **Escalabilidade:** Manual ou automática
- ✅ **Segurança:** SSL gratuito, WAF, DDoS protection
- ✅ **Backup:** Automático e sob demanda
- ✅ **Monitoramento:** Application Insights integrado
- ✅ **CI/CD:** GitHub Actions, Azure DevOps
- ✅ **Compliance:** ISO, SOC, HIPAA, PCI DSS

---

**Instalação no Azure concluída!** ☁️🎉

Seu sistema está rodando em uma plataforma enterprise-grade com:
- ✅ Infraestrutura gerenciada
- ✅ Alta disponibilidade
- ✅ Escalabilidade automática
- ✅ Backup automático
- ✅ Monitoramento integrado
- ✅ SSL incluído

**Acesse:** https://inventory-app-prod.azurewebsites.net
