# 🐧 Guia de Instalação - VPS Linux (Ubuntu/Debian)

## 📋 Pré-requisitos

- VPS com Ubuntu 20.04+ ou Debian 11+
- Acesso root ou sudo
- Domínio apontado para o IP da VPS (opcional)
- Mínimo: 1GB RAM, 10GB disco

---

## 🚀 Instalação Passo a Passo

### Passo 1: Atualizar o Sistema

```bash
# Conectar via SSH
ssh root@seu-servidor.com

# Atualizar pacotes
sudo apt update
sudo apt upgrade -y
```

---

### Passo 2: Instalar Dependências

```bash
# Instalar Python 3.9+ e ferramentas
sudo apt install -y python3 python3-pip python3-venv python3-dev

# Instalar PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Instalar Nginx
sudo apt install -y nginx

# Instalar Git
sudo apt install -y git

# Instalar supervisor (gerenciador de processos)
sudo apt install -y supervisor

# Instalar certbot (SSL gratuito)
sudo apt install -y certbot python3-certbot-nginx
```

---

### Passo 3: Configurar PostgreSQL

```bash
# Entrar no PostgreSQL
sudo -u postgres psql

# Criar banco de dados e usuário
CREATE DATABASE inventory_db;
CREATE USER inventory_user WITH PASSWORD 'SuaSenhaSegura123!';
ALTER ROLE inventory_user SET client_encoding TO 'utf8';
ALTER ROLE inventory_user SET default_transaction_isolation TO 'read committed';
ALTER ROLE inventory_user SET timezone TO 'America/Sao_Paulo';
GRANT ALL PRIVILEGES ON DATABASE inventory_db TO inventory_user;
\q

# Testar conexão
psql -U inventory_user -d inventory_db -h localhost
# Digite a senha quando solicitado
# Se conectar, digite \q para sair
```

---

### Passo 4: Criar Usuário do Sistema

```bash
# Criar usuário sem privilégios root
sudo adduser inventory
sudo usermod -aG sudo inventory

# Mudar para o novo usuário
sudo su - inventory
```

---

### Passo 5: Clonar/Enviar o Projeto

**Opção A: Via Git (Recomendado)**

```bash
# Clonar repositório
cd /home/inventory
git clone https://github.com/seu-usuario/it-inventory.git
cd it-inventory
```

**Opção B: Via SCP (Upload Manual)**

```bash
# No seu computador local
scp -r C:\Users\ADM.TECCON\CODIGOS PYTHON\INVENTARIO inventory@seu-servidor.com:/home/inventory/it-inventory

# No servidor
cd /home/inventory/it-inventory
```

---

### Passo 6: Configurar Ambiente Virtual

```bash
# Criar ambiente virtual
python3 -m venv venv

# Ativar ambiente virtual
source venv/bin/activate

# Atualizar pip
pip install --upgrade pip

# Instalar dependências
pip install -r requirements.txt

# Instalar Gunicorn (servidor WSGI)
pip install gunicorn
```

---

### Passo 7: Configurar Variáveis de Ambiente

```bash
# Criar arquivo .env
nano .env
```

**Conteúdo do .env:**

```bash
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
UPLOAD_FOLDER=/home/inventory/it-inventory/uploads
MAX_CONTENT_LENGTH=16777216

# Scheduler
SCHEDULER_TIMEZONE=America/Sao_Paulo
```

**Salvar:** `Ctrl+O`, `Enter`, `Ctrl+X`

**Gerar SECRET_KEY:**

```bash
python3 -c "import secrets; print(secrets.token_hex(32))"
```

---

### Passo 8: Inicializar Banco de Dados

```bash
# Ativar ambiente virtual (se não estiver ativo)
source venv/bin/activate

# Criar tabelas
python3 -c "from app import create_app, db; app = create_app('production'); app.app_context().push(); db.create_all(); print('Tabelas criadas!')"

# Criar tabela de configurações da empresa
python3 create_company_settings_table.py

# Criar usuário administrador
python3 run.py create-admin
# Preencha: Nome, Email, Senha
```

---

### Passo 9: Testar Aplicação

