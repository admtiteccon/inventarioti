# 🚀 Guia Completo: Docker + Portainer + Traefik

## 📋 Sobre Este Guia

Instalação completa com **Traefik** como proxy reverso e gerenciador de SSL.

### 🎯 Por Que Traefik?

**Vantagens sobre Nginx Proxy Manager:**
- ✅ **Configuração via Labels** - Tudo no docker-compose.yml
- ✅ **Auto-descoberta** - Detecta containers automaticamente
- ✅ **SSL Automático** - Let's Encrypt integrado
- ✅ **Dashboard Nativo** - Monitoramento em tempo real
- ✅ **Mais Leve** - Menos recursos
- ✅ **Mais Rápido** - Performance superior
- ✅ **Middleware Avançado** - Rate limiting, auth, etc.
- ✅ **Configuração como Código** - Versionável no Git

**Quando usar Traefik:**
- ✅ Você prefere configuração via código (Infrastructure as Code)
- ✅ Quer performance máxima
- ✅ Precisa de features avançadas (rate limiting, circuit breaker)
- ✅ Quer tudo versionado no Git
- ✅ Gosta de automação

**Quando usar Nginx Proxy Manager:**
- ✅ Prefere interface gráfica
- ✅ Quer simplicidade visual
- ✅ Não tem experiência com YAML
- ✅ Quer gerenciar via web

---

## 🏗️ Arquitetura

```
Internet
   ↓
Traefik (Porta 80/443)
   ├─→ inventario.seudominio.com → inventory-app:8000
   ├─→ portainer.seudominio.com → portainer:9000
   └─→ traefik.seudominio.com → traefik:8080 (dashboard)
```

---

## 📝 Informações Necessárias

```
IP da VPS: ___________________
Domínio: ___________________ (ex: seudominio.com.br)
Email para SSL: ___________________ (para Let's Encrypt)
```

---

## 🚀 PARTE 1: PREPARAR VPS

### Passo 1.1: Conectar e Atualizar

```bash
# Conectar
ssh root@SEU-IP-VPS

# Atualizar
apt update && apt upgrade -y

# Instalar ferramentas
apt install -y curl wget git nano htop ufw
```

### Passo 1.2: Configurar Firewall

```bash
# Resetar e configurar
ufw --force reset
ufw default deny incoming
ufw default allow outgoing

# Portas necessárias
ufw allow 22/tcp comment 'SSH'
ufw allow 80/tcp comment 'HTTP'
ufw allow 443/tcp comment 'HTTPS'
ufw allow 9443/tcp comment 'Portainer'

# Ativar
ufw --force enable
ufw status
```

---

## 🐳 PARTE 2: INSTALAR DOCKER

```bash
# Instalar Docker
curl -fsSL https://get.docker.com | sh

# Iniciar e habilitar
systemctl start docker
systemctl enable docker

# Instalar Docker Compose
apt install -y docker-compose

# Verificar
docker --version
docker-compose --version
```

---

## 🌐 PARTE 3: INSTALAR TRAEFIK

### Passo 3.1: Criar Estrutura de Diretórios

```bash
# Criar diretórios
mkdir -p /opt/traefik
mkdir -p /opt/traefik/letsencrypt
cd /opt/traefik
```

### Passo 3.2: Criar Rede Docker

```bash
# Criar rede para Traefik
docker network create traefik-network
```

### Passo 3.3: Criar Arquivo de Configuração do Traefik

```bash
cat > /opt/traefik/traefik.yml << 'EOF'
# Configuração Global
global:
  checkNewVersion: true
  sendAnonymousUsage: false

# API e Dashboard
api:
  dashboard: true
  insecure: false

# Entry Points (Portas)
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

# Certificados Let's Encrypt
certificatesResolvers:
  letsencrypt:
    acme:
      email: seu-email@gmail.com  # MUDE AQUI!
      storage: /letsencrypt/acme.json
      httpChallenge:
        entryPoint: web

# Providers
providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
    network: traefik-network

# Logs
log:
  level: INFO
  format: common

accessLog:
  format: common
EOF
```

**⚠️ IMPORTANTE:** Edite o arquivo e mude `seu-email@gmail.com` para seu email real!

```bash
nano /opt/traefik/traefik.yml
# Mude a linha: email: seu-email@gmail.com
# Salvar: Ctrl+X → Y → Enter
```

