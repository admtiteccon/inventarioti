# ⚡ Comandos Rápidos - Traefik

## 🚀 INSTALAÇÃO RÁPIDA

### Opção 1: Script Automático
```bash
curl -fsSL https://raw.githubusercontent.com/seu-repo/install-traefik-completo.sh -o install.sh
chmod +x install.sh
./install.sh
```

### Opção 2: Manual (Sequência Completa)

```bash
# 1. Atualizar sistema
apt update && apt upgrade -y
apt install -y curl wget git nano htop ufw apache2-utils jq

# 2. Configurar firewall
ufw allow 22,80,443/tcp
ufw --force enable

# 3. Instalar Docker
curl -fsSL https://get.docker.com | sh
apt install -y docker-compose

# 4. Criar rede Traefik
docker network create traefik-network

# 5. Criar estrutura
mkdir -p /opt/traefik/letsencrypt
cd /opt/traefik
```

---

## 📝 CONFIGURAÇÃO DO TRAEFIK

### Criar traefik.yml

```bash
cat > /opt/traefik/traefik.yml << 'EOF'
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
      email: seu-email@gmail.com
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

# Editar email
nano /opt/traefik/traefik.yml
```

### Gerar Senha para Dashboard

```bash
# Instalar htpasswd
apt install -y apache2-utils

# Gerar senha (substitua 'suasenha')
echo $(htpasswd -nb admin suasenha) | sed -e s/\\$/\\$\\$/g

# Copie o resultado para usar no docker-compose.yml
```

### Criar docker-compose.yml do Traefik

```bash
cat > /opt/traefik/docker-compose.yml << 'EOF'
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
      - "traefik.http.routers.traefik-dashboard.rule=Host(`traefik.seudominio.com`)"
      - "traefik.http.routers.traefik-dashboard.entrypoints=websecure"
      - "traefik.http.routers.traefik-dashboard.tls.certresolver=letsencrypt"
      - "traefik.http.routers.traefik-dashboard.service=api@internal"
      - "traefik.http.routers.traefik-dashboard.middlewares=traefik-auth"
      - "traefik.http.middlewares.traefik-auth.basicauth.users=COLE_SENHA_AQUI"

networks:
  traefik-network:
    external: true
EOF

# Editar domínio e senha
nano /opt/traefik/docker-compose.yml
```

### Criar acme.json e Iniciar

```bash
touch /opt/traefik/letsencrypt/acme.json
chmod 600 /opt/traefik/letsencrypt/acme.json

cd /opt/traefik
docker-compose up -d
```

---

## 🖥️ PORTAINER COM TRAEFIK

```bash
mkdir -p /opt/portainer
cd /opt/portainer

docker volume create portainer_data

cat > docker-compose.yml << 'EOF'
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
      - "traefik.http.routers.portainer.rule=Host(`portainer.seudominio.com`)"
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

# Editar domínio
nano docker-compose.yml

# Iniciar
docker-compose up -d
```

---

## 📦 SISTEMA DE INVENTÁRIO COM TRAEFIK

```bash
mkdir -p /opt/inventory
cd /opt/inventory

# Enviar arquivos do projeto aqui

# Criar docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
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
      apt-get update && apt-get install -y gcc postgresql-client libpq-dev &&
      pip install --no-cache-dir -r requirements.txt gunicorn &&
      python -c 'from app import create_app, db; app = create_app(\"production\"); app.app_context().push(); db.create_all()' &&
      gunicorn --bind 0.0.0.0:8000 --workers 4 --timeout 120 run:app
      "
    environment:
      FLASK_ENV: production
      SECRET_KEY: ${SECRET_KEY}
      DATABASE_URL: postgresql://inventory_user:${DB_PASSWORD}@db:5432/inventory_db
      MAIL_SERVER: ${MAIL_SERVER}
      MAIL_PORT: ${MAIL_PORT}
      MAIL_USE_TLS: ${MAIL_USE_TLS}
      MAIL_USERNAME: ${MAIL_USERNAME}
      MAIL_PASSWORD: ${MAIL_PASSWORD}
      APP_NAME: "Sistema de Inventário de TI"
      FOOTER_COMPANY_NAME: ${FOOTER_COMPANY_NAME}
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
      - "traefik.http.routers.inventory.rule=Host(`inventario.seudominio.com`)"
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
DB_PASSWORD=$(openssl rand -base64 16)
SECRET_KEY=$(openssl rand -hex 32)
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USE_TLS=true
MAIL_USERNAME=seu-email@gmail.com
MAIL_PASSWORD=sua-senha-app
FOOTER_COMPANY_NAME=Sua Empresa
EOF

# Editar .env
nano .env

# Iniciar
docker-compose up -d
```