```bash
# Testar com servidor de desenvolvimento
python3 run.py

# Abrir em outro terminal e testar
curl http://localhost:5000

# Se funcionar, pressione Ctrl+C para parar
```

---

### Passo 10: Configurar Gunicorn

```bash
# Criar arquivo de configuração
nano gunicorn_config.py
```

**Conteúdo:**

```python
import multiprocessing

# Bind
bind = "127.0.0.1:8000"

# Workers
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = "sync"
worker_connections = 1000
timeout = 120
keepalive = 5

# Logging
accesslog = "/home/inventory/it-inventory/logs/gunicorn-access.log"
errorlog = "/home/inventory/it-inventory/logs/gunicorn-error.log"
loglevel = "info"

# Process naming
proc_name = "inventory_app"

# Server mechanics
daemon = False
pidfile = "/home/inventory/it-inventory/gunicorn.pid"
```

**Criar diretório de logs:**

```bash
mkdir -p /home/inventory/it-inventory/logs
```

---

### Passo 11: Configurar Supervisor

```bash
# Voltar para root
exit

# Criar arquivo de configuração do Supervisor
sudo nano /etc/supervisor/conf.d/inventory.conf
```

**Conteúdo:**

```ini
[program:inventory]
command=/home/inventory/it-inventory/venv/bin/gunicorn -c /home/inventory/it-inventory/gunicorn_config.py run:app
directory=/home/inventory/it-inventory
user=inventory
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
stderr_logfile=/home/inventory/it-inventory/logs/supervisor-error.log
stdout_logfile=/home/inventory/it-inventory/logs/supervisor-access.log
environment=PATH="/home/inventory/it-inventory/venv/bin"
```

**Ativar:**

```bash
# Recarregar configuração
sudo supervisorctl reread
sudo supervisorctl update

# Iniciar aplicação
sudo supervisorctl start inventory

# Verificar status
sudo supervisorctl status inventory
```

---

### Passo 12: Configurar Nginx

```bash
# Criar configuração do site
sudo nano /etc/nginx/sites-available/inventory
```

**Conteúdo:**

```nginx
server {
    listen 80;
    server_name seudominio.com www.seudominio.com;

    # Logs
    access_log /var/log/nginx/inventory-access.log;
    error_log /var/log/nginx/inventory-error.log;

    # Tamanho máximo de upload
    client_max_body_size 20M;

    # Proxy para Gunicorn
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;
        
        # Timeouts
        proxy_connect_timeout 120s;
        proxy_send_timeout 120s;
        proxy_read_timeout 120s;
    }

    # Arquivos estáticos
    location /static {
        alias /home/inventory/it-inventory/app/static;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # Uploads
    location /static/uploads {
        alias /home/inventory/it-inventory/app/static/uploads;
        expires 7d;
    }
}
```

**Ativar site:**

```bash
# Criar link simbólico
sudo ln -s /etc/nginx/sites-available/inventory /etc/nginx/sites-enabled/

# Remover site padrão
sudo rm /etc/nginx/sites-enabled/default

# Testar configuração
sudo nginx -t

# Reiniciar Nginx
sudo systemctl restart nginx
```

---

### Passo 13: Configurar SSL (HTTPS)

```bash
# Obter certificado SSL gratuito
sudo certbot --nginx -d seudominio.com -d www.seudominio.com

# Seguir instruções:
# 1. Digite seu email
# 2. Aceite os termos
# 3. Escolha redirecionar HTTP para HTTPS (opção 2)

# Testar renovação automática
sudo certbot renew --dry-run
```

---

### Passo 14: Configurar Firewall

```bash
# Permitir SSH, HTTP e HTTPS
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'

# Ativar firewall
sudo ufw enable

# Verificar status
sudo ufw status
```

---

### Passo 15: Configurar Backup Automático

```bash
# Criar script de backup
sudo nano /home/inventory/backup.sh
```

**Conteúdo:**

