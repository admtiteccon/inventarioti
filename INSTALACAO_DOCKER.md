# 🐳 Guia de Instalação - Docker

## 📋 Sobre

Instalação do Sistema de Inventário de TI usando **Docker e Docker Compose**. A forma mais simples e rápida de colocar o sistema em produção!

**Vantagens:**
- ✅ Instalação em **3 comandos**
- ✅ Funciona em **qualquer sistema** (Linux, Windows, Mac)
- ✅ Isolamento completo
- ✅ Fácil de atualizar
- ✅ Fácil de fazer backup
- ✅ Escalável

**Tempo de instalação:** 5-10 minutos

---

## 🎯 Pré-requisitos

### Docker e Docker Compose Instalados

**Linux (Ubuntu/Debian):**
```bash
# Instalar Docker
curl -fsSL https://get.docker.com | sh

# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER

# Instalar Docker Compose
sudo apt install -y docker-compose

# Verificar instalação
docker --version
docker-compose --version
```

**Windows:**
- Baixar Docker Desktop: https://www.docker.com/products/docker-desktop

**Mac:**
- Baixar Docker Desktop: https://www.docker.com/products/docker-desktop

---

## 🚀 Instalação Rápida (3 Comandos)

### Passo 1: Configurar Variáveis

```bash
# Copiar arquivo de exemplo
cp .env.docker .env

# Editar configurações
nano .env
```

**Configurar:**
- `DB_PASSWORD` - Senha do banco de dados
- `SECRET_KEY` - Chave secreta (gerar com: `python -c "import secrets; print(secrets.token_hex(32))"`)
- `MAIL_*` - Configurações de email
- `FOOTER_*` - Dados da empresa

### Passo 2: Iniciar Containers

```bash
# Construir e iniciar
docker-compose up -d
```

### Passo 3: Criar Usuário Admin

```bash
# Acessar container
docker-compose exec app python run.py create-admin
```

**Pronto!** Acesse: http://localhost

---

## 📋 Instalação Detalhada

### Passo 1: Preparar Arquivos

**1.1. Enviar arquivos para servidor:**

```bash
# Via SCP
scp -r "C:\Users\ADM.TECCON\CODIGOS PYTHON\INVENTARIO" user@servidor:/opt/inventory

# Ou via Git
git clone https://github.com/seu-usuario/it-inventory.git /opt/inventory
```

**1.2. Entrar no diretório:**

```bash
cd /opt/inventory
```

---

### Passo 2: Configurar Ambiente

**2.1. Criar arquivo .env:**

```bash
cp .env.docker .env
nano .env
```

**2.2. Configurações mínimas:**

```bash
# Banco de Dados
DB_PASSWORD=SuaSenhaSegura123!

# Flask
SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")

# Email (opcional, configurar depois)
MAIL_SERVER=smtp.gmail.com
MAIL_USERNAME=seu-email@gmail.com
MAIL_PASSWORD=sua-senha-de-app

# Empresa
FOOTER_COMPANY_NAME=Sua Empresa LTDA
FOOTER_SUPPORT_EMAIL=suporte@empresa.com
```

---

### Passo 3: Iniciar Sistema

**3.1. Construir imagens:**

```bash
docker-compose build
```

**3.2. Iniciar containers:**

```bash
docker-compose up -d
```

**3.3. Verificar status:**

```bash
docker-compose ps
```

**Deve mostrar:**
```
NAME                IMAGE               STATUS
inventory-app       inventory-app       Up (healthy)
inventory-db        postgres:15-alpine  Up (healthy)
inventory-nginx     nginx:alpine        Up (healthy)
```

---

### Passo 4: Inicializar Banco de Dados

**4.1. Criar tabelas:**

```bash
docker-compose exec app python -c "from app import create_app, db; app = create_app('production'); app.app_context().push(); db.create_all(); print('✓ Tabelas criadas')"
```

**4.2. Criar tabela de configurações:**

```bash
docker-compose exec app python create_company_settings_table.py
```

---

### Passo 5: Criar Usuário Administrador

```bash
docker-compose exec app python run.py create-admin
```