---

## 🔍 COMANDOS DE VERIFICAÇÃO

### Ver Status
```bash
# Todos os containers
docker ps

# Apenas Traefik
docker ps | grep traefik

# Status detalhado
docker stats
```

### Ver Logs
```bash
# Logs do Traefik
docker logs traefik

# Seguir logs em tempo real
docker logs traefik -f

# Últimas 100 linhas
docker logs traefik --tail 100

# Logs de todos os containers
docker-compose logs -f
```

### Verificar Certificados SSL
```bash
# Ver certificados
cat /opt/traefik/letsencrypt/acme.json | jq

# Ver domínios com certificado
cat /opt/traefik/letsencrypt/acme.json | jq '.letsencrypt.Certificates[].domain.main'

# Verificar validade
openssl s_client -connect inventario.seudominio.com:443 -servername inventario.seudominio.com < /dev/null 2>/dev/null | openssl x509 -noout -dates
```

### Testar Rotas
```bash
# Testar se Traefik está respondendo
curl -I http://localhost

# Testar HTTPS redirect
curl -I http://inventario.seudominio.com

# Testar aplicação
curl -I https://inventario.seudominio.com
```

---

## 🔄 COMANDOS DE MANUTENÇÃO

### Reiniciar Traefik
```bash
cd /opt/traefik
docker-compose restart

# Ou
docker restart traefik
```

### Atualizar Traefik
```bash
cd /opt/traefik
docker-compose pull
docker-compose up -d
```

### Recriar Containers
```bash
cd /opt/traefik
docker-compose down
docker-compose up -d
```

### Forçar Renovação de Certificado
```bash
# Parar Traefik
docker stop traefik

# Remover certificados
rm /opt/traefik/letsencrypt/acme.json
touch /opt/traefik/letsencrypt/acme.json
chmod 600 /opt/traefik/letsencrypt/acme.json

# Iniciar Traefik
docker start traefik

# Verificar logs
docker logs traefik -f
```

---

## 🐛 TROUBLESHOOTING

### Traefik não inicia
```bash
# Ver logs
docker logs traefik

# Verificar configuração
docker run --rm -v /opt/traefik/traefik.yml:/traefik.yml traefik:v2.10 traefik validate /traefik.yml

# Verificar permissões
ls -la /opt/traefik/letsencrypt/acme.json
# Deve ser: -rw------- (600)
```

### SSL não funciona
```bash
# Verificar DNS
nslookup inventario.seudominio.com

# Ver logs do Traefik
docker logs traefik | grep -i acme

# Verificar se porta 80 está acessível
curl -I http://inventario.seudominio.com

# Testar Let's Encrypt
curl -I http://inventario.seudominio.com/.well-known/acme-challenge/test
```

### Container não aparece no Traefik
```bash
# Verificar se está na rede correta
docker inspect inventory-app | grep -A 10 Networks

# Verificar labels
docker inspect inventory-app | grep -A 20 Labels

# Verificar se Traefik detectou
docker logs traefik | grep inventory
```

### Dashboard não acessível
```bash
# Verificar se Traefik está rodando
docker ps | grep traefik

# Testar autenticação
curl -u admin:suasenha https://traefik.seudominio.com/api/overview

# Ver logs
docker logs traefik | grep dashboard
```

---

## 📊 MONITORAMENTO

### Dashboard do Traefik
```
https://traefik.seudominio.com
```

**Informações disponíveis:**
- Routers ativos
- Services
- Middlewares
- Certificados SSL
- Entrypoints
- Providers

### Métricas via API
```bash
# Overview
curl -u admin:senha https://traefik.seudominio.com/api/overview

# Routers
curl -u admin:senha https://traefik.seudominio.com/api/http/routers

# Services
curl -u admin:senha https://traefik.seudominio.com/api/http/services

# Certificados
curl -u admin:senha https://traefik.seudominio.com/api/http/routers | jq '.[].tls'
```

### Prometheus (Opcional)
```yaml
# Adicionar ao traefik.yml
metrics:
  prometheus:
    entryPoint: metrics
    addEntryPointsLabels: true
    addServicesLabels: true

entryPoints:
  metrics:
    address: ":8082"
```

