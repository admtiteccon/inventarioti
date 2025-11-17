# 🚀 Guia Completo: Instalação do Sistema de Inventário em VPS com Docker e Portainer

## 📋 Sobre Este Guia

Este guia é para você que tem:
- ✅ Uma VPS nova (sem nada instalado)
- ✅ Um domínio registrado (ex: `seudominio.com.br`)
- ✅ Planos de instalar múltiplas aplicações no mesmo servidor
- ✅ Quer usar Portainer para gerenciar tudo visualmente

**Tempo estimado:** 40-60 minutos

---

## 🎯 O Que Vamos Fazer

1. Preparar a VPS do zero
2. Instalar Docker e Docker Compose
3. Instalar Portainer (interface gráfica)
4. Configurar Nginx Proxy Manager (para gerenciar domínios)
5. Instalar o Sistema de Inventário
6. Configurar SSL (HTTPS) automático
7. Deixar tudo pronto para adicionar mais aplicações

---

## 📝 Informações Que Você Vai Precisar

Anote estas informações antes de começar:

```
IP da VPS: ___________________
Usuário SSH: root (ou outro): ___________________
Senha SSH: ___________________
Domínio principal: ___________________ (ex: seudominio.com.br)
Subdomínio para inventário: ___________________ (ex: inventario.seudominio.com.br)
Subdomínio para Portainer: ___________________ (ex: portainer.seudominio.com.br)
Email para SSL: ___________________ (para certificados Let's Encrypt)
```

---

## 🔧 PARTE 1: PREPARAR A VPS

### Passo 1.1: Conectar na VPS via SSH

**No Windows (PowerShell ou CMD):**
```powershell
ssh root@SEU-IP-VPS
```

**Exemplo:**
```powershell
ssh root@192.168.1.100
```

Se aparecer uma mensagem perguntando sobre o certificado, digite `yes` e pressione Enter.

### Passo 1.2: Atualizar o Sistema

```bash
# Atualizar lista de pacotes
apt update

# Atualizar todos os pacotes
apt upgrade -y

# Instalar ferramentas úteis
apt install -y curl wget git nano htop ufw
```

**Aguarde:** Isso pode levar 5-10 minutos dependendo da VPS.

### Passo 1.3: Configurar Firewall Básico

```bash
# Permitir SSH (IMPORTANTE: não pule isso!)
ufw allow 22/tcp

# Permitir HTTP e HTTPS
ufw allow 80/tcp
ufw allow 443/tcp

# Permitir Portainer
ufw allow 9443/tcp

# Ativar firewall
ufw --force enable

# Verificar status
ufw status
```

**Deve mostrar:**
```
Status: active

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
80/tcp                     ALLOW       Anywhere
443/tcp                    ALLOW       Anywhere
9443/tcp                   ALLOW       Anywhere
```

---

## 🐳 PARTE 2: INSTALAR DOCKER

### Passo 2.1: Instalar Docker

```bash
# Baixar e executar script oficial do Docker
curl -fsSL https://get.docker.com | sh
```

**Aguarde:** Download e instalação levam 2-3 minutos.

### Passo 2.2: Configurar Docker

```bash
# Iniciar Docker
systemctl start docker

# Habilitar Docker para iniciar automaticamente
systemctl enable docker

# Verificar se está funcionando
docker --version
```

**Deve mostrar algo como:**
```
Docker version 24.0.7, build afdd53b
```

### Passo 2.3: Instalar Docker Compose

```bash
# Instalar Docker Compose
apt install -y docker-compose

# Verificar instalação
docker-compose --version
```

**Deve mostrar:**
```
docker-compose version 1.29.2
```

---

## 🖥️ PARTE 3: INSTALAR PORTAINER

### Passo 3.1: Criar Volume para Portainer

```bash
# Criar volume persistente
docker volume create portainer_data
```

### Passo 3.2: Instalar Portainer

```bash
docker run -d \
  -p 8000:8000 \
  -p 9443:9443 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest
```