```bash
#!/bin/bash

# Configurações
BACKUP_DIR="/home/inventory/backups"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="inventory_db"
DB_USER="inventory_user"
APP_DIR="/home/inventory/it-inventory"

# Criar diretório de backup
mkdir -p $BACKUP_DIR

# Backup do banco de dados
PGPASSWORD='SuaSenhaSegura123!' pg_dump -U $DB_USER -h localhost $DB_NAME > $BACKUP_DIR/db_$DATE.sql

# Backup dos uploads
tar -czf $BACKUP_DIR/uploads_$DATE.tar.gz $APP_DIR/app/static/uploads

# Manter apenas últimos 7 dias
find $BACKUP_DIR -name "db_*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "uploads_*.tar.gz" -mtime +7 -delete

echo "Backup concluído: $DATE"
```

**Tornar executável:**

```bash
sudo chmod +x /home/inventory/backup.sh
```

**Agendar backup diário:**

```bash
# Editar crontab
sudo crontab -e

# Adicionar linha (backup às 2h da manhã)
0 2 * * * /home/inventory/backup.sh >> /home/inventory/backup.log 2>&1
```

---

## 🎯 Comandos Úteis

### Gerenciar Aplicação

```bash
# Ver status
sudo supervisorctl status inventory

# Reiniciar
sudo supervisorctl restart inventory

# Parar
sudo supervisorctl stop inventory

# Iniciar
sudo supervisorctl start inventory

# Ver logs
tail -f /home/inventory/it-inventory/logs/gunicorn-error.log
```

### Gerenciar Nginx

```bash
# Testar configuração
sudo nginx -t

# Reiniciar
sudo systemctl restart nginx

# Ver logs
sudo tail -f /var/log/nginx/inventory-error.log
```

### Atualizar Aplicação

```bash
# Conectar como usuário inventory
sudo su - inventory
cd /home/inventory/it-inventory

# Ativar ambiente virtual
source venv/bin/activate

# Atualizar código (se usando Git)
git pull origin main

# Atualizar dependências
pip install -r requirements.txt

# Reiniciar aplicação
exit
sudo supervisorctl restart inventory
```

---

## 🔒 Segurança Adicional

### 1. Fail2Ban (Proteção contra ataques)

```bash
sudo apt install -y fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### 2. Desabilitar Login Root via SSH

```bash
sudo nano /etc/ssh/sshd_config

# Alterar:
PermitRootLogin no

# Reiniciar SSH
sudo systemctl restart sshd
```

### 3. Configurar PostgreSQL para aceitar apenas localhost

```bash
sudo nano /etc/postgresql/*/main/pg_hba.conf

# Garantir que tenha apenas:
local   all             all                                     peer
host    all             all             127.0.0.1/32            md5
```

---

## 📊 Monitoramento

### Ver uso de recursos

```bash
# CPU e memória
htop

# Espaço em disco
df -h

# Processos Python
ps aux | grep python
```

### Logs importantes

```bash
# Logs da aplicação
tail -f /home/inventory/it-inventory/logs/gunicorn-error.log

# Logs do Nginx
tail -f /var/log/nginx/inventory-error.log

# Logs do sistema
tail -f /var/log/syslog
```

---

## ✅ Verificação Final

Acesse seu domínio:
```
https://seudominio.com
```

Deve aparecer:
- ✅ Página de login
- ✅ HTTPS ativo (cadeado verde)
- ✅ Logo da empresa (se configurado)
- ✅ Sistema funcionando

---

## 🆘 Solução de Problemas

### Erro 502 Bad Gateway

```bash
# Verificar se Gunicorn está rodando
sudo supervisorctl status inventory

# Ver logs
tail -f /home/inventory/it-inventory/logs/gunicorn-error.log
```

### Erro de Banco de Dados

```bash
# Verificar se PostgreSQL está rodando
sudo systemctl status postgresql

# Testar conexão
psql -U inventory_user -d inventory_db -h localhost
```

### Uploads não funcionam

```bash
# Verificar permissões
sudo chown -R inventory:inventory /home/inventory/it-inventory/app/static/uploads
sudo chmod -R 755 /home/inventory/it-inventory/app/static/uploads
```

---

**Instalação Completa!** 🎉

Seu sistema está rodando em produção com:
- ✅ HTTPS (SSL)
- ✅ Banco PostgreSQL
- ✅ Backup automático
- ✅ Firewall configurado
- ✅ Logs organizados
- ✅ Reinício automático

**Suporte:** Consulte os logs em caso de problemas!
