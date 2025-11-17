# 📋 Comandos Prontos para Copiar e Colar

## 🚀 INSTALAÇÃO COMPLETA EM SEQUÊNCIA

### 1️⃣ Conectar na VPS
```bash
ssh root@SEU-IP-VPS
# Substitua SEU-IP-VPS pelo IP real
```

### 2️⃣ Atualizar Sistema
```bash
apt update && apt upgrade -y && apt install -y curl wget git nano htop ufw net-tools
```

### 3️⃣ Configurar Firewall
```bash
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp comment 'SSH'
ufw allow 80/tcp comment 'HTTP'
ufw allow 443/tcp comment 'HTTPS'
ufw allow 81/tcp comment 'Nginx Proxy Manager'
ufw allow 9443/tcp comment 'Portainer'
ufw --force enable
ufw status
```

### 4️⃣ Instalar Docker
```bash
curl -fsSL https://get.docker.com | sh
systemctl start docker
systemctl enable docker
apt install -y docker-compose
docker --version
docker-compose --version
```

### 5️⃣ Instalar Portainer
```bash
docker volume create portainer_data
docker run -d \
  -p 8000:8000 \
  -p 9443:9443 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest
sleep 10
docker ps | grep portainer
```

**Agora acesse:** `https://SEU-IP:9443` e crie o usuário admin do Portainer

### 6️⃣ Instalar Nginx Proxy Manager
```bash
mkdir -p /opt/nginx-proxy-manager
cd /opt/nginx-proxy-manager
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

docker-compose up -d
sleep 15
docker ps | grep nginx-proxy-manager
```

**Agora acesse:** `http://SEU-IP:81`  
**Login:** `admin@example.com` / `changeme`  
**Troque email e senha na primeira vez!**

### 7️⃣ Preparar Diretório do Sistema de Inventário
```bash
mkdir -p /opt/inventory
cd /opt/inventory
```

**PARE AQUI!** Agora você precisa enviar os arquivos do projeto para `/opt/inventory/`

---

## 📤 ENVIAR ARQUIVOS DO SEU PC PARA A VPS

### Opção A: Via SCP (PowerShell no Windows)
```powershell
# No seu PC, abra PowerShell e navegue até a pasta do projeto
cd "C:\Users\ADM.TECCON\CODIGOS PYTHON\INVENTARIO"

# Envie todos os arquivos
scp -r * root@SEU-IP-VPS:/opt/inventory/

# Verificar se enviou
ssh root@SEU-IP-VPS "ls -la /opt/inventory/"
```

### Opção B: Via WinSCP (Interface Gráfica)
1. Baixe WinSCP: https://winscp.net/
2. Conecte na VPS (IP, usuário root, senha)
3. Navegue até `/opt/inventory/`
4. Arraste os arquivos do projeto

### Opção C: Via Git
```bash
# Na VPS
cd /opt/inventory
git clone https://github.com/seu-usuario/seu-repo.git .
```

---

## 🔧 CONFIGURAR SISTEMA DE INVENTÁRIO

### 8️⃣ Criar docker-compose.yml
```bash
cd /opt/inventory
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
      - nginx-proxy-manager_proxy-network
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
```

### 9️⃣ Criar Arquivo .env
```bash
# Gerar senha aleatória para o banco
DB_PASS=$(openssl rand -base64 16)

# Gerar chave secreta
SECRET=$(openssl rand -hex 32)

# Criar arquivo .env
cat > .env << EOF
# Banco de Dados
DB_PASSWORD=$DB_PASS

# Segurança
SECRET_KEY=$SECRET

# Email (CONFIGURE COM SEUS DADOS!)
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USE_TLS=true
MAIL_USERNAME=seu-email@gmail.com
MAIL_PASSWORD=sua-senha-de-app-gmail

# Personalização
FOOTER_COMPANY_NAME=Sua Empresa LTDA
EOF

echo "✓ Arquivo .env criado com senhas aleatórias!"
echo "⚠️  IMPORTANTE: Edite o .env e configure seu email!"
```

### 🔟 Editar .env com Suas Informações
```bash
nano /opt/inventory/.env
```

**Altere estas linhas:**
```env
MAIL_USERNAME=seu-email-real@gmail.com
MAIL_PASSWORD=sua-senha-de-app-real
FOOTER_COMPANY_NAME=Nome da Sua Empresa
```

