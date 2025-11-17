# 🐳 Guia Completo - Docker + Portainer (VPS do Zero)

## 📋 Sobre Este Guia

Este guia mostra **passo a passo** como instalar o Sistema de Inventário de TI em uma VPS Linux completamente vazia, usando:
- **Docker** - Containerização
- **Docker Compose** - Orquestração
- **Portainer** - Interface gráfica para gerenciar Docker

**Tempo total:** 20-30 minutos  
**Dificuldade:** ⭐⭐ (Fácil)

---

## 🎯 Pré-requisitos

- VPS Linux (Ubuntu 20.04+ ou Debian 11+)
- Acesso root via SSH
- IP da VPS
- Domínio (opcional)

---

## 🚀 PARTE 1: Preparar VPS e Instalar Docker

### Passo 1: Conectar na VPS

```bash
# Conectar via SSH
ssh root@SEU-IP-VPS

# Exemplo:
ssh root@192.168.1.100
```

---

### Passo 2: Atualizar Sistema

```bash
# Atualizar lista de pacotes
apt update

# Atualizar sistema (pode demorar alguns minutos)
apt upgrade -y

# Instalar utilitários básicos
apt install -y curl wget git nano unzip
```

---

### Passo 3: Instalar Docker

```bash
# Instalar Docker (script oficial)
curl -fsSL https://get.docker.com | sh

# Verificar instalação
docker --version
```

**Deve mostrar:**
```
Docker version 24.0.7, build afdd53b
```

---

### Passo 4: Instalar Docker Compose

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

### Passo 5: Iniciar Docker

```bash
# Iniciar serviço Docker
systemctl start docker

# Habilitar para iniciar automaticamente
systemctl enable docker

# Verificar status
systemctl status docker
```

**Deve mostrar:** `Active: active (running)`

---

## 🎨 PARTE 2: Instalar Portainer

### Passo 6: Criar Volume para Portainer

```bash
# Criar volume persistente
docker volume create portainer_data
```

---

### Passo 7: Instalar Portainer

```bash
# Instalar Portainer Community Edition
docker run -d \
  -p 9000:9000 \
  -p 9443:9443 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest
```

---

### Passo 8: Acessar Portainer

**Abrir navegador:**
```
http://SEU-IP-VPS:9000
```

**Exemplo:**
```
http://192.168.1.100:9000
```

**Primeira vez:**
1. Criar senha de administrador (mínimo 12 caracteres)
2. Confirmar senha
3. Clicar em "Create user"
4. Selecionar "Get Started"
5. Clicar em "local" (ambiente Docker local)

**Pronto! Você está no Portainer!** 🎉

---

## 📦 PARTE 3: Preparar Aplicação

### Passo 9: Criar Diretório do Projeto

```bash
# Criar diretório
mkdir -p /opt/inventory
cd /opt/inventory
```

---

### Passo 10: Enviar Arquivos do Projeto

**Opção A: Via SCP (do seu PC Windows)**

```bash
# No PowerShell do seu PC
scp -r "C:\Users\ADM.TECCON\CODIGOS PYTHON\INVENTARIO\*" root@SEU-IP:/opt/inventory/
```

**Opção B: Via Git**

```bash
# Na VPS
cd /opt/inventory
git clone https://github.com/seu-usuario/it-inventory.git .
```

**Opção C: Via Upload Manual (WinSCP)**

1. Abrir WinSCP
2. Conectar em `root@SEU-IP`
3. Navegar para `/opt/inventory`
4. Arrastar arquivos do projeto

---

### Passo 11: Configurar Variáveis de Ambiente

```bash
# Copiar arquivo de exemplo
cp .env.docker .env

# Editar configurações
nano .env
```

**Configurações mínimas:**

```bash
# Banco de Dados
DB_PASSWORD=SuaSenhaSegura123!

# Flask (gerar com: python3 -c "import secrets; print(secrets.token_hex(32))")
SECRET_KEY=sua-chave-secreta-gerada-aqui

# Email (configurar depois se quiser)
MAIL_SERVER=smtp.gmail.com
MAIL_USERNAME=seu-email@gmail.com
MAIL_PASSWORD=sua-senha-de-app

# Empresa
FOOTER_COMPANY_NAME=Sua Empresa LTDA
FOOTER_SUPPORT_EMAIL=suporte@empresa.com
```