**Preencher:**
```
Full Name: Administrador
Email: admin@empresa.com
Password: ********
Confirm Password: ********
```

---

### Passo 6: Acessar Sistema

**Abrir navegador:**
```
http://localhost
```

Ou com IP do servidor:
```
http://192.168.1.100
```

**Fazer login com credenciais criadas!** ✅

---

## 🔧 Comandos Úteis

### Gerenciar Containers

```bash
# Ver status
docker-compose ps

# Ver logs
docker-compose logs -f

# Ver logs de um serviço específico
docker-compose logs -f app
docker-compose logs -f db
docker-compose logs -f nginx

# Reiniciar
docker-compose restart

# Parar
docker-compose stop

# Iniciar
docker-compose start

# Parar e remover
docker-compose down

# Parar e remover (incluindo volumes)
docker-compose down -v
```

### Acessar Containers

```bash
# Shell no container da aplicação
docker-compose exec app bash

# Shell no container do banco
docker-compose exec db psql -U inventory_user -d inventory_db

# Shell no container do nginx
docker-compose exec nginx sh
```

### Atualizar Aplicação

```bash
# Parar containers
docker-compose down

# Atualizar código (git pull ou copiar arquivos)
git pull origin main

# Reconstruir e iniciar
docker-compose up -d --build
```

---

## 📊 Estrutura dos Containers

```
┌─────────────────────────────────────────┐
│           Internet / Usuários           │
└──────────────────┬──────────────────────┘
                   │
                   ▼
         ┌─────────────────┐
         │  Nginx (Port 80)│
         │  Proxy Reverso  │
         └────────┬─────────┘
                  │
                  ▼
         ┌─────────────────┐
         │  App (Port 8000)│
         │  Flask/Gunicorn │
         └────────┬─────────┘
                  │
                  ▼
         ┌─────────────────┐
         │ PostgreSQL (5432)│
         │   Banco de Dados │
         └──────────────────┘
```

---

## 💾 Backup e Restore

### Backup

**Banco de Dados:**
```bash
# Backup do banco
docker-compose exec db pg_dump -U inventory_user inventory_db > backup_$(date +%Y%m%d).sql

# Ou com docker-compose
docker-compose exec -T db pg_dump -U inventory_user inventory_db | gzip > backup_$(date +%Y%m%d).sql.gz
```

**Uploads:**
```bash
# Backup dos arquivos enviados
docker run --rm -v inventory_uploads_data:/data -v $(pwd):/backup alpine tar czf /backup/uploads_$(date +%Y%m%d).tar.gz -C /data .
```

**Backup Completo (Script):**
```bash
#!/bin/bash
# backup-docker.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="./backups"

mkdir -p $BACKUP_DIR

# Backup banco
docker-compose exec -T db pg_dump -U inventory_user inventory_db | gzip > $BACKUP_DIR/db_$DATE.sql.gz

# Backup uploads
docker run --rm -v inventory_uploads_data:/data -v $(pwd)/$BACKUP_DIR:/backup alpine tar czf /backup/uploads_$DATE.tar.gz -C /data .

echo "Backup concluído: $DATE"
```

### Restore

**Banco de Dados:**
```bash
# Restaurar banco
gunzip < backup_20251112.sql.gz | docker-compose exec -T db psql -U inventory_user inventory_db
```

**Uploads:**
```bash
# Restaurar uploads
docker run --rm -v inventory_uploads_data:/data -v $(pwd):/backup alpine tar xzf /backup/uploads_20251112.tar.gz -C /data
```

---

## 🔒 SSL/HTTPS com Let's Encrypt

### Opção 1: Certbot Manual

```bash
# Instalar certbot
sudo apt install -y certbot

# Parar nginx temporariamente
docker-compose stop nginx

# Obter certificado
sudo certbot certonly --standalone -d seudominio.com

# Copiar certificados
sudo mkdir -p ./ssl
sudo cp /etc/letsencrypt/live/seudominio.com/fullchain.pem ./ssl/
sudo cp /etc/letsencrypt/live/seudominio.com/privkey.pem ./ssl/

# Editar nginx.conf (descomentar seção HTTPS)
nano nginx.conf

# Reiniciar nginx
docker-compose up -d nginx
```

