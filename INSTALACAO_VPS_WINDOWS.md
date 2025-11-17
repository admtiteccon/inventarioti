# 🪟 Guia de Instalação - VPS Windows Server

## 📋 Pré-requisitos

- Windows Server 2019+ ou Windows 10/11 Pro
- Acesso de Administrador
- Domínio apontado para o IP (opcional)
- Mínimo: 2GB RAM, 20GB disco

---

## 🚀 Instalação Passo a Passo

### Passo 1: Conectar ao Servidor

```
1. Abrir "Conexão de Área de Trabalho Remota"
2. Digitar IP do servidor
3. Conectar com usuário Administrador
```

---

### Passo 2: Instalar Python

**Baixar Python 3.11:**
```
https://www.python.org/downloads/windows/
```

**Instalação:**
1. Executar instalador
2. ✅ Marcar "Add Python to PATH"
3. Clicar "Install Now"
4. Aguardar conclusão

**Verificar:**
```powershell
# Abrir PowerShell como Administrador
python --version
pip --version
```

---

### Passo 3: Instalar PostgreSQL

**Baixar PostgreSQL 15:**
```
https://www.postgresql.org/download/windows/
```

**Instalação:**
1. Executar instalador
2. Senha do superusuário: `SuaSenhaSegura123!`
3. Porta: `5432` (padrão)
4. Locale: `Portuguese, Brazil`
5. Concluir instalação

**Configurar Banco:**
```powershell
# Abrir SQL Shell (psql)
# Pressionar Enter para valores padrão
# Digitar senha do postgres

# Criar banco e usuário
CREATE DATABASE inventory_db;
CREATE USER inventory_user WITH PASSWORD 'SuaSenhaSegura123!';
ALTER ROLE inventory_user SET client_encoding TO 'utf8';
ALTER ROLE inventory_user SET default_transaction_isolation TO 'read committed';
ALTER ROLE inventory_user SET timezone TO 'America/Sao_Paulo';
GRANT ALL PRIVILEGES ON DATABASE inventory_db TO inventory_user;
\q
```

---

### Passo 4: Instalar IIS (Internet Information Services)

**Via PowerShell (Administrador):**
```powershell
# Instalar IIS
Install-WindowsFeature -name Web-Server -IncludeManagementTools

# Instalar módulos adicionais
Install-WindowsFeature Web-CGI
Install-WindowsFeature Web-ISAPI-Ext
Install-WindowsFeature Web-ISAPI-Filter
```

**Verificar:**
```
Abrir navegador: http://localhost
Deve aparecer página padrão do IIS
```

---

### Passo 5: Instalar URL Rewrite e HttpPlatformHandler

**URL Rewrite:**
```
https://www.iis.net/downloads/microsoft/url-rewrite
```

**HttpPlatformHandler:**
```
https://www.iis.net/downloads/microsoft/httpplatformhandler
```

Baixar e instalar ambos.

---

### Passo 6: Preparar Diretório da Aplicação

```powershell
# Criar diretório
New-Item -Path "C:\inetpub\inventory" -ItemType Directory

# Copiar arquivos do projeto
# Opção 1: Via RDP (copiar/colar)
# Opção 2: Via FTP
# Opção 3: Via Git (se instalado)

# Exemplo com Git:
cd C:\inetpub
git clone https://github.com/seu-usuario/it-inventory.git inventory
```

---

### Passo 7: Configurar Ambiente Virtual

```powershell
# Navegar para o diretório
cd C:\inetpub\inventory

# Criar ambiente virtual
python -m venv venv

# Ativar ambiente virtual
.\venv\Scripts\Activate.ps1

# Se houver erro de execução de scripts:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Atualizar pip
python -m pip install --upgrade pip

# Instalar dependências
pip install -r requirements.txt

# Instalar waitress (servidor WSGI para Windows)
pip install waitress
```

---

### Passo 8: Configurar Variáveis de Ambiente

**Criar arquivo `.env`:**
```powershell
notepad .env
```

