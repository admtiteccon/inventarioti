#!/bin/bash

################################################################################
# Script de Instalação Completa - VPS + Docker + Portainer + Nginx Proxy Manager
# Para VPS Linux limpa com suporte a múltiplas aplicações
################################################################################

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Funções de output
print_header() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║ $(printf "%-58s" "$1")║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}\n"
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
    echo -e "${CYAN}ℹ $1${NC}"
}

print_step() {
    echo -e "${PURPLE}▶ $1${NC}"
}

# Verificar se está rodando como root
if [[ $EUID -ne 0 ]]; then
   print_error "Este script deve ser executado como root (use sudo)"
   exit 1
fi

# Banner
clear
echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║     🚀 INSTALAÇÃO COMPLETA DE SERVIDOR DOCKER                ║
║                                                               ║
║     • Docker + Docker Compose                                ║
║     • Portainer (Interface Gráfica)                          ║
║     • Nginx Proxy Manager (Gerenciador de Domínios)         ║
║     • Sistema de Inventário de TI                            ║
║     • SSL Automático (Let's Encrypt)                         ║
║     • Pronto para múltiplas aplicações                       ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}\n"

# Obter informações
print_info "Este script irá configurar um servidor completo do zero."
print_info "Tempo estimado: 10-15 minutos\n"

read -p "Continuar com a instalação? (s/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    print_info "Instalação cancelada."
    exit 0
fi

# Obter IP do servidor
print_step "Detectando IP do servidor..."
SERVER_IP=$(curl -s ifconfig.me || curl -s ipinfo.io/ip || hostname -I | awk '{print $1}')
print_success "IP detectado: $SERVER_IP"

# ============================================================================
# PASSO 1: ATUALIZAR SISTEMA
# ============================================================================
print_header "PASSO 1/7: ATUALIZAR SISTEMA"

print_step "Atualizando lista de pacotes..."
apt update -qq

print_step "Atualizando sistema..."
DEBIAN_FRONTEND=noninteractive apt upgrade -y -qq

print_step "Instalando ferramentas essenciais..."
apt install -y -qq curl wget git nano htop ufw net-tools

print_success "Sistema atualizado com sucesso!"

# ============================================================================
# PASSO 2: CONFIGURAR FIREWALL
# ============================================================================
print_header "PASSO 2/7: CONFIGURAR FIREWALL"

print_step "Configurando regras do firewall..."

# Resetar UFW
ufw --force reset > /dev/null 2>&1

# Configurar regras
ufw default deny incoming > /dev/null 2>&1
ufw default allow outgoing > /dev/null 2>&1

# Permitir portas necessárias
ufw allow 22/tcp comment 'SSH' > /dev/null 2>&1
ufw allow 80/tcp comment 'HTTP' > /dev/null 2>&1
ufw allow 443/tcp comment 'HTTPS' > /dev/null 2>&1
ufw allow 81/tcp comment 'Nginx Proxy Manager' > /dev/null 2>&1
ufw allow 9443/tcp comment 'Portainer' > /dev/null 2>&1

# Ativar firewall
echo "y" | ufw enable > /dev/null 2>&1

print_success "Firewall configurado!"
print_info "Portas abertas: 22 (SSH), 80 (HTTP), 443 (HTTPS), 81 (NPM), 9443 (Portainer)"

# ============================================================================
# PASSO 3: INSTALAR DOCKER
# ============================================================================
print_header "PASSO 3/7: INSTALAR DOCKER"

print_step "Baixando e instalando Docker..."
curl -fsSL https://get.docker.com | sh > /dev/null 2>&1

print_step "Configurando Docker..."
systemctl start docker
systemctl enable docker > /dev/null 2>&1

print_step "Instalando Docker Compose..."
apt install -y -qq docker-compose

DOCKER_VERSION=$(docker --version | cut -d ' ' -f3 | tr -d ',')
COMPOSE_VERSION=$(docker-compose --version | cut -d ' ' -f3 | tr -d ',')

print_success "Docker instalado! Versão: $DOCKER_VERSION"
print_success "Docker Compose instalado! Versão: $COMPOSE_VERSION"

# ============================================================================
# PASSO 4: INSTALAR PORTAINER
# ============================================================================
print_header "PASSO 4/7: INSTALAR PORTAINER"

print_step "Criando volume para Portainer..."
docker volume create portainer_data > /dev/null 2>&1

print_step "Instalando Portainer CE..."
docker run -d \
  -p 8000:8000 \
  -p 9443:9443 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest > /dev/null 2>&1

# Aguardar Portainer iniciar
print_step "Aguardando Portainer inicializar..."
sleep 10

