#!/bin/bash

################################################################################
# Script de Instalação Completa - Docker + Portainer + Traefik
# Para VPS Linux limpa com proxy reverso moderno
################################################################################

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Funções
print_header() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║ $(printf "%-58s" "$1")║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}\n"
}

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_info() { echo -e "${CYAN}ℹ $1${NC}"; }
print_step() { echo -e "${PURPLE}▶ $1${NC}"; }

# Verificar root
if [[ $EUID -ne 0 ]]; then
   print_error "Este script deve ser executado como root"
   exit 1
fi

# Banner
clear
echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║     🚀 INSTALAÇÃO DOCKER + PORTAINER + TRAEFIK               ║
║                                                               ║
║     • Docker + Docker Compose                                ║
║     • Portainer (Interface Gráfica)                          ║
║     • Traefik (Proxy Reverso Moderno)                        ║
║     • SSL Automático (Let's Encrypt)                         ║
║     • Sistema de Inventário de TI                            ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}\n"

print_info "Traefik é um proxy reverso moderno e automático"
print_info "Configuração via código (Infrastructure as Code)"
print_info "Tempo estimado: 10-15 minutos\n"

# Coletar informações
read -p "Digite seu domínio (ex: seudominio.com.br): " DOMAIN
read -p "Digite seu email para SSL: " EMAIL
read -p "Digite uma senha para o dashboard do Traefik: " TRAEFIK_PASSWORD

if [[ -z "$DOMAIN" ]] || [[ -z "$EMAIL" ]]; then
    print_error "Domínio e email são obrigatórios!"
    exit 1
fi

# Detectar IP
SERVER_IP=$(curl -s ifconfig.me || curl -s ipinfo.io/ip || hostname -I | awk '{print $1}')
print_success "IP detectado: $SERVER_IP"

# ============================================================================
print_header "PASSO 1/7: ATUALIZAR SISTEMA"
# ============================================================================

print_step "Atualizando sistema..."
apt update -qq
DEBIAN_FRONTEND=noninteractive apt upgrade -y -qq
apt install -y -qq curl wget git nano htop ufw apache2-utils jq

print_success "Sistema atualizado!"

# ============================================================================
print_header "PASSO 2/7: CONFIGURAR FIREWALL"
# ============================================================================

print_step "Configurando firewall..."
ufw --force reset > /dev/null 2>&1
ufw default deny incoming > /dev/null 2>&1
ufw default allow outgoing > /dev/null 2>&1
ufw allow 22/tcp comment 'SSH' > /dev/null 2>&1
ufw allow 80/tcp comment 'HTTP' > /dev/null 2>&1
ufw allow 443/tcp comment 'HTTPS' > /dev/null 2>&1
echo "y" | ufw enable > /dev/null 2>&1

print_success "Firewall configurado!"

# ============================================================================
print_header "PASSO 3/7: INSTALAR DOCKER"
# ============================================================================

print_step "Instalando Docker..."
curl -fsSL https://get.docker.com | sh > /dev/null 2>&1
systemctl start docker
systemctl enable docker > /dev/null 2>&1
apt install -y -qq docker-compose

DOCKER_VERSION=$(docker --version | cut -d ' ' -f3 | tr -d ',')
print_success "Docker instalado! Versão: $DOCKER_VERSION"

# ============================================================================
print_header "PASSO 4/7: INSTALAR TRAEFIK"
# ============================================================================

print_step "Criando estrutura do Traefik..."
mkdir -p /opt/traefik/letsencrypt
cd /opt/traefik

# Criar rede
docker network create traefik-network 2>/dev/null || true

# Gerar hash da senha
TRAEFIK_PASSWORD_HASH=$(htpasswd -nb admin "$TRAEFIK_PASSWORD" | sed -e s/\\$/\\$\\$/g)

# Criar traefik.yml
cat > traefik.yml << EOF
global:
  checkNewVersion: true
  sendAnonymousUsage: false

api:
  dashboard: true
  insecure: false

entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https
          permanent: true

  websecure:
    address: ":443"
    http:
      tls:
        certResolver: letsencrypt

certificatesResolvers:
  letsencrypt:
    acme:
      email: $EMAIL
      storage: /letsencrypt/acme.json
      httpChallenge:
        entryPoint: web

providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
    network: traefik-network

