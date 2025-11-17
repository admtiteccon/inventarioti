#!/bin/bash

################################################################################
# Script de Instalação Automática - Sistema de Inventário de TI
# Para Ubuntu 20.04+ / Debian 11+
# Autor: IT Inventory System
# Versão: 1.0.0
################################################################################

set -e  # Parar em caso de erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funções auxiliares
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Verificar se está rodando como root
if [[ $EUID -ne 0 ]]; then
   print_error "Este script deve ser executado como root (use sudo)"
   exit 1
fi

# Banner
clear
echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   Sistema de Inventário de TI - Instalação Automática    ║
║                                                           ║
║   Este script irá instalar e configurar:                 ║
║   • Python 3.9+                                          ║
║   • PostgreSQL                                           ║
║   • Nginx                                                ║
║   • Supervisor                                           ║
║   • Certbot (SSL)                                        ║
║   • Aplicação completa                                   ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}\n"

# Coletar informações do usuário
print_header "CONFIGURAÇÃO INICIAL"

read -p "Nome de domínio (ex: inventory.seudominio.com): " DOMAIN
read -p "Email do administrador: " ADMIN_EMAIL
read -p "Nome da empresa: " COMPANY_NAME
read -sp "Senha do banco de dados PostgreSQL: " DB_PASSWORD
echo
read -sp "Confirme a senha do banco de dados: " DB_PASSWORD_CONFIRM
echo

if [ "$DB_PASSWORD" != "$DB_PASSWORD_CONFIRM" ]; then
    print_error "As senhas não coincidem!"
    exit 1
fi

# Gerar SECRET_KEY
SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")

# Confirmar instalação
echo
print_warning "Configuração:"
echo "  Domínio: $DOMAIN"
echo "  Email: $ADMIN_EMAIL"
echo "  Empresa: $COMPANY_NAME"
echo "  Banco: inventory_db"
echo
read -p "Continuar com a instalação? (s/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    print_info "Instalação cancelada."
    exit 0
fi

# Início da instalação
print_header "PASSO 1: ATUALIZAR SISTEMA"

apt update
apt upgrade -y
print_success "Sistema atualizado"

# Instalar dependências
print_header "PASSO 2: INSTALAR DEPENDÊNCIAS"

apt install -y python3 python3-pip python3-venv python3-dev \
    postgresql postgresql-contrib \
    nginx \
    supervisor \
    git \
    certbot python3-certbot-nginx \
    build-essential libpq-dev

print_success "Dependências instaladas"

# Configurar PostgreSQL
print_header "PASSO 3: CONFIGURAR POSTGRESQL"

sudo -u postgres psql << EOF
CREATE DATABASE inventory_db;
CREATE USER inventory_user WITH PASSWORD '$DB_PASSWORD';
ALTER ROLE inventory_user SET client_encoding TO 'utf8';
ALTER ROLE inventory_user SET default_transaction_isolation TO 'read committed';
ALTER ROLE inventory_user SET timezone TO 'America/Sao_Paulo';
GRANT ALL PRIVILEGES ON DATABASE inventory_db TO inventory_user;
\q
EOF

print_success "PostgreSQL configurado"

# Criar usuário do sistema
print_header "PASSO 4: CRIAR USUÁRIO DO SISTEMA"

if id "inventory" &>/dev/null; then
    print_warning "Usuário 'inventory' já existe"
else
    adduser --disabled-password --gecos "" inventory
    print_success "Usuário 'inventory' criado"
fi

# Criar diretórios
print_header "PASSO 5: PREPARAR DIRETÓRIOS"

mkdir -p /home/inventory/it-inventory
mkdir -p /home/inventory/it-inventory/logs
mkdir -p /home/inventory/backups

print_success "Diretórios criados"

# Copiar arquivos da aplicação
print_header "PASSO 6: INSTALAR APLICAÇÃO"