if docker ps | grep -q portainer; then
    print_success "Portainer instalado e rodando!"
    print_info "Acesse: https://$SERVER_IP:9443"
else
    print_error "Erro ao iniciar Portainer"
fi

# ============================================================================
# PASSO 5: INSTALAR NGINX PROXY MANAGER
# ============================================================================
print_header "PASSO 5/7: INSTALAR NGINX PROXY MANAGER"

print_step "Criando diretório para Nginx Proxy Manager..."
mkdir -p /opt/nginx-proxy-manager
cd /opt/nginx-proxy-manager

print_step "Criando docker-compose.yml..."
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  nginx-proxy-manager:
    image: 'jc21/nginx-proxy-manager:latest'
    container_name: nginx-proxy-manager
    restart: always
    ports:
      - '80:80'
      - '443:443'
      - '81:81'
    environment:
      DB_SQLITE_FILE: "/data/database.sqlite"
    volumes:
      - npm_data:/data
      - npm_letsencrypt:/etc/letsencrypt
    networks:
      - proxy-network

volumes:
  npm_data:
  npm_letsencrypt:

networks:
  proxy-network:
    driver: bridge
EOF

print_step "Iniciando Nginx Proxy Manager..."
docker-compose up -d > /dev/null 2>&1

# Aguardar NPM iniciar
print_step "Aguardando Nginx Proxy Manager inicializar..."
sleep 15

if docker ps | grep -q nginx-proxy-manager; then
    print_success "Nginx Proxy Manager instalado e rodando!"
    print_info "Acesse: http://$SERVER_IP:81"
    print_info "Login padrão: admin@example.com / changeme"
else
    print_error "Erro ao iniciar Nginx Proxy Manager"
fi

# ============================================================================
# PASSO 6: PREPARAR SISTEMA DE INVENTÁRIO
# ============================================================================
print_header "PASSO 6/7: PREPARAR SISTEMA DE INVENTÁRIO"

print_step "Criando diretório do projeto..."
mkdir -p /opt/inventory
cd /opt/inventory

print_step "Criando docker-compose.yml do Sistema de Inventário..."
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  # Banco de Dados PostgreSQL
  db:
    image: postgres:15-alpine
    container_name: inventory-db
    restart: always
    environment:
      POSTGRES_DB: inventory_db
      POSTGRES_USER: inventory_user
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - inventory-network
      - nginx-proxy-manager_proxy-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U inventory_user -d inventory_db"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Aplicação Flask
  app:
    image: python:3.11-slim
    container_name: inventory-app
    restart: always
    working_dir: /app
    command: >
      bash -c "
      echo '🔧 Instalando dependências do sistema...' &&
      apt-get update && apt-get install -y gcc postgresql-client libpq-dev &&
      echo '📦 Instalando dependências Python...' &&
      pip install --no-cache-dir -r requirements.txt &&
      pip install --no-cache-dir gunicorn &&
      echo '🗄️ Inicializando banco de dados...' &&
      python -c 'from app import create_app, db; app = create_app(\"production\"); app.app_context().push(); db.create_all(); print(\"✓ Banco de dados inicializado!\")' &&
      echo '🚀 Iniciando aplicação...' &&
      gunicorn --bind 0.0.0.0:8000 --workers 4 --timeout 120 --access-logfile - --error-logfile - run:app
      "
    environment:
      FLASK_ENV: production
      SECRET_KEY: ${SECRET_KEY}
      DATABASE_URL: postgresql://inventory_user:${DB_PASSWORD}@db:5432/inventory_db
      MAIL_SERVER: ${MAIL_SERVER:-smtp.gmail.com}
      MAIL_PORT: ${MAIL_PORT:-587}
      MAIL_USE_TLS: ${MAIL_USE_TLS:-true}
      MAIL_USERNAME: ${MAIL_USERNAME}
      MAIL_PASSWORD: ${MAIL_PASSWORD}
      APP_NAME: "Sistema de Inventário de TI"
      FOOTER_COMPANY_NAME: ${FOOTER_COMPANY_NAME:-Sua Empresa}
      FOOTER_YEAR: "2025"
      FOOTER_VERSION: "1.0.0"
    volumes:
      - /opt/inventory:/app
      - uploads_data:/app/app/static/uploads
    expose:
      - "8000"
    networks:
      - inventory-network
      - nginx-proxy-manager_proxy-network
    depends_on:
      db:
        condition: service_healthy

volumes:
  postgres_data:
  uploads_data:

networks:
  inventory-network:
    driver: bridge
  nginx-proxy-manager_proxy-network:
    external: true
EOF

print_step "Criando arquivo .env de exemplo..."
cat > .env.example << 'EOF'
# Banco de Dados
DB_PASSWORD=MudeMeParaUmaSenhaForte123!