**Conteúdo:**
```ini
# Flask Configuration
SECRET_KEY=gere-uma-chave-secreta-aleatoria-aqui
FLASK_ENV=production

# Database Configuration (PostgreSQL)
DATABASE_URL=postgresql://inventory_user:SuaSenhaSegura123!@localhost:5432/inventory_db

# Mail Configuration (Gmail exemplo)
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USE_TLS=true
MAIL_USERNAME=seu-email@gmail.com
MAIL_PASSWORD=sua-senha-de-app
MAIL_DEFAULT_SENDER=noreply@seudominio.com

# Application Settings
APP_NAME=IT Inventory System
APP_ADMIN_EMAIL=admin@seudominio.com

# Footer Customization
FOOTER_COMPANY_NAME=Sua Empresa LTDA
FOOTER_YEAR=2025
FOOTER_VERSION=1.0.0
FOOTER_DOCS_URL=https://docs.seudominio.com
FOOTER_SUPPORT_EMAIL=suporte@seudominio.com

# Session Configuration
SESSION_LIFETIME_HOURS=24

# File Upload
UPLOAD_FOLDER=C:\inetpub\inventory\uploads
MAX_CONTENT_LENGTH=16777216

# Scheduler
SCHEDULER_TIMEZONE=America/Sao_Paulo
```

**Gerar SECRET_KEY:**
```powershell
python -c "import secrets; print(secrets.token_hex(32))"
```

---

### Passo 9: Inicializar Banco de Dados

```powershell
# Ativar ambiente virtual
.\venv\Scripts\Activate.ps1

# Criar tabelas
python -c "from app import create_app, db; app = create_app('production'); app.app_context().push(); db.create_all(); print('Tabelas criadas!')"

# Criar tabela de configurações
python create_company_settings_table.py

# Criar usuário administrador
python run.py create-admin
```

---

### Passo 10: Criar Script de Inicialização

**Criar arquivo `start_server.py`:**
```powershell
notepad start_server.py
```

**Conteúdo:**
```python
"""
Script para iniciar o servidor em produção no Windows
"""
import os
from dotenv import load_dotenv
from waitress import serve
from app import create_app

# Carregar variáveis de ambiente
load_dotenv()

# Criar aplicação
app = create_app('production')

if __name__ == '__main__':
    # Configurações do servidor
    host = '127.0.0.1'
    port = 8000
    threads = 4
    
    print(f"Iniciando servidor em {host}:{port}")
    print(f"Threads: {threads}")
    print("Pressione Ctrl+C para parar")
    
    # Iniciar servidor Waitress
    serve(
        app,
        host=host,
        port=port,
        threads=threads,
        url_scheme='http',
        ident='IT Inventory System'
    )
```

**Testar:**
```powershell
python start_server.py
# Abrir navegador: http://localhost:8000
# Se funcionar, pressionar Ctrl+C
```

---

### Passo 11: Configurar como Serviço do Windows

**Instalar NSSM (Non-Sucking Service Manager):**
```
https://nssm.cc/download
```

1. Baixar nssm-2.24.zip
2. Extrair para `C:\nssm`
3. Adicionar ao PATH do sistema

**Criar Serviço:**
```powershell
# Abrir PowerShell como Administrador
cd C:\nssm\win64

# Instalar serviço
.\nssm.exe install InventoryService "C:\inetpub\inventory\venv\Scripts\python.exe" "C:\inetpub\inventory\start_server.py"

# Configurar diretório de trabalho
.\nssm.exe set InventoryService AppDirectory "C:\inetpub\inventory"

# Configurar saída de logs
.\nssm.exe set InventoryService AppStdout "C:\inetpub\inventory\logs\service-output.log"
.\nssm.exe set InventoryService AppStderr "C:\inetpub\inventory\logs\service-error.log"

# Configurar reinício automático
.\nssm.exe set InventoryService AppExit Default Restart
.\nssm.exe set InventoryService AppRestartDelay 5000

# Iniciar serviço
.\nssm.exe start InventoryService

# Verificar status
.\nssm.exe status InventoryService
```

**Ou via Services.msc:**
```
1. Win+R → services.msc
2. Procurar "InventoryService"
3. Clicar com botão direito → Propriedades
4. Tipo de inicialização: Automático
5. Iniciar o serviço
```

---

### Passo 12: Configurar IIS como Proxy Reverso

**Criar Site no IIS:**

1. Abrir "Gerenciador do IIS"
2. Clicar com botão direito em "Sites" → "Adicionar Site"
3. Configurar:
   - Nome do site: `Inventory`
   - Caminho físico: `C:\inetpub\inventory\app\static`
   - Tipo: `http`
   - Porta: `80`
   - Nome do host: `seudominio.com`

**Configurar web.config:**
```powershell
notepad C:\inetpub\inventory\web.config
```