**Salvar:** `Ctrl+X` → `Y` → `Enter`

---

## 🚀 FAZER DEPLOY

### Via Portainer (Recomendado)

1. Acesse Portainer: `https://SEU-IP:9443`
2. **Stacks** → **+ Add stack**
3. **Name:** `inventory-system`
4. **Build method:** **Upload**
5. Selecione o arquivo `/opt/inventory/docker-compose.yml`
6. **Environment variables:** Clique em **"Load variables from .env file"**
7. Cole o conteúdo do arquivo `/opt/inventory/.env`
8. **Deploy the stack**

### Via Docker Compose (Linha de Comando)
```bash
cd /opt/inventory
docker-compose up -d
docker ps
docker logs inventory-app -f
```

**Aguarde 2-3 minutos** para a primeira inicialização.

---

## 🌐 CONFIGURAR DNS

**No painel do seu provedor de domínio**, adicione estes registros:

| Tipo | Nome | Valor | TTL |
|------|------|-------|-----|
| A | `inventario` | `SEU-IP-VPS` | 3600 |
| A | `portainer` | `SEU-IP-VPS` | 3600 |

**Exemplo:**
- `inventario.seudominio.com.br` → `192.168.1.100`
- `portainer.seudominio.com.br` → `192.168.1.100`

**Testar propagação:**
```bash
nslookup inventario.seudominio.com.br
```

---

## 🔒 CONFIGURAR SSL NO NGINX PROXY MANAGER

### Para o Sistema de Inventário

1. Acesse NPM: `http://SEU-IP:81`
2. **Hosts** → **Proxy Hosts** → **Add Proxy Host**

**Aba Details:**
```
Domain Names: inventario.seudominio.com.br
Scheme: http
Forward Hostname/IP: inventory-app
Forward Port: 8000
☑ Block Common Exploits
☑ Websockets Support
```

**Aba SSL:**
```
SSL Certificate: Request a new SSL Certificate
☑ Force SSL
☑ HTTP/2 Support
Email Address: seu-email@gmail.com
☑ I Agree to the Let's Encrypt Terms of Service
```

3. **Save**

### Para o Portainer

1. **Add Proxy Host** novamente

**Aba Details:**
```
Domain Names: portainer.seudominio.com.br
Scheme: https
Forward Hostname/IP: portainer
Forward Port: 9443
☑ Block Common Exploits
☑ Websockets Support
```

**Aba SSL:**
```
SSL Certificate: Request a new SSL Certificate
☑ Force SSL
☑ HTTP/2 Support
Email Address: seu-email@gmail.com
☑ I Agree
```

2. **Save**

---

## 👤 CRIAR USUÁRIO ADMIN DO SISTEMA

### Via Portainer Console

1. Acesse Portainer: `https://portainer.seudominio.com.br`
2. **Containers** → Clique em `inventory-app`
3. **Console** → **Connect**
4. **Command:** `/bin/bash`
5. **Connect**

```bash
python run.py create-admin
```

**Preencha:**
```
Nome Completo: Administrador
Email: admin@suaempresa.com
Senha: ********
Confirmar Senha: ********
```

### Via SSH (Alternativa)
```bash
docker exec -it inventory-app python run.py create-admin
```

---

## ✅ TESTAR O SISTEMA

### Acessar o Sistema
```
https://inventario.seudominio.com.br
```

**Deve aparecer:**
- ✅ Página de login
- ✅ Cadeado verde (SSL)
- ✅ Sem avisos de segurança

### Fazer Login
```
Email: admin@suaempresa.com
Senha: (a que você criou)
```

### Configurar Empresa
1. Menu → **Sistema** → **Configurações da Empresa**
2. Preencha os dados
3. Upload do logo (opcional)
4. **Salvar**

---

## 🔍 VERIFICAR STATUS

### Ver Containers Rodando
```bash
docker ps
```

**Deve mostrar:**
```
CONTAINER ID   IMAGE                          STATUS
xxx            portainer/portainer-ce         Up
xxx            jc21/nginx-proxy-manager       Up
xxx            inventory-app                  Up
xxx            inventory-db                   Up
```

### Ver Logs em Tempo Real
```bash
# Logs da aplicação
docker logs inventory-app -f

# Logs do banco
docker logs inventory-db -f

# Logs do Nginx Proxy Manager
docker logs nginx-proxy-manager -f
```