# Segurança (gere uma chave aleatória de 32+ caracteres)
SECRET_KEY=mude-esta-chave-para-algo-aleatorio-e-seguro

# Configurações de Email (Gmail exemplo)
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USE_TLS=true
MAIL_USERNAME=seu-email@gmail.com
MAIL_PASSWORD=sua-senha-de-app-do-gmail

# Personalização
FOOTER_COMPANY_NAME=Sua Empresa LTDA
EOF

# Gerar SECRET_KEY aleatória
SECRET_KEY=$(openssl rand -hex 32)

print_step "Criando arquivo .env com valores padrão..."
cat > .env << EOF
# Banco de Dados
DB_PASSWORD=InventoryDB$(openssl rand -hex 8)!

# Segurança
SECRET_KEY=$SECRET_KEY

# Configurações de Email (CONFIGURE ANTES DE USAR)
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USE_TLS=true
MAIL_USERNAME=seu-email@gmail.com
MAIL_PASSWORD=sua-senha-de-app

# Personalização
FOOTER_COMPANY_NAME=Minha Empresa
EOF

print_success "Estrutura do Sistema de Inventário criada!"
print_warning "IMPORTANTE: Edite o arquivo /opt/inventory/.env com suas configurações"
print_info "Arquivo de exemplo: /opt/inventory/.env.example"

# ============================================================================
# PASSO 7: INSTRUÇÕES FINAIS
# ============================================================================
print_header "PASSO 7/7: INSTALAÇÃO CONCLUÍDA!"

echo -e "${GREEN}"
cat << EOF

╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   ✓ INSTALAÇÃO CONCLUÍDA COM SUCESSO!                        ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝

EOF
echo -e "${NC}"

print_success "Servidor configurado e pronto para uso!"
echo

print_info "📋 PRÓXIMOS PASSOS:"
echo
echo "1️⃣  CONFIGURAR PORTAINER"
echo "   Acesse: https://$SERVER_IP:9443"
echo "   • Crie usuário admin"
echo "   • Conecte ao ambiente local"
echo

echo "2️⃣  CONFIGURAR NGINX PROXY MANAGER"
echo "   Acesse: http://$SERVER_IP:81"
echo "   • Login: admin@example.com / changeme"
echo "   • Troque email e senha"
echo "   • Configure seus domínios"
echo

echo "3️⃣  ENVIAR ARQUIVOS DO SISTEMA DE INVENTÁRIO"
echo "   Do seu PC Windows (PowerShell):"
echo "   scp -r \"C:\\caminho\\do\\projeto\\*\" root@$SERVER_IP:/opt/inventory/"
echo

echo "4️⃣  CONFIGURAR VARIÁVEIS DE AMBIENTE"
echo "   No servidor:"
echo "   nano /opt/inventory/.env"
echo "   • Configure senha do banco"
echo "   • Configure email (SMTP)"
echo "   • Configure nome da empresa"
echo

echo "5️⃣  FAZER DEPLOY DO SISTEMA"
echo "   Via Portainer:"
echo "   • Stacks → Add stack"
echo "   • Nome: inventory-system"
echo "   • Upload: /opt/inventory/docker-compose.yml"
echo "   • Load variables from .env"
echo "   • Deploy!"
echo

echo "6️⃣  CONFIGURAR DNS E SSL"
echo "   No seu provedor de domínio:"
echo "   • Adicione registro A: inventario.seudominio.com → $SERVER_IP"
echo "   • Adicione registro A: portainer.seudominio.com → $SERVER_IP"
echo
echo "   No Nginx Proxy Manager:"
echo "   • Add Proxy Host"
echo "   • Configure SSL (Let's Encrypt)"
echo

print_info "📚 DOCUMENTAÇÃO COMPLETA:"
echo "   /opt/inventory/GUIA_INSTALACAO_VPS_PORTAINER_COMPLETO.md"
echo

print_info "🔧 ARQUIVOS IMPORTANTES:"
echo "   • Docker Compose NPM: /opt/nginx-proxy-manager/docker-compose.yml"
echo "   • Docker Compose Inventário: /opt/inventory/docker-compose.yml"
echo "   • Variáveis de ambiente: /opt/inventory/.env"
echo "   • Exemplo de .env: /opt/inventory/.env.example"
echo

print_info "📊 VERIFICAR STATUS:"
echo "   docker ps                    # Ver containers rodando"
echo "   docker logs portainer        # Logs do Portainer"
echo "   docker logs nginx-proxy-manager  # Logs do NPM"
echo

print_success "Servidor pronto para receber aplicações! 🚀"
echo

exit 0