**Conteúdo:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <system.webServer>
        <handlers>
            <add name="httpPlatformHandler" path="*" verb="*" 
                 modules="httpPlatformHandler" resourceType="Unspecified" 
                 requireAccess="Script" />
        </handlers>
        <httpPlatform processPath="C:\inetpub\inventory\venv\Scripts\python.exe"
                      arguments="C:\inetpub\inventory\start_server.py"
                      startupTimeLimit="60"
                      startupRetryCount="3"
                      stdoutLogEnabled="true"
                      stdoutLogFile="C:\inetpub\inventory\logs\iis-python.log">
            <environmentVariables>
                <environmentVariable name="PYTHONPATH" value="C:\inetpub\inventory" />
            </environmentVariables>
        </httpPlatform>
        
        <!-- Rewrite rules -->
        <rewrite>
            <rules>
                <rule name="Static Files" stopProcessing="true">
                    <match url="^static/(.*)$" />
                    <action type="Rewrite" url="app/static/{R:1}" />
                </rule>
                <rule name="Proxy to Python" stopProcessing="true">
                    <match url="(.*)" />
                    <conditions>
                        <add input="{REQUEST_FILENAME}" matchType="IsFile" negate="true" />
                        <add input="{REQUEST_FILENAME}" matchType="IsDirectory" negate="true" />
                    </conditions>
                    <action type="Rewrite" url="http://localhost:8000/{R:1}" />
                </rule>
            </rules>
        </rewrite>
        
        <!-- Security -->
        <security>
            <requestFiltering>
                <requestLimits maxAllowedContentLength="20971520" />
            </requestFiltering>
        </security>
    </system.webServer>
</configuration>
```

**Reiniciar IIS:**
```powershell
iisreset
```

---

### Passo 13: Configurar SSL (HTTPS)

**Opção 1: Certificado Let's Encrypt (Gratuito)**

**Instalar Win-ACME:**
```
https://www.win-acme.com/
```

1. Baixar e extrair
2. Executar `wacs.exe` como Administrador
3. Seguir assistente:
   - Escolher opção "N" (novo certificado)
   - Selecionar site IIS
   - Escolher validação HTTP
   - Confirmar

**Opção 2: Certificado Próprio**

1. Abrir "Gerenciador do IIS"
2. Selecionar servidor → "Certificados de Servidor"
3. "Criar Certificado Autoassinado"
4. Nome: `Inventory SSL`
5. Voltar ao site → "Ligações" → "Adicionar"
6. Tipo: `https`, Porta: `443`
7. Certificado SSL: Selecionar o criado

---

### Passo 14: Configurar Firewall

```powershell
# Abrir PowerShell como Administrador

# Permitir HTTP
New-NetFirewallRule -DisplayName "HTTP Inventory" -Direction Inbound -Protocol TCP -LocalPort 80 -Action Allow

# Permitir HTTPS
New-NetFirewallRule -DisplayName "HTTPS Inventory" -Direction Inbound -Protocol TCP -LocalPort 443 -Action Allow

# Permitir RDP (se ainda não estiver)
New-NetFirewallRule -DisplayName "RDP" -Direction Inbound -Protocol TCP -LocalPort 3389 -Action Allow
```

---

### Passo 15: Configurar Backup Automático

**Criar script de backup:**
```powershell
notepad C:\inetpub\inventory\backup.ps1
```

**Conteúdo:**
```powershell
# Configurações
$BackupDir = "C:\Backups\Inventory"
$Date = Get-Date -Format "yyyyMMdd_HHmmss"
$DBName = "inventory_db"
$DBUser = "inventory_user"
$DBPassword = "SuaSenhaSegura123!"
$AppDir = "C:\inetpub\inventory"

# Criar diretório de backup
New-Item -Path $BackupDir -ItemType Directory -Force

# Backup do banco de dados
$env:PGPASSWORD = $DBPassword
& "C:\Program Files\PostgreSQL\15\bin\pg_dump.exe" -U $DBUser -h localhost $DBName > "$BackupDir\db_$Date.sql"

# Backup dos uploads
Compress-Archive -Path "$AppDir\app\static\uploads" -DestinationPath "$BackupDir\uploads_$Date.zip"

# Manter apenas últimos 7 dias
Get-ChildItem $BackupDir -Filter "db_*.sql" | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-7)} | Remove-Item
Get-ChildItem $BackupDir -Filter "uploads_*.zip" | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-7)} | Remove-Item

Write-Host "Backup concluído: $Date"
```

**Agendar backup:**
```
1. Win+R → taskschd.msc
2. "Criar Tarefa Básica"
3. Nome: "Backup Inventory"
4. Gatilho: Diariamente às 02:00
5. Ação: Iniciar programa
   - Programa: powershell.exe
   - Argumentos: -ExecutionPolicy Bypass -File "C:\inetpub\inventory\backup.ps1"
