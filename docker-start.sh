#!/bin/bash

################################################################################
# Script de Inicialização Rápida - Docker
# Sistema de Inventário de TI
################################################################################

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# Banner
clear
echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   Sistema de Inventário de TI - Docker Setup             ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}\n"

# Verificar Docker
print_header "VERIFICANDO PRÉ-REQUISITOS"

if ! command -v docker &> /dev/null; then
    print_error "Docker não está instalado!"
    echo "Instale com: curl -fsSL https://get.docker.com | sh"
    exit 1
fi
print_success "Docker instalado"

if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose não está instalado!"
    echo "Instale com: sudo apt install -y docker-compose"
    exit 1
fi
print_success "Docker Compose instalado"

# Verificar arquivo .env
print_header "CONFIGURANDO AMBIENTE"

if [ ! -f .env ]; then
    print_warning "Arquivo .env não encontrado. Criando..."
    cp .env.docker .env
    print_success "Arquivo .env criado"
    print_warning "IMPORTANTE: Edite o arquivo .env antes de continuar!"
    echo ""
    read -p "Deseja editar agora? (s/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        ${EDITOR:-nano} .env
    fi
else
    print_success "Arquivo .env encontrado"
fi

# Construir imagens
print_header "CONSTRUINDO IMAGENS DOCKER"

docker-compose build
print_success "Imagens construídas"

# Iniciar containers
print_header "INICIANDO CONTAINERS"

docker-compose up -d
print_success "Containers iniciados"

# Aguardar containers ficarem saudáveis
print_header "AGUARDANDO CONTAINERS FICAREM PRONTOS"

echo "Aguardando banco de dados..."
sleep 10

# Verificar status
print_header "VERIFICANDO STATUS"

docker-compose ps

# Inicializar banco
print_header "INICIALIZANDO BANCO DE DADOS"

docker-compose exec -T app python -c "from app import create_app, db; app = create_app('production'); app.app_context().push(); db.create_all(); print('Tabelas criadas')" || print_warning "Tabelas já existem"

docker-compose exec -T app python create_company_settings_table.py || print_warning "Configurações já existem"

print_success "Banco de dados inicializado"

# Finalização
print_header "INSTALAÇÃO CONCLUÍDA!"

echo -e "${GREEN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   ✓ Sistema instalado com sucesso!                       ║
║                                                           ║
║   Próximos passos:                                       ║
║   1. Criar usuário administrador:                        ║
║      docker-compose exec app python run.py create-admin  ║
║                                                           ║
║   2. Acessar o sistema:                                  ║
║      http://localhost                                    ║
║                                                           ║
║   Comandos úteis:                                        ║
║   • Ver logs: docker-compose logs -f                     ║
║   • Parar: docker-compose stop                           ║
║   • Reiniciar: docker-compose restart                    ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}\n"

# Perguntar se quer criar admin agora
read -p "Deseja criar o usuário administrador agora? (s/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    docker-compose exec app python run.py create-admin
fi

print_success "Tudo pronto! Acesse: http://localhost"