### Testar Conexão com Banco
```bash
docker exec -it inventory-db psql -U inventory_user -d inventory_db -c "SELECT 1"
```

**Deve retornar:**
```
 ?column? 
----------
        1
```

---

## 🔄 COMANDOS DE MANUTENÇÃO

### Reiniciar Aplicação
```bash
docker restart inventory-app
```

### Reiniciar Tudo
```bash
cd /opt/inventory
docker-compose restart
```

### Ver Uso de Recursos
```bash
docker stats
```

### Backup do Banco
```bash
# Criar backup
docker exec inventory-db pg_dump -U inventory_user inventory_db > backup_$(date +%Y%m%d).sql

# Verificar
ls -lh backup_*.sql
```

### Restaurar Backup
```bash
cat backup_20250115.sql | docker exec -i inventory-db psql -U inventory_user -d inventory_db
```

### Limpar Sistema
```bash
# Remover containers parados
docker container prune -f

# Remover imagens não usadas
docker image prune -a -f

# Remover volumes não usados (CUIDADO!)
docker volume prune -f
```

### Atualizar Sistema
```bash
cd /opt/inventory
git pull  # Se usar Git
docker-compose down
docker-compose up -d --force-recreate
```

---

## 🐛 TROUBLESHOOTING

### Container não inicia
```bash
docker logs inventory-app
docker logs inventory-db
```

### Erro de porta em uso
```bash
# Ver o que está usando a porta 80
netstat -tulpn | grep :80

# Parar Apache (se estiver rodando)
systemctl stop apache2
systemctl disable apache2
```

### Erro de conexão com banco
```bash
# Verificar se o banco está rodando
docker ps | grep inventory-db

# Testar conexão
docker exec -it inventory-db psql -U inventory_user -d inventory_db

# Ver logs do banco
docker logs inventory-db
```

### SSL não funciona
```bash
# Verificar DNS
nslookup inventario.seudominio.com.br

# Ver logs do NPM
docker logs nginx-proxy-manager

# Verificar certificados
docker exec nginx-proxy-manager ls -la /etc/letsencrypt/live/
```

### Aplicação lenta
```bash
# Ver uso de recursos
docker stats

# Aumentar workers
nano /opt/inventory/docker-compose.yml
# Mudar: --workers 4 para --workers 8

# Reiniciar
docker-compose restart
```

---

## 📊 MONITORAMENTO

### Ver Uso de Recursos
```bash
# CPU, RAM, Rede
docker stats --no-stream

# Espaço em disco
df -h

# Uso de memória
free -h

# Processos
htop
```

### Ver Logs de Todos os Containers
```bash
docker-compose logs -f
```

### Ver Apenas Erros
```bash
docker logs inventory-app 2>&1 | grep -i error
```

---

## 🔐 SEGURANÇA ADICIONAL

### Criar Usuário Não-Root
```bash
adduser seuusuario
usermod -aG sudo seuusuario
usermod -aG docker seuusuario
```

### Desabilitar Login Root via SSH
```bash
nano /etc/ssh/sshd_config
# Mudar: PermitRootLogin yes → PermitRootLogin no
systemctl restart sshd
```

### Instalar Fail2Ban
```bash
apt install -y fail2ban
systemctl start fail2ban
systemctl enable fail2ban
systemctl status fail2ban
```

### Trocar Porta SSH (Opcional)
```bash
nano /etc/ssh/sshd_config
# Mudar: Port 22 → Port 2222
systemctl restart sshd

# Atualizar firewall
ufw allow 2222/tcp
ufw delete allow 22/tcp
```

---

## 🎉 PRONTO!

Se você executou todos os comandos acima, seu sistema está:

✅ Instalado  
✅ Configurado  
✅ Com SSL  
✅ Funcionando  

**Acesse:** `https://inventario.seudominio.com.br`

**Próximos passos:**
1. Criar usuários para sua equipe
2. Cadastrar hardware e software
3. Configurar backup automático
4. Adicionar mais aplicações conforme necessário

---

**Dúvidas?** Consulte os outros guias:
- `GUIA_INSTALACAO_VPS_PORTAINER_COMPLETO.md` - Guia detalhado
- `GUIA_RAPIDO_INSTALACAO.md` - Referência rápida
- `RESUMO_VISUAL_INSTALACAO.md` - Diagramas e fluxos

🚀 **Bom trabalho!**