### Passo 3.3: Verificar Instalação

```bash
# Ver se o Portainer está rodando
docker ps
```

**Deve mostrar:**
```
CONTAINER ID   IMAGE                          STATUS
xxx            portainer/portainer-ce:latest  Up
```

### Passo 3.4: Acessar Portainer

**Abra no navegador:**
```
https://SEU-IP-VPS:9443
```

**Exemplo:**
```
https://192.168.1.100:9443
```

⚠️ **Aviso de segurança:** O navegador vai mostrar um aviso sobre certificado. Clique em "Avançado" → "Continuar mesmo assim" (é normal, vamos configurar SSL depois).

### Passo 3.5: Criar Usuário Admin do Portainer

**Na primeira tela:**

1. **Username:** `admin`
2. **Password:** Crie uma senha forte (mínimo 12 caracteres)
3. **Confirm Password:** Repita a senha
4. Clique em **"Create user"**

**Na segunda tela:**

1. Clique em **"Get Started"**
2. Você verá o ambiente "local" → Clique nele

**Pronto! Você está no dashboard do Portainer!** 🎉

---

## 🌐 PARTE 4: INSTALAR NGINX PROXY MANAGER

**Por que?** Para gerenciar múltiplos domínios/subdomínios e SSL automático.

### Passo 4.1: Criar Stack do Nginx Proxy Manager

**No Portainer:**

1. Menu lateral → **"Stacks"**
2. Clique em **"+ Add stack"**
3. **Name:** `nginx-proxy-manager`
4. **Build method:** Selecione **"Web editor"**

### Passo 4.2: Colar Configuração

**Cole este código na área de texto:**

```yaml
version: '3.8'

services:
  nginx-proxy-manager:
    image: 'jc21/nginx-proxy-manager:latest'
    container_name: nginx-proxy-manager
    restart: always
    ports:
      - '80:80'      # HTTP
      - '443:443'    # HTTPS
      - '81:81'      # Interface Admin
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
```

### Passo 4.3: Deploy

1. Role para baixo
2. Clique em **"Deploy the stack"**
3. Aguarde 1-2 minutos (download da imagem)

### Passo 4.4: Acessar Nginx Proxy Manager

**Abra no navegador:**
```
http://SEU-IP-VPS:81
```

**Login padrão:**
- **Email:** `admin@example.com`
- **Password:** `changeme`

**Primeira vez:**
1. Vai pedir para trocar email e senha
2. **Email:** Coloque seu email real
3. **Password:** Crie uma senha forte
4. Clique em **"Save"**

---

## 📦 PARTE 5: PREPARAR ARQUIVOS DO SISTEMA

### Passo 5.1: Criar Diretório do Projeto

```bash
# Criar diretório
mkdir -p /opt/inventory
cd /opt/inventory
```

### Passo 5.2: Enviar Arquivos do Projeto

**Opção A: Via SCP (do seu PC Windows)**

Abra outro PowerShell no seu PC (não feche o SSH):

```powershell
# Navegue até a pasta do projeto
cd "C:\Users\ADM.TECCON\CODIGOS PYTHON\INVENTARIO"

# Envie todos os arquivos
scp -r * root@SEU-IP-VPS:/opt/inventory/
```

**Opção B: Via Git (se tiver repositório)**

```bash
# No servidor SSH
cd /opt/inventory
git clone https://github.com/seu-usuario/seu-repo.git .
```

**Opção C: Criar arquivo ZIP e enviar**

No seu PC:
1. Compacte a pasta do projeto em um ZIP
2. Use WinSCP ou FileZilla para enviar
3. No servidor: `unzip arquivo.zip -d /opt/inventory/`

### Passo 5.3: Verificar Arquivos

```bash
# Listar arquivos
ls -la /opt/inventory/

# Deve mostrar seus arquivos Python, templates, etc.
```

---

## 🚀 PARTE 6: INSTALAR O SISTEMA DE INVENTÁRIO