---

## 🔐 MIDDLEWARES ÚTEIS

### Rate Limiting
```yaml
labels:
  - "traefik.http.middlewares.ratelimit.ratelimit.average=100"
  - "traefik.http.middlewares.ratelimit.ratelimit.burst=50"
  - "traefik.http.routers.app.middlewares=ratelimit"
```

### IP Whitelist
```yaml
labels:
  - "traefik.http.middlewares.ipwhitelist.ipwhitelist.sourcerange=192.168.1.0/24,10.0.0.0/8"
  - "traefik.http.routers.app.middlewares=ipwhitelist"
```

### Basic Auth
```bash
# Gerar senha
echo $(htpasswd -nb usuario senha) | sed -e s/\\$/\\$\\$/g

# Adicionar label
labels:
  - "traefik.http.middlewares.auth.basicauth.users=usuario:$$apr1$$..."
  - "traefik.http.routers.app.middlewares=auth"
```

### Headers Customizados
```yaml
labels:
  - "traefik.http.middlewares.headers.headers.customrequestheaders.X-Custom-Header=value"
  - "traefik.http.routers.app.middlewares=headers"
```

### Redirect
```yaml
labels:
  - "traefik.http.middlewares.redirect.redirectregex.regex=^https://old.domain.com/(.*)"
  - "traefik.http.middlewares.redirect.redirectregex.replacement=https://new.domain.com/$${1}"
  - "traefik.http.routers.app.middlewares=redirect"
```

### Compress
```yaml
labels:
  - "traefik.http.middlewares.compress.compress=true"
  - "traefik.http.routers.app.middlewares=compress"
```

### Múltiplos Middlewares
```yaml
labels:
  - "traefik.http.routers.app.middlewares=ratelimit,compress,headers"
```

---

## 🚀 ADICIONAR NOVA APLICAÇÃO

### Template Básico
```yaml
services:
  minha-app:
    image: minha-imagem:latest
    container_name: minha-app
    restart: always
    networks:
      - traefik-network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.minha-app.rule=Host(`app.seudominio.com`)"
      - "traefik.http.routers.minha-app.entrypoints=websecure"
      - "traefik.http.routers.minha-app.tls.certresolver=letsencrypt"
      - "traefik.http.services.minha-app.loadbalancer.server.port=80"

networks:
  traefik-network:
    external: true
```

### Exemplo: WordPress
```yaml
services:
  wordpress:
    image: wordpress:latest
    restart: always
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: senha123
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - wordpress_data:/var/www/html
    networks:
      - traefik-network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.wordpress.rule=Host(`blog.seudominio.com`)"
      - "traefik.http.routers.wordpress.entrypoints=websecure"
      - "traefik.http.routers.wordpress.tls.certresolver=letsencrypt"
      - "traefik.http.services.wordpress.loadbalancer.server.port=80"

volumes:
  wordpress_data:

networks:
  traefik-network:
    external: true
```

---

## 💾 BACKUP

### Backup Completo
```bash
#!/bin/bash
BACKUP_DIR="/root/backups/traefik"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup configuração
tar czf $BACKUP_DIR/traefik-config-$DATE.tar.gz /opt/traefik/

# Backup certificados
cp /opt/traefik/letsencrypt/acme.json $BACKUP_DIR/acme-$DATE.json

# Manter últimos 7 dias
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete
find $BACKUP_DIR -name "*.json" -mtime +7 -delete

echo "Backup concluído: $DATE"
```

### Restaurar Backup
```bash
# Parar Traefik
docker stop traefik

# Restaurar configuração
tar xzf traefik-config-20250115.tar.gz -C /

# Restaurar certificados
cp acme-20250115.json /opt/traefik/letsencrypt/acme.json
chmod 600 /opt/traefik/letsencrypt/acme.json

# Iniciar Traefik
docker start traefik
```

---

## 📋 CHECKLIST RÁPIDO

- [ ] Docker instalado
- [ ] Rede traefik-network criada
- [ ] traefik.yml configurado (email correto)
- [ ] docker-compose.yml do Traefik criado
- [ ] Senha do dashboard gerada
- [ ] acme.json criado (permissão 600)
- [ ] Traefik rodando
- [ ] DNS configurado
- [ ] Portainer rodando
- [ ] Sistema de Inventário rodando
- [ ] SSL funcionando (cadeado verde)
- [ ] Dashboard acessível

---

**Traefik configurado e funcionando!** 🚀