**Salvar:** `Ctrl+O`, `Enter`, `Ctrl+X`

---

## 🎨 PARTE 4: Deploy via Portainer (Interface Gráfica)

### Passo 12: Criar Stack no Portainer

**12.1. No Portainer:**
1. Menu lateral → **Stacks**
2. Clicar em **+ Add stack**

**12.2. Configurar Stack:**
- **Name:** `inventory-system`
- **Build method:** Selecionar **Upload**

**12.3. Upload do docker-compose.yml:**
1. Clicar em **Upload**
2. Selecionar arquivo `docker-compose.yml`
3. Ou copiar e colar o conteúdo

**12.4. Configurar Variáveis de Ambiente:**

Clicar em **+ Add an environment variable** para cada:

```
DB_PASSWORD = SuaSenhaSegura123!
SECRET_KEY = sua-chave-secreta
MAIL_SERVER = smtp.gmail.com
MAIL_USERNAME = seu-email@gmail.com
MAIL_PASSWORD = sua-senha
FOOTER_COMPANY_NAME = Sua Empresa LTDA
```

**12.5. Deploy:**
1. Clicar em **Deploy the stack**
2. Aguardar criação dos containers (~2-3 minutos)

---

### Passo 13: Verificar Containers

**No Portainer:**
1. Menu lateral → **Containers**
2. Verificar se 3 containers estão rodando:
   - ✅ `inventory-app` (verde)
   - ✅ `inventory-db` (verde)
   - ✅ `inventory-nginx` (verde)

**Status deve ser:** `running` e `healthy`

---

### Passo 14: Inicializar Banco de Dados

**14.1. No Portainer:**
1. Menu lateral → **Containers**
2. Clicar em `inventory-app`
3. Clicar em **Console**
4. Selecionar `/bin/bash`
5. Clicar em **Connect**

**14.2. Executar comandos:**

```bash
# Criar tabelas
python -c "from app import create_app, db; app = create_app('production'); app.app_context().push(); db.create_all(); print('✓ Tabelas criadas')"

# Criar tabela de configurações
python create_company_settings_table.py
```

---

### Passo 15: Criar Usuário Administrador

**No console do container (ainda aberto):**

```bash
python run.py create-admin
```

**Preencher:**
```
Full Name: Administrador
Email: admin@empresa.com
Password: ********
Confirm Password: ********
```

**Deve mostrar:**
```
Success! Admin user created:
  Name: Administrador
  Email: admin@empresa.com
  Role: admin
```

---

### Passo 16: Acessar Sistema

**Abrir navegador:**
```
http://SEU-IP-VPS
```

**Exemplo:**
```
http://192.168.1.100
```

**Fazer login com as credenciais criadas!** ✅

---

## 🎨 PARTE 5: Gerenciar via Portainer

### Ver Logs

**No Portainer:**
1. Menu lateral → **Containers**
2. Clicar no container desejado
3. Clicar em **Logs**
4. Ver logs em tempo real

### Reiniciar Container

**No Portainer:**
1. Menu lateral → **Containers**
2. Selecionar container
3. Clicar em **Restart**

### Ver Estatísticas

**No Portainer:**
1. Menu lateral → **Containers**
2. Clicar no container
3. Aba **Stats**
4. Ver CPU, memória, rede em tempo real

### Acessar Console

**No Portainer:**
1. Menu lateral → **Containers**
2. Clicar no container
3. Clicar em **Console**
4. Selecionar `/bin/bash`
5. Clicar em **Connect**

### Gerenciar Volumes

**No Portainer:**
1. Menu lateral → **Volumes**
2. Ver volumes:
   - `inventory_postgres_data` (banco de dados)
   - `inventory_uploads_data` (arquivos enviados)
   - `inventory_logs_data` (logs)

