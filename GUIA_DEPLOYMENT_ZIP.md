# 📦 Guia de Criação de Pacote ZIP para Deployment

## 🎯 Sobre

O script `create_deployment_package.py` cria um arquivo ZIP otimizado contendo apenas os arquivos necessários para deployment em produção.

**O que faz:**
- ✅ Inclui apenas arquivos essenciais
- ✅ Exclui arquivos de desenvolvimento
- ✅ Exclui documentação desnecessária
- ✅ Exclui logs e uploads
- ✅ Gera nome com timestamp
- ✅ Mostra estatísticas

---

## 🚀 Como Usar

### Passo 1: Executar o Script

```bash
# No diretório do projeto
python create_deployment_package.py
```

### Passo 2: Aguardar Criação

```
============================================================
CRIANDO PACOTE DE DEPLOYMENT
============================================================

Arquivo: it-inventory-deployment-20251112_220000.zip

✓ Adicionado: app/__init__.py
✓ Adicionado: app/models/user.py
✓ Adicionado: app/routes/auth.py
...

============================================================
PACOTE CRIADO COM SUCESSO!
============================================================

Arquivo: it-inventory-deployment-20251112_220000.zip
Tamanho: 2.45 MB (2,567,890 bytes)
Arquivos incluídos: 127
Arquivos excluídos: 89
```

---

## 📋 Arquivos Incluídos

### Código da Aplicação
- ✅ `app/` - Todo o código da aplicação
- ✅ `migrations/` - Migrações do banco
- ✅ `config.py` - Configurações
- ✅ `run.py` - Ponto de entrada

### Deployment
- ✅ `requirements.txt` - Dependências Python
- ✅ `startup.sh` - Script de inicialização (Azure)
- ✅ `.deployment` - Config deployment (Azure)
- ✅ `runtime.txt` - Versão Python (Azure)
- ✅ `gunicorn_config.py` - Config Gunicorn

### Utilitários
- ✅ `create_company_settings_table.py` - Inicialização

---

## 🚫 Arquivos Excluídos

### Desenvolvimento
- ❌ `venv/`, `env/` - Ambientes virtuais
- ❌ `__pycache__/`, `*.pyc` - Cache Python
- ❌ `.vscode/`, `.idea/` - IDEs
- ❌ `.git/` - Controle de versão

### Dados Locais
- ❌ `*.db`, `*.sqlite` - Bancos locais
- ❌ `.env` - Variáveis de ambiente locais
- ❌ `logs/` - Logs de desenvolvimento
- ❌ `uploads/` - Uploads locais
- ❌ `backups/` - Backups locais

### Documentação
- ❌ `README.md`
- ❌ `INSTALACAO_*.md`
- ❌ `GUIA_*.md`
- ❌ Outros arquivos `.md` de documentação

### Scripts de Desenvolvimento
- ❌ `test_*.py` - Scripts de teste
- ❌ `translate_system.py`
- ❌ `create_excel_templates.py`
- ❌ `install_linux.sh`

---

## 📤 Upload para Diferentes Plataformas

### Azure App Service

**Opção 1: Via Portal (Recomendado)**

1. Acessar Azure Portal
2. Ir para App Service
3. Menu lateral → **Deployment Center**
4. Clicar em **ZIP Deploy**
5. Selecionar arquivo ZIP
6. Clicar em **Upload**
7. Aguardar deployment

**Opção 2: Via Azure CLI**

```bash
az webapp deployment source config-zip \
  --resource-group rg-inventory-prod \
  --name inventory-app-prod \
  --src it-inventory-deployment-20251112_220000.zip
```

**Opção 3: Via Kudu**

```
https://inventory-app-prod.scm.azurewebsites.net/ZipDeployUI
```

---

### VPS Linux

**Via SCP:**

```bash
# Upload do ZIP
scp it-inventory-deployment-20251112_220000.zip user@servidor:/tmp/

# Conectar via SSH
ssh user@servidor

# Extrair
cd /home/inventory
unzip /tmp/it-inventory-deployment-20251112_220000.zip -d it-inventory

# Ajustar permissões
chown -R inventory:inventory it-inventory
chmod -R 755 it-inventory

# Reiniciar
sudo supervisorctl restart inventory
```

**Via SFTP:**

1. Usar FileZilla ou WinSCP
2. Conectar no servidor
3. Upload do ZIP para `/tmp/`
4. Extrair via SSH (comandos acima)

---

### VPS Windows

**Via RDP:**

1. Conectar via Remote Desktop
2. Copiar arquivo ZIP
3. Extrair para `C:\inetpub\inventory`
4. Reiniciar serviço:
   ```powershell
   Restart-Service InventoryService
   ```

**Via PowerShell Remoto:**

```powershell
# Upload
$session = New-PSSession -ComputerName servidor -Credential (Get-Credential)
Copy-Item -Path "it-inventory-deployment-20251112_220000.zip" -Destination "C:\temp\" -ToSession $session

# Extrair
Invoke-Command -Session $session -ScriptBlock {
    Expand-Archive -Path "C:\temp\it-inventory-deployment-20251112_220000.zip" -DestinationPath "C:\inetpub\inventory" -Force
    Restart-Service InventoryService
}
```