6. Concluir
```

---

## 🎯 Comandos Úteis

### Gerenciar Serviço

```powershell
# Ver status
Get-Service InventoryService

# Iniciar
Start-Service InventoryService

# Parar
Stop-Service InventoryService

# Reiniciar
Restart-Service InventoryService

# Ver logs
Get-Content C:\inetpub\inventory\logs\service-error.log -Tail 50
```

### Gerenciar IIS

```powershell
# Reiniciar IIS
iisreset

# Parar IIS
iisreset /stop

# Iniciar IIS
iisreset /start

# Ver sites
Get-IISSite
```

### Atualizar Aplicação

```powershell
# Parar serviço
Stop-Service InventoryService

# Navegar para diretório
cd C:\inetpub\inventory

# Ativar ambiente virtual
.\venv\Scripts\Activate.ps1

# Atualizar código (se usando Git)
git pull origin main

# Atualizar dependências
pip install -r requirements.txt

# Reiniciar serviço
Start-Service InventoryService
```

---

## 🔒 Segurança Adicional

### 1. Desabilitar Serviços Desnecessários

```powershell
# Listar serviços em execução
Get-Service | Where-Object {$_.Status -eq "Running"}

# Desabilitar serviços não usados (exemplo)
Stop-Service -Name "Print Spooler"
Set-Service -Name "Print Spooler" -StartupType Disabled
```

### 2. Configurar Windows Defender

```powershell
# Adicionar exclusão para melhor performance
Add-MpPreference -ExclusionPath "C:\inetpub\inventory"
```

### 3. Atualizar Windows

```
1. Configurações → Atualização e Segurança
2. Windows Update → Verificar atualizações
3. Instalar todas as atualizações
4. Reiniciar se necessário
```

---

## 📊 Monitoramento

### Gerenciador de Tarefas

```
Ctrl+Shift+Esc
- Verificar uso de CPU/RAM
- Procurar processo "python.exe"
```

### Monitor de Desempenho

```
Win+R → perfmon
- Adicionar contadores de CPU, Memória, Disco
- Monitorar em tempo real
```

### Logs Importantes

```
- Aplicação: C:\inetpub\inventory\logs\service-error.log
- IIS: C:\inetpub\logs\LogFiles\
- Sistema: Visualizador de Eventos (eventvwr.msc)
```

---

## ✅ Verificação Final

Acesse seu domínio:
```
https://seudominio.com
```

Deve aparecer:
- ✅ Página de login
- ✅ HTTPS ativo (se configurado)
- ✅ Logo da empresa (se configurado)
- ✅ Sistema funcionando

---

## 🆘 Solução de Problemas

### Serviço não inicia

```powershell
# Ver logs
Get-Content C:\inetpub\inventory\logs\service-error.log -Tail 50

# Testar manualmente
cd C:\inetpub\inventory
.\venv\Scripts\Activate.ps1
python start_server.py
```

### Erro 500 no IIS

```powershell
# Habilitar erros detalhados
# Editar web.config, adicionar:
<system.web>
    <customErrors mode="Off"/>
</system.web>

# Ver logs do IIS
Get-Content C:\inetpub\inventory\logs\iis-python.log -Tail 50
```

### Banco de dados não conecta

```powershell
# Verificar se PostgreSQL está rodando
Get-Service postgresql*

# Testar conexão
& "C:\Program Files\PostgreSQL\15\bin\psql.exe" -U inventory_user -d inventory_db -h localhost
```

### Uploads não funcionam

```powershell
# Verificar permissões
icacls "C:\inetpub\inventory\app\static\uploads" /grant "IIS_IUSRS:(OI)(CI)F"
```

---

## 📦 Estrutura de Diretórios

```
C:\inetpub\inventory\
├── app\                    # Aplicação Flask
├── venv\                   # Ambiente virtual
├── logs\                   # Logs do sistema
├── uploads\                # Arquivos enviados
├── .env                    # Variáveis de ambiente
├── start_server.py         # Script de inicialização
├── web.config              # Configuração IIS
└── backup.ps1              # Script de backup
```

---

**Instalação Completa!** 🎉

Seu sistema está rodando em produção no Windows com:
- ✅ IIS como proxy reverso
- ✅ Serviço Windows automático
- ✅ Banco PostgreSQL
- ✅ Backup automático agendado
- ✅ Firewall configurado
- ✅ Logs organizados

**Suporte:** Consulte os logs em caso de problemas!