### Fazer Backup

**No Portainer:**
1. Menu lateral → **Volumes**
2. Selecionar volume
3. Clicar em **Browse**
4. Baixar arquivos necessários

---

## 🔄 Atualizar Aplicação

### Via Portainer (Interface Gráfica)

**Passo 1: Parar Stack**
1. Menu lateral → **Stacks**
2. Selecionar `inventory-system`
3. Clicar em **Stop this stack**

**Passo 2: Atualizar Código**
```bash
# Via SSH
cd /opt/inventory
git pull origin main
# Ou fazer upload dos novos arquivos
```

**Passo 3: Reconstruir e Iniciar**
1. No Portainer → **Stacks** → `inventory-system`
2. Clicar em **Editor**
3. Clicar em **Update the stack**
4. ✅ Marcar "Re-pull image and redeploy"
5. Clicar em **Update**

---

## 🔒 Configurar SSL/HTTPS

### Opção 1: Certbot + Nginx

```bash
# Instalar certbot
apt install -y certbot

# Parar nginx do Docker temporariamente
docker stop inventory-nginx

# Obter certificado
certbot certonly --standalone -d seudominio.com

# Copiar certificados
mkdir -p /opt/inventory/ssl
cp /etc/letsencrypt/live/seudominio.com/fullchain.pem /opt/inventory/ssl/
cp /etc/letsencrypt/live/seudominio.com/privkey.pem /opt/inventory/ssl/

# Editar nginx.conf (descomentar seção HTTPS)
nano /opt/inventory/nginx.conf

# Reiniciar stack no Portainer
```

### Opção 2: Nginx Proxy Manager (Recomendado)

**Adicionar ao docker-compose.yml:**

```yaml
  npm:
    image: 'jc21/nginx-proxy-manager:latest'
    container_name: nginx-proxy-manager
    restart: always
    ports:
      - '80:80'
      - '443:443'
      - '81:81'
    volumes:
      - npm_data:/data
      - npm_letsencrypt:/etc/letsencrypt
    networks:
      - inventory-network

volumes:
  npm_data:
  npm_letsencrypt:
```

**Acessar:**
```
http://SEU-IP:81
```

**Login padrão:**
```
Email: admin@example.com
Password: changeme
```

**Configurar:**
1. Trocar senha
2. Adicionar Proxy Host
3. Configurar SSL automático

---

## 📊 Monitoramento no Portainer

### Dashboard

**Portainer → Home:**
- Ver todos os containers
- Status em tempo real
- Uso de recursos

### Estatísticas

**Containers → Stats:**
- CPU usage
- Memory usage
- Network I/O
- Block I/O

### Alertas

**Portainer → Notifications:**
- Configurar webhooks
- Alertas de container down
- Alertas de recursos

---

## 💾 Backup Completo

### Via Portainer

**Backup de Volumes:**
1. Menu lateral → **Volumes**
2. Selecionar volume
3. **Browse** → Baixar arquivos

**Backup de Stack:**
1. Menu lateral → **Stacks**
2. Selecionar stack
3. Copiar configuração

### Via Linha de Comando

```bash
# Criar diretório de backup
mkdir -p /opt/backups

# Backup do banco
docker-compose exec -T db pg_dump -U inventory_user inventory_db | gzip > /opt/backups/db_$(date +%Y%m%d).sql.gz

# Backup dos uploads
docker run --rm -v inventory_uploads_data:/data -v /opt/backups:/backup alpine tar czf /backup/uploads_$(date +%Y%m%d).tar.gz -C /data .

# Backup da configuração
cp /opt/inventory/docker-compose.yml /opt/backups/
cp /opt/inventory/.env /opt/backups/
```

---

## 🔧 Comandos Úteis

### Via SSH (Linha de Comando)

```bash
# Ver containers rodando
docker ps

# Ver logs
docker-compose logs -f

# Reiniciar stack
docker-compose restart

# Parar tudo
docker-compose down

# Iniciar tudo
docker-compose up -d

# Ver uso de recursos
docker stats
```