### Passo 3.4: Criar docker-compose.yml do Traefik

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
      # Habilitar Traefik para este container
      - "traefik.enable=true"
      
      # Dashboard
      - "traefik.http.routers.traefik-dashboard.rule=Host(`traefik.seudominio.com.br`)"
      - "traefik.http.routers.traefik-dashboard.entrypoints=websecure"
      - "traefik.http.routers.traefik-dashboard.tls.certresolver=letsencrypt"
      - "traefik.http.routers.traefik-dashboard.service=api@internal"
      
      # Autenticação Básica (usuário: admin, senha: admin)
      # Gere sua própria senha com: echo $(htpasswd -nb admin suasenha) | sed -e s/\\$/\\$\\$/g
      - "traefik.http.routers.traefik-dashboard.middlewares=traefik-auth"
      - "traefik.http.middlewares.traefik-auth.basicauth.users=admin:$$apr1$$8evjzm8h$$Yq7Y8.vXxvVXxvVXxvVXx."

networks:
  traefik-network:
    external: true
EOF
```

**⚠️ IMPORTANTE:** Edite o arquivo e mude `traefik.seudominio.com.br` para seu domínio real!

```bash
nano /opt/traefik/docker-compose.yml
# Mude: traefik.seudominio.com.br
# Salvar: Ctrl+X → Y → Enter
```

### Passo 3.5: Gerar Senha para Dashboard do Traefik

```bash
# Instalar htpasswd
apt install -y apache2-utils

# Gerar senha (substitua 'suasenha' por uma senha forte)
echo $(htpasswd -nb admin suasenha) | sed -e s/\\$/\\$\\$/g

# Copie o resultado e cole no docker-compose.yml na linha:
# traefik.http.middlewares.traefik-auth.basicauth.users=COLE_AQUI
```

### Passo 3.6: Criar Arquivo acme.json

```bash
# Criar arquivo para certificados
touch /opt/traefik/letsencrypt/acme.json
chmod 600 /opt/traefik/letsencrypt/acme.json
```

### Passo 3.7: Iniciar Traefik

```bash
cd /opt/traefik
docker-compose up -d

# Verificar
docker ps | grep traefik
docker logs traefik
```

---

## 🖥️ PARTE 4: INSTALAR PORTAINER

### Passo 4.1: Criar Volume

```bash
docker volume create portainer_data
```

### Passo 4.2: Criar docker-compose.yml do Portainer

```bash
mkdir -p /opt/portainer
cd /opt/portainer

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
      # Habilitar Traefik
      - "traefik.enable=true"
      
      # HTTP Router
      - "traefik.http.routers.portainer.rule=Host(`portainer.seudominio.com.br`)"
      - "traefik.http.routers.portainer.entrypoints=websecure"
      - "traefik.http.routers.portainer.tls.certresolver=letsencrypt"
      
      # Service
      - "traefik.http.services.portainer.loadbalancer.server.port=9000"

volumes:
  portainer_data:
    external: true

networks:
  traefik-network:
    external: true
EOF
```

**⚠️ IMPORTANTE:** Edite e mude `portainer.seudominio.com.br`!

```bash
nano docker-compose.yml
# Mude o domínio
# Salvar: Ctrl+X → Y → Enter
```

### Passo 4.3: Iniciar Portainer

```bash
docker-compose up -d

# Verificar
docker ps | grep portainer
docker logs portainer
```

---

## 📦 PARTE 5: INSTALAR SISTEMA DE INVENTÁRIO

### Passo 5.1: Criar Diretório e Enviar Arquivos

```bash
mkdir -p /opt/inventory
cd /opt/inventory

# Envie seus arquivos aqui via SCP, WinSCP ou Git
```

**Do seu PC (PowerShell):**
```powershell
scp -r "C:\Users\ADM.TECCON\CODIGOS PYTHON\INVENTARIO\*" root@SEU-IP:/opt/inventory/
```

### Passo 5.2: Criar docker-compose.yml

```bash
cat > /opt/inventory/docker-compose.yml << 'EOF'
version: '3.8'

services:
  # Banco de Dados
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

  # Aplicação Flask
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
      # Habilitar Traefik
      - "traefik.enable=true"
      
      # HTTP Router
      - "traefik.http.routers.inventory.rule=Host(`inventario.seudominio.com.br`)"
      - "traefik.http.routers.inventory.entrypoints=websecure"
      - "traefik.http.routers.inventory.tls.certresolver=letsencrypt"
      
      # Service
      - "traefik.http.services.inventory.loadbalancer.server.port=8000"
      
      # Middleware (opcional - rate limiting)
      # - "traefik.http.routers.inventory.middlewares=inventory-ratelimit"
      # - "traefik.http.middlewares.inventory-ratelimit.ratelimit.average=100"

volumes:
  postgres_data:
  uploads_data:

networks:
  inventory-network:
    driver: bridge
  traefik-network:
    external: true