---

## 🔄 Atualização de Produção

### Processo Recomendado

**1. Criar Backup:**

```bash
# Azure
az webapp config backup create --resource-group rg-inventory-prod --webapp-name inventory-app-prod

# Linux
/home/inventory/backup.sh

# Windows
C:\inetpub\inventory\backup.ps1
```

**2. Criar Novo Pacote:**

```bash
python create_deployment_package.py
```

**3. Testar Localmente (Opcional):**

```bash
# Extrair em diretório temporário
mkdir test-deploy
unzip it-inventory-deployment-*.zip -d test-deploy
cd test-deploy

# Testar
python -m venv venv
source venv/bin/activate  # Linux
# ou
venv\Scripts\activate  # Windows

pip install -r requirements.txt
python run.py
```

**4. Deploy:**

Seguir instruções da plataforma (Azure/Linux/Windows)

**5. Verificar:**

```bash
# Acessar aplicação
curl https://seu-dominio.com

# Verificar logs
# Azure: Portal → Log stream
# Linux: tail -f /home/inventory/it-inventory/logs/gunicorn-error.log
# Windows: Get-Content C:\inetpub\inventory\logs\service-error.log -Tail 50
```

---

## 📊 Tamanho Esperado

**Pacote típico:**
- **Tamanho:** 2-5 MB
- **Arquivos:** 100-150
- **Tempo upload:** 10-30 segundos

**Se muito grande (>10MB):**
- Verificar se não incluiu `venv/`
- Verificar se não incluiu `logs/`
- Verificar se não incluiu `uploads/`

---

## 🔧 Personalizar Exclusões

Editar `create_deployment_package.py`:

```python
# Adicionar mais exclusões
EXCLUDE_PATTERNS = [
    # ... existentes ...
    'meu_arquivo.txt',
    'minha_pasta/',
    '*.tmp',
]

# Adicionar mais inclusões
INCLUDE_PATTERNS = [
    # ... existentes ...
    'meu_script.py',
]
```

---

## 🐛 Solução de Problemas

### Erro: Arquivo muito grande

```bash
# Verificar conteúdo
unzip -l it-inventory-deployment-*.zip | more

# Procurar arquivos grandes
unzip -l it-inventory-deployment-*.zip | sort -k4 -n | tail -20
```

### Erro: Faltam arquivos

```bash
# Listar conteúdo
unzip -l it-inventory-deployment-*.zip | grep "app/"

# Verificar se tem todos os arquivos necessários
```

### Erro no deployment

```bash
# Verificar estrutura
unzip -l it-inventory-deployment-*.zip | head -20

# Deve ter:
# - app/
# - config.py
# - run.py
# - requirements.txt
```

---

## 📝 Checklist Pré-Deployment

Antes de criar o ZIP:

- [ ] Código testado localmente
- [ ] Todas as alterações commitadas (se usar Git)
- [ ] `requirements.txt` atualizado
- [ ] `.env` não está incluído (usar variáveis do servidor)
- [ ] Versão atualizada em `config.py`
- [ ] Migrations criadas (se houver mudanças no banco)

Após criar o ZIP:

- [ ] Tamanho razoável (2-5 MB)
- [ ] Arquivos essenciais incluídos
- [ ] Sem arquivos de desenvolvimento
- [ ] Testado em ambiente de staging (se disponível)

---

## 🎯 Automação (Opcional)

### Script de Deploy Completo

```bash
#!/bin/bash
# deploy.sh

echo "1. Criando pacote..."
python create_deployment_package.py

echo "2. Obtendo nome do arquivo..."
ZIP_FILE=$(ls -t it-inventory-deployment-*.zip | head -1)

echo "3. Fazendo upload para Azure..."
az webapp deployment source config-zip \
  --resource-group rg-inventory-prod \
  --name inventory-app-prod \
  --src "$ZIP_FILE"

echo "4. Aguardando deployment..."
sleep 30

echo "5. Verificando..."
curl -I https://inventory-app-prod.azurewebsites.net

echo "✓ Deploy concluído!"
```

Usar:
```bash
chmod +x deploy.sh
./deploy.sh
```

---

## 💡 Dicas

1. **Mantenha backups:** Sempre faça backup antes de atualizar
2. **Teste localmente:** Extraia e teste o ZIP antes de fazer deploy
3. **Use staging:** Se possível, teste em ambiente de staging primeiro
4. **Monitore logs:** Acompanhe logs após deployment
5. **Versionamento:** Mantenha os ZIPs antigos por segurança

---

## ✅ Resumo

**Criar pacote:**
```bash
python create_deployment_package.py
```

**Upload Azure:**
```bash
Portal → Deployment Center → ZIP Deploy
```

**Upload Linux:**
```bash
scp *.zip user@servidor:/tmp/
ssh user@servidor
unzip /tmp/*.zip -d /home/inventory/it-inventory
```

**Upload Windows:**
```
RDP → Copiar → Extrair → Reiniciar serviço
```

---

**Pacote pronto para deployment em qualquer plataforma!** 📦🚀