### Passo 6.1: Criar Arquivo docker-compose.yml

```bash
# Editar arquivo
nano /opt/inventory/docker-compose.yml
```

**Cole este conteúdo:**

```yaml
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
      - proxy-network
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
      apt-get update && apt-get install -y gcc postgresql-client libpq-dev &&
      pip install --no-cache-dir -r requirements.txt &&
      pip install --no-cache-dir gunicorn &&
      python -c 'from app import create_app, db; app = create_app(\"production\"); app.app_context().push(); db.create_all(); print(\"Banco de dados inicializado!\")' &&
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
      - proxy-network
    depends_on:
      db:
        condition: service_healthy

volumes:
  postgres_data:
  uploads_data:

networks:
  inventory-network:
    driver: bridge
  proxy-network:
    external: true
    name: nginx-proxy-manager_proxy-network
```

**Salvar:** Pressione `Ctrl+X`, depois `Y`, depois `Enter`

### Passo 6.2: Criar Arquivo .env

```bash
# Criar arquivo de variáveis
nano /opt/inventory/.env
```

**Cole e PERSONALIZE:**

```env
# Banco de Dados
DB_PASSWORD=SuaSenhaSeguraDB123!

# Segurança
SECRET_KEY=sua-chave-secreta-aleatoria-32-caracteres-aqui

# Email (Gmail exemplo)
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USE_TLS=true
MAIL_USERNAME=seu-email@gmail.com
MAIL_PASSWORD=sua-senha-de-app-gmail

# Personalização
FOOTER_COMPANY_NAME=Sua Empresa LTDA
```

**⚠️ IMPORTANTE:**
- Troque `SuaSenhaSeguraDB123!` por uma senha forte
- Troque `sua-chave-secreta...` por uma string aleatória de 32+ caracteres
- Configure seu email real (para recuperação de senha)

**Salvar:** `Ctrl+X` → `Y` → `Enter`

### Passo 6.3: Deploy via Portainer

**Volte ao Portainer no navegador:**

1. **Stacks** → **"+ Add stack"**
2. **Name:** `inventory-system`
3. **Build method:** Selecione **"Repository"**
4. **Repository URL:** Deixe em branco
5. **Build method:** Mude para **"Upload"**
6. Clique em **"Select file"**
7. Navegue até `/opt/inventory/docker-compose.yml`

**OU use Web editor:**

1. **Build method:** **"Web editor"**
2. Cole o conteúdo do docker-compose.yml acima

### Passo 6.4: Configurar Variáveis de Ambiente

**Role para baixo até "Environment variables":**

Clique em **"Load variables from .env file"** e cole o conteúdo do seu `.env`

**OU adicione manualmente:**

| Name | Value |
|------|-------|
| `DB_PASSWORD` | `SuaSenhaSeguraDB123!` |
| `SECRET_KEY` | `sua-chave-secreta...` |
| `MAIL_SERVER` | `smtp.gmail.com` |
| `MAIL_PORT` | `587` |
| `MAIL_USE_TLS` | `true` |
| `MAIL_USERNAME` | `seu-email@gmail.com` |
| `MAIL_PASSWORD` | `sua-senha-app` |
| `FOOTER_COMPANY_NAME` | `Sua Empresa LTDA` |

### Passo 6.5: Deploy!

1. Clique em **"Deploy the stack"**
2. Aguarde 3-5 minutos (primeira vez demora mais)
3. Vá em **"Containers"** e verifique se estão rodando:
   - `inventory-app` (running)
   - `inventory-db` (running)

---

## 🌐 PARTE 7: CONFIGURAR DOMÍNIO E SSL

### Passo 7.1: Configurar DNS do Domínio

**No painel do seu provedor de domínio (Registro.br, GoDaddy, etc.):**

Adicione estes registros DNS:

| Tipo | Nome | Valor | TTL |
|------|------|-------|-----|
| A | `inventario` | `SEU-IP-VPS` | 3600 |
| A | `portainer` | `SEU-IP-VPS` | 3600 |