log:
  level: INFO
  format: common

accessLog:
  format: common
EOF

# Criar docker-compose.yml
cat > docker-compose.yml << EOF
version: '3.8'

services:
  traefik:
    image: traefik:v2.10
    container_name: traefik
    restart: always
    security_opt:
      - no-new-privileges:true
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./traefik.yml:/traefik.yml:ro
      - ./letsencrypt:/letsencrypt
    networks:
      - traefik-network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.traefik-dashboard.rule=Host(\`traefik.$DOMAIN\`)"
      - "traefik.http.routers.traefik-dashboard.entrypoints=websecure"
      - "traefik.http.routers.traefik-dashboard.tls.certresolver=letsencrypt"
      - "traefik.http.routers.traefik-dashboard.service=api@internal"
      - "traefik.http.routers.traefik-dashboard.middlewares=traefik-auth"
      - "traefik.http.middlewares.traefik-auth.basicauth.users=$TRAEFIK_PASSWORD_HASH"

networks:
  traefik-network:
    external: true
EOF

# Criar acme.json
touch letsencrypt/acme.json
chmod 600 letsencrypt/acme.json

# Iniciar Traefik
print_step "Iniciando Traefik..."
docker-compose up -d > /dev/null 2>&1
sleep 5

if docker ps | grep -q traefik; then
    print_success "Traefik instalado e rodando!"
else
    print_error "Erro ao iniciar Traefik"
fi

# ============================================================================
print_header "PASSO 5/7: INSTALAR PORTAINER"
# ============================================================================

print_step "Instalando Portainer..."
mkdir -p /opt/portainer
cd /opt/portainer

docker volume create portainer_data > /dev/null 2>&1

cat > docker-compose.yml << EOF
version: '3.8'

services:
  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    restart: always
    security_opt:
      - no-new-privileges:true
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data
    networks:
      - traefik-network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.portainer.rule=Host(\`portainer.$DOMAIN\`)"
      - "traefik.http.routers.portainer.entrypoints=websecure"
      - "traefik.http.routers.portainer.tls.certresolver=letsencrypt"
      - "traefik.http.services.portainer.loadbalancer.server.port=9000"

volumes:
  portainer_data:
    external: true

networks:
  traefik-network:
    external: true
EOF

docker-compose up -d > /dev/null 2>&1
sleep 5

if docker ps | grep -q portainer; then
    print_success "Portainer instalado e rodando!"
else
    print_error "Erro ao iniciar Portainer"
fi

# ============================================================================
print_header "PASSO 6/7: PREPARAR SISTEMA DE INVENTÁRIO"
# ============================================================================

print_step "Criando estrutura do Sistema de Inventário..."
mkdir -p /opt/inventory
cd /opt/inventory

# Gerar senhas
DB_PASS=$(openssl rand -base64 16)
SECRET=$(openssl rand -hex 32)

# Criar docker-compose.yml
cat > docker-compose.yml << EOF
version: '3.8'

services:
  db:
    image: postgres:15-alpine
    container_name: inventory-db
    restart: always
    environment:
      POSTGRES_DB: inventory_db
      POSTGRES_USER: inventory_user
      POSTGRES_PASSWORD: \${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - inventory-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U inventory_user -d inventory_db"]
      interval: 10s
      timeout: 5s
      retries: 5

  app:
    image: python:3.11-slim
    container_name: inventory-app
    restart: always
    working_dir: /app
    command: >
      bash -c "
      echo '🔧 Instalando dependências...' &&
      apt-get update && apt-get install -y gcc postgresql-client libpq-dev &&
      pip install --no-cache-dir -r requirements.txt &&
      pip install --no-cache-dir gunicorn &&
      echo '🗄️ Inicializando banco...' &&
      python -c 'from app import create_app, db; app = create_app(\"production\"); app.app_context().push(); db.create_all(); print(\"✓ Banco OK!\")' &&
      echo '🚀 Iniciando aplicação...' &&
      gunicorn --bind 0.0.0.0:8000 --workers 4 --timeout 120 --access-logfile - --error-logfile - run:app
      "
    environment:
      FLASK_ENV: production
      SECRET_KEY: \${SECRET_KEY}
      DATABASE_URL: postgresql://inventory_user:\${DB_PASSWORD}@db:5432/inventory_db
      MAIL_SERVER: \${MAIL_SERVER}
      MAIL_PORT: \${MAIL_PORT}
      MAIL_USE_TLS: \${MAIL_USE_TLS}
      MAIL_USERNAME: \${MAIL_USERNAME}
      MAIL_PASSWORD: \${MAIL_PASSWORD}
      APP_NAME: "Sistema de Inventário de TI"
      FOOTER_COMPANY_NAME: \${FOOTER_COMPANY_NAME}
      FOOTER_YEAR: "2025"
      FOOTER_VERSION: "1.0.0"
    volumes:
      - /opt/inventory:/app
      - uploads_data:/app/app/static/uploads
    networks:
      - inventory-network
      - traefik-network
    depends_on:
      db:
        condition: service_healthy
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.inventory.rule=Host(\`inventario.$DOMAIN\`)"
      - "traefik.http.routers.inventory.entrypoints=websecure"
      - "traefik.http.routers.inventory.tls.certresolver=letsencrypt"
      - "traefik.http.services.inventory.loadbalancer.server.port=8000"

volumes:
  postgres_data:
  uploads_data:

networks:
  inventory-network:
    driver: bridge
  traefik-network:
    external: true
EOF

# Criar .env
cat > .env << EOF
# Banco de Dados
DB_PASSWORD=$DB_PASS

# Segurança
SECRET_KEY=$SECRET

# Email (CONFIGURE ANTES DE USAR)
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USE_TLS=true
MAIL_USERNAME=seu-email@gmail.com
MAIL_PASSWORD=sua-senha-de-app

# Personalização
FOOTER_COMPANY_NAME=Minha Empresa
EOF

print_success "Estrutura do Sistema de Inventário criada!"
print_warning "IMPORTANTE: Envie os arquivos do projeto para /opt/inventory/"
print_warning "IMPORTANTE: Configure o arquivo /opt/inventory/.env"

# ============================================================================
print_header "PASSO 7/7: INSTALAÇÃO CONCLUÍDA!"
# ============================================================================

echo -e "${GREEN}"
cat << EOF

╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   ✓ INSTALAÇÃO CONCLUÍDA COM SUCESSO!                        ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝

EOF
echo -e "${NC}"

print_success "Servidor configurado com Traefik!"
echo

print_info "📋 CONFIGURAR DNS (no seu provedor de domínio):"
echo
echo "   Adicione estes registros A:"
echo "   • inventario.$DOMAIN → $SERVER_IP"
echo "   • portainer.$DOMAIN → $SERVER_IP"
echo "   • traefik.$DOMAIN → $SERVER_IP"
echo

print_info "🌐 ACESSOS (após configurar DNS):"
echo
echo "   • Traefik Dashboard: https://traefik.$DOMAIN"
echo "     Login: admin / $TRAEFIK_PASSWORD"
echo
echo "   • Portainer: https://portainer.$DOMAIN"
echo "     (criar usuário na primeira vez)"
echo
echo "   • Sistema de Inventário: https://inventario.$DOMAIN"
echo "     (após enviar arquivos e fazer deploy)"
echo

print_info "📁 PRÓXIMOS PASSOS:"
echo
echo "1️⃣  Configurar DNS (aguardar propagação 5-30 min)"
echo
echo "2️⃣  Enviar arquivos do projeto:"
echo "   scp -r \"C:\\caminho\\projeto\\*\" root@$SERVER_IP:/opt/inventory/"
echo
echo "3️⃣  Configurar .env:"
echo "   nano /opt/inventory/.env"
echo
echo "4️⃣  Fazer deploy:"
echo "   cd /opt/inventory"
echo "   docker-compose up -d"
echo
echo "5️⃣  Criar usuário admin:"
echo "   docker exec -it inventory-app python run.py create-admin"
echo

print_info "📊 VERIFICAR STATUS:"
echo "   docker ps                    # Ver containers"
echo "   docker logs traefik          # Logs do Traefik"
echo "   docker logs portainer        # Logs do Portainer"
echo

print_info "🔐 SENHAS GERADAS:"
echo "   Dashboard Traefik: $TRAEFIK_PASSWORD"
echo "   DB Password: $DB_PASS"
echo "   (salvas em /opt/inventory/.env)"
echo

print_success "Instalação base completa! 🚀"
echo

exit 0