EOF
```

**⚠️ IMPORTANTE:** Edite e mude `inventario.seudominio.com.br`!

```bash
nano docker-compose.yml
# Mude o domínio
# Salvar: Ctrl+X → Y → Enter
```

### Passo 5.3: Criar .env

```bash
# Gerar senhas
DB_PASS=$(openssl rand -base64 16)
SECRET=$(openssl rand -hex 32)

cat > .env << EOF
# Banco de Dados
DB_PASSWORD=$DB_PASS

# Segurança
SECRET_KEY=$SECRET

# Email
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USE_TLS=true
MAIL_USERNAME=seu-email@gmail.com
MAIL_PASSWORD=sua-senha-de-app

# Personalização
FOOTER_COMPANY_NAME=Sua Empresa LTDA
EOF

# Editar com seus dados reais
nano .env
```

### Passo 5.4: Iniciar Sistema

```bash
cd /opt/inventory
docker-compose up -d

# Verificar
docker ps
docker logs inventory-app -f
```

---

## 🌐 PARTE 6: CONFIGURAR DNS

No painel do seu provedor de domínio, adicione:

| Tipo | Nome | Valor | TTL |
|------|------|-------|-----|
| A | `inventario` | `SEU-IP-VPS` | 3600 |
| A | `portainer` | `SEU-IP-VPS` | 3600 |
| A | `traefik` | `SEU-IP-VPS` | 3600 |

**Testar propagação:**
```bash
nslookup inventario.seudominio.com.br
nslookup portainer.seudominio.com.br
nslookup traefik.seudominio.com.br
```

---

## ✅ PARTE 7: TESTAR TUDO

### Acessar Traefik Dashboard

```
https://traefik.seudominio.com.br
```

**Login:**
- Usuário: `admin`
- Senha: (a que você definiu)

**Deve mostrar:**
- ✅ 3 routers (inventory, portainer, traefik-dashboard)
- ✅ 3 services
- ✅ Certificados SSL ativos

### Acessar Portainer

```
https://portainer.seudominio.com.br
```

- ✅ Criar usuário admin
- ✅ Conectar ao ambiente local
- ✅ Ver containers rodando

### Acessar Sistema de Inventário

```
https://inventario.seudominio.com.br
```

- ✅ Página de login
- ✅ Cadeado verde (SSL)
- ✅ Sem avisos

---

## 👤 PARTE 8: CRIAR USUÁRIO ADMIN

```bash
docker exec -it inventory-app python run.py create-admin
```

Preencha os dados e faça login!

---

## 🔧 COMANDOS ÚTEIS

### Ver Logs do Traefik
```bash
docker logs traefik -f
```

### Reiniciar Traefik
```bash
cd /opt/traefik
docker-compose restart
```

### Ver Certificados SSL
```bash
cat /opt/traefik/letsencrypt/acme.json | jq
```

### Adicionar Nova Aplicação

Basta adicionar labels no docker-compose.yml:

```yaml
services:
  minha-app:
    image: minha-imagem
    networks:
      - traefik-network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.minha-app.rule=Host(`app.seudominio.com`)"
      - "traefik.http.routers.minha-app.entrypoints=websecure"
      - "traefik.http.routers.minha-app.tls.certresolver=letsencrypt"
      - "traefik.http.services.minha-app.loadbalancer.server.port=80"
```

**Pronto!** SSL automático e tudo funcionando! 🎉

---

## 📊 COMPARAÇÃO: Traefik vs Nginx Proxy Manager

| Característica | Traefik | Nginx Proxy Manager |
|----------------|---------|---------------------|
| **Interface** | Dashboard read-only | Interface completa |
| **Configuração** | Via labels (código) | Via web (cliques) |
| **SSL** | Automático | Automático |
| **Performance** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Recursos** | Menos RAM/CPU | Mais RAM/CPU |
| **Curva de aprendizado** | Média | Fácil |
| **Versionamento** | Sim (Git) | Não |
| **Middlewares** | Muitos nativos | Limitado |
| **Auto-descoberta** | Sim | Não |
| **Ideal para** | DevOps, automação | Iniciantes, visual |

---

## 🎉 PRONTO!

Você agora tem:
- ✅ Traefik como proxy reverso
- ✅ SSL automático
- ✅ Portainer para gerenciamento
- ✅ Sistema de Inventário funcionando
- ✅ Tudo configurado via código (versionável)

**Próximos passos:**
1. Adicionar mais aplicações (só adicionar labels!)
2. Configurar middlewares (rate limiting, auth, etc.)
3. Monitorar via dashboard do Traefik
4. Fazer backup dos arquivos de configuração

---

**Traefik é poderoso e moderno!** 🚀