# Assumindo que o script está no diretório da aplicação
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ "$SCRIPT_DIR" != "/home/inventory/it-inventory" ]; then
    print_info "Copiando arquivos da aplicação..."
    cp -r "$SCRIPT_DIR"/* /home/inventory/it-inventory/
    print_success "Arquivos copiados"
fi

cd /home/inventory/it-inventory

# Criar ambiente virtual
print_info "Criando ambiente virtual..."
sudo -u inventory python3 -m venv venv
print_success "Ambiente virtual criado"

# Instalar dependências Python
print_info "Instalando dependências Python..."
sudo -u inventory /home/inventory/it-inventory/venv/bin/pip install --upgrade pip
sudo -u inventory /home/inventory/it-inventory/venv/bin/pip install -r requirements.txt
sudo -u inventory /home/inventory/it-inventory/venv/bin/pip install gunicorn
print_success "Dependências Python instaladas"

# Criar arquivo .env
print_header "PASSO 7: CONFIGURAR VARIÁVEIS DE AMBIENTE"

cat > /home/inventory/it-inventory/.env << EOF
# Flask Configuration
SECRET_KEY=$SECRET_KEY
FLASK_ENV=production

# Database Configuration
DATABASE_URL=postgresql://inventory_user:$DB_PASSWORD@localhost:5432/inventory_db

# Mail Configuration (Configure depois)
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USE_TLS=true
MAIL_USERNAME=seu-email@gmail.com
MAIL_PASSWORD=sua-senha-de-app
MAIL_DEFAULT_SENDER=noreply@$DOMAIN

# Application Settings
APP_NAME=IT Inventory System
APP_ADMIN_EMAIL=$ADMIN_EMAIL

# Footer Customization
FOOTER_COMPANY_NAME=$COMPANY_NAME
FOOTER_YEAR=$(date +%Y)
FOOTER_VERSION=1.0.0
FOOTER_DOCS_URL=https://$DOMAIN/docs
FOOTER_SUPPORT_EMAIL=$ADMIN_EMAIL

# Session Configuration
SESSION_LIFETIME_HOURS=24

# File Upload
UPLOAD_FOLDER=/home/inventory/it-inventory/uploads
MAX_CONTENT_LENGTH=16777216

# Scheduler
SCHEDULER_TIMEZONE=America/Sao_Paulo
EOF

chown inventory:inventory /home/inventory/it-inventory/.env
print_success "Arquivo .env criado"

# Inicializar banco de dados
print_header "PASSO 8: INICIALIZAR BANCO DE DADOS"

sudo -u inventory /home/inventory/it-inventory/venv/bin/python3 << 'PYEOF'
from app import create_app, db
app = create_app('production')
with app.app_context():
    db.create_all()
    print("Tabelas criadas com sucesso!")
PYEOF

sudo -u inventory /home/inventory/it-inventory/venv/bin/python3 create_company_settings_table.py

print_success "Banco de dados inicializado"

# Configurar Gunicorn
print_header "PASSO 9: CONFIGURAR GUNICORN"

cat > /home/inventory/it-inventory/gunicorn_config.py << 'EOF'
import multiprocessing

bind = "127.0.0.1:8000"
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = "sync"
worker_connections = 1000
timeout = 120
keepalive = 5

accesslog = "/home/inventory/it-inventory/logs/gunicorn-access.log"
errorlog = "/home/inventory/it-inventory/logs/gunicorn-error.log"
loglevel = "info"

proc_name = "inventory_app"
daemon = False
pidfile = "/home/inventory/it-inventory/gunicorn.pid"
EOF

chown inventory:inventory /home/inventory/it-inventory/gunicorn_config.py
print_success "Gunicorn configurado"

# Configurar Supervisor
print_header "PASSO 10: CONFIGURAR SUPERVISOR"

cat > /etc/supervisor/conf.d/inventory.conf << EOF
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
EOF

supervisorctl reread
supervisorctl update
supervisorctl start inventory

print_success "Supervisor configurado e aplicação iniciada"

# Configurar Nginx
print_header "PASSO 11: CONFIGURAR NGINX"

cat > /etc/nginx/sites-available/inventory << EOF
server {
    listen 80;
    server_name $DOMAIN;

    access_log /var/log/nginx/inventory-access.log;
    error_log /var/log/nginx/inventory-error.log;

    client_max_body_size 20M;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_redirect off;
        
        proxy_connect_timeout 120s;
        proxy_send_timeout 120s;
        proxy_read_timeout 120s;
    }

    location /static {
        alias /home/inventory/it-inventory/app/static;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    location /static/uploads {
        alias /home/inventory/it-inventory/app/static/uploads;
        expires 7d;
    }
}
EOF

ln -sf /etc/nginx/sites-available/inventory /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

nginx -t
systemctl restart nginx

print_success "Nginx configurado"

# Configurar SSL
print_header "PASSO 12: CONFIGURAR SSL (HTTPS)"

print_info "Obtendo certificado SSL gratuito..."
certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email $ADMIN_EMAIL --redirect

print_success "SSL configurado"

# Configurar Firewall
print_header "PASSO 13: CONFIGURAR FIREWALL"

ufw allow OpenSSH
ufw allow 'Nginx Full'
echo "y" | ufw enable

print_success "Firewall configurado"

# Configurar Backup
print_header "PASSO 14: CONFIGURAR BACKUP AUTOMÁTICO"

cat > /home/inventory/backup.sh << 'EOF'
#!/bin/bash

BACKUP_DIR="/home/inventory/backups"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="inventory_db"
DB_USER="inventory_user"
APP_DIR="/home/inventory/it-inventory"

mkdir -p $BACKUP_DIR

PGPASSWORD='DB_PASSWORD_PLACEHOLDER' pg_dump -U $DB_USER -h localhost $DB_NAME > $BACKUP_DIR/db_$DATE.sql

tar -czf $BACKUP_DIR/uploads_$DATE.tar.gz $APP_DIR/app/static/uploads

find $BACKUP_DIR -name "db_*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "uploads_*.tar.gz" -mtime +7 -delete

echo "Backup concluído: $DATE"
EOF

sed -i "s/DB_PASSWORD_PLACEHOLDER/$DB_PASSWORD/g" /home/inventory/backup.sh
chmod +x /home/inventory/backup.sh
chown inventory:inventory /home/inventory/backup.sh

# Agendar backup
(crontab -l 2>/dev/null; echo "0 2 * * * /home/inventory/backup.sh >> /home/inventory/backup.log 2>&1") | crontab -

print_success "Backup automático configurado (diariamente às 2h)"

# Ajustar permissões
print_header "PASSO 15: AJUSTAR PERMISSÕES"

chown -R inventory:inventory /home/inventory/it-inventory
chmod -R 755 /home/inventory/it-inventory
chmod 600 /home/inventory/it-inventory/.env

print_success "Permissões ajustadas"

# Finalização
print_header "INSTALAÇÃO CONCLUÍDA!"

echo -e "${GREEN}"
cat << EOF

╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   ✓ Instalação concluída com sucesso!                    ║
║                                                           ║
║   Seu sistema está rodando em:                           ║
║   https://$DOMAIN
║                                                           ║
║   Próximos passos:                                       ║
║   1. Criar usuário administrador:                        ║
║      sudo -u inventory /home/inventory/it-inventory/venv/bin/python3 /home/inventory/it-inventory/run.py create-admin
║                                                           ║
║   2. Configurar email no arquivo .env:                   ║
║      sudo nano /home/inventory/it-inventory/.env         ║
║                                                           ║
║   3. Acessar o sistema e configurar empresa:             ║
║      https://$DOMAIN/settings/
║                                                           ║
║   Comandos úteis:                                        ║
║   • Ver status: sudo supervisorctl status inventory      ║
║   • Reiniciar: sudo supervisorctl restart inventory      ║
║   • Ver logs: tail -f /home/inventory/it-inventory/logs/gunicorn-error.log
║                                                           ║
║   Backup automático: Diariamente às 2h da manhã          ║
║   Localização: /home/inventory/backups/                  ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝

EOF
echo -e "${NC}"

print_info "Informações salvas em: /home/inventory/install_info.txt"

cat > /home/inventory/install_info.txt << EOF
Sistema de Inventário de TI - Informações de Instalação
========================================================

Data de Instalação: $(date)
Domínio: $DOMAIN
Email Admin: $ADMIN_EMAIL
Empresa: $COMPANY_NAME

Banco de Dados:
- Nome: inventory_db
- Usuário: inventory_user
- Host: localhost
- Porta: 5432

Diretórios:
- Aplicação: /home/inventory/it-inventory
- Logs: /home/inventory/it-inventory/logs
- Backups: /home/inventory/backups

Serviços:
- Aplicação: supervisorctl status inventory
- Nginx: systemctl status nginx
- PostgreSQL: systemctl status postgresql

Comandos Úteis:
- Reiniciar app: sudo supervisorctl restart inventory
- Ver logs: tail -f /home/inventory/it-inventory/logs/gunicorn-error.log
- Backup manual: /home/inventory/backup.sh

Próximos Passos:
1. Criar admin: sudo -u inventory /home/inventory/it-inventory/venv/bin/python3 /home/inventory/it-inventory/run.py create-admin
2. Configurar email: sudo nano /home/inventory/it-inventory/.env
3. Acessar: https://$DOMAIN
EOF

chown inventory:inventory /home/inventory/install_info.txt

print_success "Instalação finalizada!"
print_info "Acesse: https://$DOMAIN"

exit 0