### Via Portainer (Interface Gráfica)

```
Tudo pode ser feito clicando em botões! 🖱️
- Ver logs: Containers → [nome] → Logs
- Reiniciar: Containers → [nome] → Restart
- Console: Containers → [nome] → Console
- Stats: Containers → [nome] → Stats
```

---

## 🎯 GUIA VISUAL PORTAINER

### Tela Inicial (Home)

```
┌─────────────────────────────────────────┐
│  Portainer                         👤   │
├─────────────────────────────────────────┤
│  📊 Dashboard                           │
│  🐳 Containers (3)                      │
│  📦 Images (3)                          │
│  🗂️  Volumes (3)                        │
│  🌐 Networks (1)                        │
│  📚 Stacks (1)                          │
└─────────────────────────────────────────┘
```

### Gerenciar Containers

```
Containers → Lista
┌──────────────────┬─────────┬────────┐
│ Nome             │ Status  │ Ações  │
├──────────────────┼─────────┼────────┤
│ inventory-app    │ 🟢 Up   │ ⚙️ 📊 📝│
│ inventory-db     │ 🟢 Up   │ ⚙️ 📊 📝│
│ inventory-nginx  │ 🟢 Up   │ ⚙️ 📊 📝│
└──────────────────┴─────────┴────────┘

⚙️ = Gerenciar  📊 = Stats  📝 = Logs
```

---

## 🔥 INSTALAÇÃO COMPLETA PASSO A PASSO

### Resumo dos 16 Passos

```
PARTE 1: Preparar VPS (5 passos)
├─ 1. Conectar via SSH
├─ 2. Atualizar sistema
├─ 3. Instalar Docker
├─ 4. Instalar Docker Compose
└─ 5. Iniciar Docker

PARTE 2: Instalar Portainer (3 passos)
├─ 6. Criar volume
├─ 7. Instalar Portainer
└─ 8. Acessar e configurar

PARTE 3: Deploy Aplicação (8 passos)
├─ 9. Criar diretório
├─ 10. Enviar arquivos
├─ 11. Configurar .env
├─ 12. Criar stack no Portainer
├─ 13. Verificar containers
├─ 14. Inicializar banco
├─ 15. Criar admin
└─ 16. Acessar sistema ✅
```

---

## 📝 Script Automatizado Completo

Criei um script que faz TUDO automaticamente:

```bash
#!/bin/bash
# install-docker-portainer.sh

# Atualizar sistema
apt update && apt upgrade -y

# Instalar utilitários
apt install -y curl wget git nano unzip

# Instalar Docker
curl -fsSL https://get.docker.com | sh

# Instalar Docker Compose
apt install -y docker-compose

# Iniciar Docker
systemctl start docker
systemctl enable docker

# Instalar Portainer
docker volume create portainer_data
docker run -d \
  -p 9000:9000 \
  -p 9443:9443 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest

echo "✓ Docker e Portainer instalados!"
echo "Acesse Portainer em: http://$(hostname -I | awk '{print $1}'):9000"
```

**Usar:**
```bash
chmod +x install-docker-portainer.sh
./install-docker-portainer.sh
```

---

## 🎯 Após Instalação

### Configurar Empresa

1. Acessar: `http://SEU-IP/settings/`
2. Upload do logo
3. Preencher dados da empresa
4. Salvar

### Criar Usuários

1. Menu: Admin → Gerenciar Usuários
2. Adicionar Usuário
3. Preencher dados
4. Selecionar função

### Importar Dados

1. Menu: Hardware → Importar
2. Baixar template
3. Preencher Excel
4. Fazer upload

---

## 🔍 Troubleshooting

### Portainer não abre

```bash
# Verificar se está rodando
docker ps | grep portainer

# Ver logs
docker logs portainer

# Reiniciar
docker restart portainer
```

### Containers não iniciam

**No Portainer:**
1. Stacks → inventory-system
2. Ver logs de cada container
3. Verificar variáveis de ambiente

**Via SSH:**
```bash
cd /opt/inventory
docker-compose logs
```

