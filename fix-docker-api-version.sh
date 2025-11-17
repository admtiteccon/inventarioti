#!/bin/bash

################################################################################
# Script para Corrigir Erro de API Version do Docker
# Corrige: "client version 1.24 is too old"
################################################################################

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Funções
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_info() { echo -e "${CYAN}ℹ $1${NC}"; }
print_step() { echo -e "${BLUE}▶ $1${NC}"; }

# Banner
clear
echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   🔧 CORREÇÃO DE ERRO DE API VERSION DO DOCKER               ║
║                                                               ║
║   Corrige: "client version 1.24 is too old"                  ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}\n"

# Verificar root
if [[ $EUID -ne 0 ]]; then
   print_error "Este script deve ser executado como root"
   exit 1
fi

print_info "Este script vai:"
echo "  • Fazer backup dos arquivos docker-compose.yml"
echo "  • Remover a linha 'version: 3.8' de todos os arquivos"
echo "  • Reiniciar todos os serviços"
echo ""

read -p "Deseja continuar? (s/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[SsYy]$ ]]; then
    print_warning "Operação cancelada pelo usuário"
    exit 0
fi

echo ""

# Função para corrigir docker-compose.yml
fix_compose() {
    local dir=$1
    local service=$2
    
    if [ ! -d "$dir" ]; then
        print_warning "$service não encontrado em $dir"
        return 1
    fi
    
    if [ ! -f "$dir/docker-compose.yml" ]; then
        print_warning "docker-compose.yml não encontrado em $dir"
        return 1
    fi
    
    print_step "Corrigindo $service..."
    
    cd "$dir"
    
    # Fazer backup
    if [ ! -f "docker-compose.yml.backup-api-fix" ]; then
        cp docker-compose.yml docker-compose.yml.backup-api-fix
        print_success "Backup criado: docker-compose.yml.backup-api-fix"
    else
        print_info "Backup já existe, pulando..."
    fi
    
    # Verificar se tem a linha version
    if grep -q "^version:" docker-compose.yml; then
        # Parar serviço
        print_info "Parando $service..."
        docker-compose down > /dev/null 2>&1 || true
        
        # Remover linha version
        sed -i.bak '/^version:/d' docker-compose.yml
        rm -f docker-compose.yml.bak
        
        print_success "Linha 'version' removida"
        
        # Reiniciar serviço
        print_info "Reiniciando $service..."
        docker-compose up -d > /dev/null 2>&1
        
        # Aguardar inicialização
        sleep 3
        
        # Verificar se está rodando
        if docker-compose ps | grep -q "Up"; then
            print_success "$service corrigido e rodando!"
        else
            print_error "$service não está rodando. Verifique os logs."
            return 1
        fi
    else
        print_info "$service já está correto (sem linha version)"
    fi
    
    echo ""
    return 0
}

# ============================================================================
print_step "INICIANDO CORREÇÃO..."
echo ""
# ============================================================================

# Contador de serviços corrigidos
FIXED=0
TOTAL=0

# Corrigir Traefik
TOTAL=$((TOTAL + 1))
if fix_compose "/opt/traefik" "Traefik"; then
    FIXED=$((FIXED + 1))
fi

# Corrigir Portainer
TOTAL=$((TOTAL + 1))
if fix_compose "/opt/portainer" "Portainer"; then
    FIXED=$((FIXED + 1))
fi

# Corrigir Sistema de Inventário
TOTAL=$((TOTAL + 1))
if fix_compose "/opt/inventory" "Sistema de Inventário"; then
    FIXED=$((FIXED + 1))
fi

# ============================================================================
print_step "VERIFICANDO STATUS DOS SERVIÇOS..."
echo ""
# ============================================================================

print_info "Aguardando 10 segundos para estabilização..."
sleep 10

echo ""
print_info "📊 Status dos Containers:"
echo ""
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "traefik|portainer|inventory" || true
echo ""

# ============================================================================
print_step "VERIFICANDO LOGS DO TRAEFIK..."
echo ""
# ============================================================================

print_info "Últimas 15 linhas do log do Traefik:"
echo ""
docker logs traefik --tail 15 2>&1 | tail -15
echo ""

# Verificar se ainda tem erro de API
if docker logs traefik 2>&1 | grep -q "client version.*is too old"; then
    print_error "ATENÇÃO: Ainda há erros de API version nos logs!"
    print_info "Execute: docker logs traefik"
else
    print_success "Nenhum erro de API version encontrado nos logs!"
fi

echo ""

# ============================================================================
print_step "RESUMO DA CORREÇÃO"
echo ""
# ============================================================================

echo -e "${GREEN}"
cat << EOF
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   ✓ CORREÇÃO CONCLUÍDA!                                      ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}\n"

print_success "Serviços corrigidos: $FIXED de $TOTAL"
echo ""

print_info "📁 Backups criados:"
echo "  • /opt/traefik/docker-compose.yml.backup-api-fix"
echo "  • /opt/portainer/docker-compose.yml.backup-api-fix"
echo "  • /opt/inventory/docker-compose.yml.backup-api-fix"
echo ""

print_info "🔍 Comandos úteis:"
echo "  • Ver todos os containers: docker ps"
echo "  • Ver logs do Traefik: docker logs traefik"
echo "  • Ver logs do Portainer: docker logs portainer"
echo "  • Ver logs do Inventory: docker logs inventory-app"
echo ""

print_info "🔄 Se precisar reverter:"
echo "  cd /opt/traefik && cp docker-compose.yml.backup-api-fix docker-compose.yml"
echo "  cd /opt/portainer && cp docker-compose.yml.backup-api-fix docker-compose.yml"
echo "  cd /opt/inventory && cp docker-compose.yml.backup-api-fix docker-compose.yml"
echo ""

# Verificar se todos os serviços principais estão rodando
RUNNING=$(docker ps | grep -E "traefik|portainer|inventory-app" | wc -l)

if [ "$RUNNING" -ge 3 ]; then
    print_success "Todos os serviços principais estão rodando! 🚀"
else
    print_warning "Alguns serviços podem não estar rodando. Verifique com: docker ps"
fi

echo ""

# Testar acesso ao Traefik
print_info "🌐 Testando conectividade do Traefik..."
if docker exec traefik wget -q --spider http://localhost:80 2>/dev/null; then
    print_success "Traefik está respondendo!"
else
    print_warning "Traefik pode não estar respondendo corretamente"
fi

echo ""
print_success "Correção finalizada! ✨"
echo ""

exit 0