**Exemplo:**
- `inventario.seudominio.com.br` → `192.168.1.100`
- `portainer.seudominio.com.br` → `192.168.1.100`

**Aguarde:** Propagação DNS leva 5-30 minutos.

### Passo 7.2: Configurar Proxy no Nginx Proxy Manager

**Acesse:** `http://SEU-IP:81`

#### Configurar Sistema de Inventário:

1. **Hosts** → **Proxy Hosts** → **"Add Proxy Host"**

**Aba "Details":**
- **Domain Names:** `inventario.seudominio.com.br`
- **Scheme:** `http`
- **Forward Hostname / IP:** `inventory-app`
- **Forward Port:** `8000`
- ✅ **Block Common Exploits**
- ✅ **Websockets Support**

**Aba "SSL":**
- **SSL Certificate:** Selecione **"Request a new SSL Certificate"**
- ✅ **Force SSL**
- ✅ **HTTP/2 Support**
- **Email Address:** Seu email
- ✅ **I Agree to the Let's Encrypt Terms of Service**

2. Clique em **"Save"**

**Aguarde 30-60 segundos** para o certificado ser gerado.

#### Configurar Portainer:

1. **"Add Proxy Host"** novamente

**Aba "Details":**
- **Domain Names:** `portainer.seudominio.com.br`
- **Scheme:** `https`
- **Forward Hostname / IP:** `portainer`
- **Forward Port:** `9443`
- ✅ **Block Common Exploits**
- ✅ **Websockets Support**

**Aba "SSL":**
- **SSL Certificate:** **"Request a new SSL Certificate"**
- ✅ **Force SSL**
- ✅ **HTTP/2 Support**
- **Email Address:** Seu email
- ✅ **I Agree**

2. Clique em **"Save"**

---

## 👤 PARTE 8: CRIAR USUÁRIO ADMIN DO SISTEMA

### Passo 8.1: Acessar Console do Container

**No Portainer:**

1. **Containers** → Clique em `inventory-app`
2. **Console** → Clique em **"Connect"**
3. **Command:** Selecione `/bin/bash`
4. Clique em **"Connect"**

### Passo 8.2: Criar Admin

**No terminal que abrir, digite:**

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

**Deve mostrar:**
```
✓ Usuário admin criado com sucesso!
```

---

## ✅ PARTE 9: TESTAR O SISTEMA

### Passo 9.1: Acessar o Sistema

**Abra no navegador:**
```
https://inventario.seudominio.com.br
```

**Deve aparecer:**
- ✅ Página de login
- ✅ Cadeado verde (SSL funcionando)
- ✅ Sem avisos de segurança

### Passo 9.2: Fazer Login

1. **Email:** `admin@suaempresa.com`
2. **Senha:** A que você criou
3. Clique em **"Entrar"**

**Deve entrar no dashboard!** 🎉

### Passo 9.3: Configurar Empresa

1. Menu → **"Sistema"** → **"Configurações da Empresa"**
2. Preencha:
   - Nome da Empresa
   - CNPJ
   - Endereço
   - Telefone
   - Email
3. **Upload do Logo** (opcional)
4. Clique em **"Salvar"**

---

## 🔄 PARTE 10: ADICIONAR MAIS APLICAÇÕES

Agora que você tem tudo configurado, adicionar novas aplicações é fácil!

### Exemplo: Adicionar WordPress

**No Portainer:**

1. **Stacks** → **"+ Add stack"**
2. **Name:** `wordpress`
3. Cole um docker-compose.yml do WordPress
4. **Deploy**

**No Nginx Proxy Manager:**

1. **Add Proxy Host**
2. **Domain:** `blog.seudominio.com.br`
3. **Forward to:** `wordpress:80`
4. **SSL:** Request new certificate
5. **Save**

**Pronto!** Mais uma aplicação rodando! 🚀

---

## 📊 GERENCIAMENTO DIÁRIO