### Opção 2: Nginx Proxy Manager (Recomendado)

Usar Nginx Proxy Manager para gerenciar SSL automaticamente:

```yaml
# Adicionar ao docker-compose.yml
  npm:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: always
    ports:
      - '80:80'
      - '443:443'
      - '81:81'
    volumes:
      - npm_data:/data
      - npm_letsencrypt:/etc/letsencrypt
```

---

## 📈 Escalabilidade

### Múltiplas Instâncias da Aplicação

```bash
# Escalar aplicação para 3 instâncias
docker-compose up -d --scale app=3
```

### Load Balancer

Editar `nginx.conf`:

```nginx
upstream inventory_app {
    server app:8000;
    server app:8001;
    server app:8002;
}
```

---

## 🐛 Solução de Problemas

### Container não inicia

```bash
# Ver logs
docker-compose logs app

# Ver logs em tempo real
docker-compose logs -f app
```

### Erro de conexão com banco

```bash
# Verificar se banco está rodando
docker-compose ps db

# Ver logs do banco
docker-compose logs db

# Testar conexão
docker-compose exec db psql -U inventory_user -d inventory_db -c "SELECT 1"
```

### Erro de permissão

```bash
# Ajustar permissões dos volumes
docker-compose down
sudo chown -R 1000:1000 ./uploads ./logs
docker-compose up -d
```

### Resetar tudo

```bash
# Parar e remover tudo (CUIDADO: apaga dados!)
docker-compose down -v

# Remover imagens
docker-compose down --rmi all

# Reconstruir do zero
docker-compose up -d --build
```

---

## 🎯 Ambientes (Dev/Prod)

### Desenvolvimento

```bash
# docker-compose.dev.yml
version: '3.8'
services:
  app:
    build: .
    environment:
      FLASK_ENV: development
      FLASK_DEBUG: 1
    volumes:
      - .:/app
    ports:
      - "5000:8000"
```

**Usar:**
```bash
docker-compose -f docker-compose.dev.yml up
```

### Produção

```bash
# Usar docker-compose.yml padrão
docker-compose up -d
```

---

## 💡 Dicas

### Performance

1. **Usar volumes nomeados** (já configurado)
2. **Limitar recursos:**
   ```yaml
   deploy:
     resources:
       limits:
         cpus: '2'
         memory: 2G
   ```

### Segurança

1. **Não expor porta do banco:**
   ```yaml
   # Remover do docker-compose.yml
   # ports:
   #   - "5432:5432"
   ```

2. **Usar secrets do Docker:**
   ```yaml
   secrets:
     db_password:
       file: ./secrets/db_password.txt
   ```

### Monitoramento

```bash
# Ver uso de recursos
docker stats

# Ver logs de todos os containers
docker-compose logs -f --tail=100
```

---

## ✅ Checklist de Instalação

- [ ] Docker instalado
- [ ] Docker Compose instalado
- [ ] Arquivos do projeto copiados
- [ ] Arquivo .env configurado
- [ ] `docker-compose up -d` executado
- [ ] Containers rodando (healthy)
- [ ] Banco de dados inicializado
- [ ] Usuário admin criado
- [ ] Sistema acessível no navegador
- [ ] Login funcionando

---

## 📊 Comparação com Outras Instalações

| Aspecto | Docker | VPS Manual | Azure |
|---------|--------|------------|-------|
| **Tempo Setup** | 10min | 2-3h | 30min |
| **Dificuldade** | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Portabilidade** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ |
| **Manutenção** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Custo** | Baixo | Baixo | Médio |
| **Escalabilidade** | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ |

---

## 🎉 Pronto!

Seu sistema está rodando em Docker com:
- ✅ PostgreSQL isolado
- ✅ Aplicação Flask em container
- ✅ Nginx como proxy
- ✅ Volumes persistentes
- ✅ Health checks
- ✅ Restart automático
- ✅ Fácil de atualizar
- ✅ Fácil de fazer backup

**Acesse:** http://localhost

**Documentação Docker:** https://docs.docker.com/

---

**Instalação Docker concluída!** 🐳🎉