### Erro de conexão com banco

```bash
# Verificar se banco está rodando
docker ps | grep inventory-db

# Testar conexão
docker-compose exec db psql -U inventory_user -d inventory_db -c "SELECT 1"
```

### Aplicação não responde

```bash
# Ver logs da aplicação
docker-compose logs app

# Reiniciar aplicação
docker-compose restart app
```

---

## 🔒 Segurança

### Firewall

```bash
# Instalar UFW
apt install -y ufw

# Permitir SSH
ufw allow 22/tcp

# Permitir HTTP/HTTPS
ufw allow 80/tcp
ufw allow 443/tcp

# Permitir Portainer
ufw allow 9000/tcp

# Ativar firewall
ufw enable

# Ver status
ufw status
```

### Trocar Porta do Portainer

```bash
# Parar Portainer
docker stop portainer
docker rm portainer

# Reinstalar em porta diferente (ex: 8080)
docker run -d \
  -p 8080:9000 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest
```

---

## 📊 Recursos do Portainer

### O Que Você Pode Fazer

- ✅ **Ver todos os containers** em tempo real
- ✅ **Iniciar/Parar/Reiniciar** com um clique
- ✅ **Ver logs** de qualquer container
- ✅ **Acessar console** (terminal) dos containers
- ✅ **Ver estatísticas** (CPU, RAM, rede)
- ✅ **Gerenciar volumes** (backup, browse)
- ✅ **Gerenciar redes** Docker
- ✅ **Gerenciar imagens** (pull, remove)
- ✅ **Deploy stacks** (docker-compose via interface)
- ✅ **Configurar variáveis** de ambiente
- ✅ **Ver eventos** do Docker
- ✅ **Gerenciar múltiplos** ambientes

### Interface Amigável

```
Sem Portainer:
docker-compose logs app | grep error

Com Portainer:
Clicar em "Logs" → Ver erros destacados em vermelho
```

---

## 💡 Dicas

### Performance

1. **Limitar recursos dos containers:**
   ```yaml
   deploy:
     resources:
       limits:
         cpus: '2'
         memory: 2G
   ```

2. **Usar volumes nomeados** (já configurado)

3. **Limpar imagens antigas:**
   ```bash
   docker system prune -a
   ```

### Backup Automático

**Criar script:**
```bash
nano /opt/backup-docker.sh
```

**Conteúdo:**
```bash
#!/bin/bash
DATE=$(date +%Y%m%d)
cd /opt/inventory
docker-compose exec -T db pg_dump -U inventory_user inventory_db | gzip > /opt/backups/db_$DATE.sql.gz
```

**Agendar:**
```bash
crontab -e
# Adicionar:
0 2 * * * /opt/backup-docker.sh
```

---

## ✅ Checklist Final

- [ ] Docker instalado
- [ ] Docker Compose instalado
- [ ] Portainer rodando (http://IP:9000)
- [ ] Arquivos do projeto em /opt/inventory
- [ ] Arquivo .env configurado
- [ ] Stack criada no Portainer
- [ ] 3 containers rodando (app, db, nginx)
- [ ] Banco de dados inicializado
- [ ] Usuário admin criado
- [ ] Sistema acessível (http://IP)
- [ ] Login funcionando
- [ ] Firewall configurado

---

## 🎉 Pronto!

Seu sistema está rodando com:
- ✅ Docker (containerização)
- ✅ Docker Compose (orquestração)
- ✅ Portainer (interface gráfica)
- ✅ PostgreSQL (banco de dados)
- ✅ Nginx (proxy reverso)
- ✅ Gunicorn (servidor Python)
- ✅ Volumes persistentes
- ✅ Health checks
- ✅ Restart automático

**Acesse:**
- **Sistema:** http://SEU-IP
- **Portainer:** http://SEU-IP:9000

**Gerencie tudo via Portainer com interface gráfica!** 🎨🐳

---

**Instalação Docker + Portainer concluída!** 🎉

A forma mais fácil de gerenciar containers Docker!