### Ver Logs

**Portainer:**
1. **Containers** → Selecione o container
2. **Logs** → Ver em tempo real

### Reiniciar Aplicação

**Portainer:**
1. **Containers** → Selecione `inventory-app`
2. **Restart**

### Backup do Banco

**Via Portainer Console:**

```bash
# Conectar no container do banco
docker exec -it inventory-db bash

# Fazer backup
pg_dump -U inventory_user inventory_db > /tmp/backup.sql

# Copiar para o host
exit
docker cp inventory-db:/tmp/backup.sql /root/backup_$(date +%Y%m%d).sql
```

### Atualizar Sistema

```bash
# SSH no servidor
cd /opt/inventory

# Atualizar código (se usar Git)
git pull

# Reiniciar via Portainer
# Containers → inventory-app → Restart
```

---

## 🔒 SEGURANÇA ADICIONAL

### Mudar Porta SSH (Opcional mas Recomendado)

```bash
# Editar configuração SSH
nano /etc/ssh/sshd_config

# Mudar linha:
# Port 22
# Para:
Port 2222

# Salvar e reiniciar
systemctl restart sshd

# Atualizar firewall
ufw allow 2222/tcp
ufw delete allow 22/tcp
```

### Configurar Fail2Ban

```bash
# Instalar
apt install -y fail2ban

# Iniciar
systemctl start fail2ban
systemctl enable fail2ban
```

---

## 🐛 SOLUÇÃO DE PROBLEMAS

### Container não inicia

**Verificar logs:**
```bash
docker logs inventory-app
```

**Ou via Portainer:**
Containers → inventory-app → Logs

### Erro de conexão com banco

**Verificar se o banco está rodando:**
```bash
docker ps | grep inventory-db
```

**Testar conexão:**
```bash
docker exec -it inventory-db psql -U inventory_user -d inventory_db -c "SELECT 1"
```

### SSL não funciona

**Verificar DNS:**
```bash
nslookup inventario.seudominio.com.br
```

**Deve retornar o IP da sua VPS.**

**Verificar logs do Nginx Proxy Manager:**
Portainer → Containers → nginx-proxy-manager → Logs

### Aplicação lenta

**Ver uso de recursos:**
Portainer → Containers → Selecione container → Stats

**Aumentar workers do Gunicorn:**
Edite o docker-compose.yml e mude `--workers 4` para `--workers 8`

---

## 📋 CHECKLIST FINAL

- [ ] VPS acessível via SSH
- [ ] Docker instalado e rodando
- [ ] Portainer acessível via `https://portainer.seudominio.com.br`
- [ ] Nginx Proxy Manager rodando
- [ ] DNS configurado e propagado
- [ ] Sistema de Inventário rodando
- [ ] SSL funcionando (cadeado verde)
- [ ] Usuário admin criado
- [ ] Login funcionando
- [ ] Configurações da empresa preenchidas
- [ ] Backup configurado

---

## 🎉 PARABÉNS!

Você agora tem:

✅ **Servidor Docker completo** com Portainer
✅ **Sistema de Inventário** rodando com SSL
✅ **Gerenciamento visual** de todos os containers
✅ **Nginx Proxy Manager** para adicionar mais aplicações
✅ **Infraestrutura escalável** para crescer

### Próximos Passos:

1. **Criar usuários** para sua equipe
2. **Importar dados** via Excel
3. **Cadastrar hardware e software**
4. **Configurar backup automático**
5. **Adicionar mais aplicações** conforme necessário

---

## 📞 Links Úteis

- **Portainer:** https://docs.portainer.io/
- **Nginx Proxy Manager:** https://nginxproxymanager.com/guide/
- **Docker:** https://docs.docker.com/
- **Let's Encrypt:** https://letsencrypt.org/

---

**Sistema instalado e funcionando!** 🐳🚀✨

Qualquer dúvida, consulte os logs via Portainer ou verifique a documentação específica de cada componente.
