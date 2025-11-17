# ⚡ Guia Rápido de Instalação - VPS com Docker e Portainer

## 🎯 Para Quem É Este Guia

Você tem uma VPS nova e quer instalar o Sistema de Inventário com:
- ✅ Docker e Portainer (interface gráfica)
- ✅ Nginx Proxy Manager (gerenciar domínios)
- ✅ SSL automático (HTTPS)
- ✅ Suporte para múltiplas aplicações

---

## ⚡ INSTALAÇÃO RÁPIDA (5 minutos)

### Opção 1: Script Automático (Recomendado)

```bash
# 1. Conectar na VPS
ssh root@SEU-IP-VPS

# 2. Baixar e executar script
curl -fsSL https://raw.githubusercontent.com/seu-repo/install-vps-completo.sh -o install.sh
chmod +x install.sh
./install.sh

# 3. Seguir instruções na tela
```

### Opção 2: Manual (10 minutos)

```bash
# 1. Atualizar sistema
apt update && apt upgrade -y

# 2. Instalar Docker
curl -fsSL https://get.docker.com | sh
apt install -y docker-compose

# 3. Configurar firewall
ufw allow 22,80,443,81,9443/tcp
ufw --force enable

# 4. Instalar Portainer
docker volume create portainer_data
docker run -d -p 9443:9443 --name portainer --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest

# 5. Instalar Nginx Proxy Manager
mkdir -p /opt/nginx-proxy-manager && cd /opt/nginx-proxy-manager
# (copiar docker-compose.yml do guia completo)
docker-compose up -d
```

---

## 📋 CHECKLIST DE INSTALAÇÃO

### Antes de Começar
- [ ] IP da VPS anotado
- [ ] Acesso SSH funcionando
- [ ] Domínio registrado
- [ ] Email para SSL anotado

### Instalação Base
- [ ] Sistema atualizado
- [ ] Docker instalado
- [ ] Firewall configurado
- [ ] Portainer rodando (porta 9443)
- [ ] Nginx Proxy Manager rodando (porta 81)

### Configuração DNS
- [ ] Registro A: `inventario.seudominio.com` → IP da VPS
- [ ] Registro A: `portainer.seudominio.com` → IP da VPS
- [ ] DNS propagado (teste: `nslookup inventario.seudominio.com`)

### Deploy do Sistema
- [ ] Arquivos enviados para `/opt/inventory/`
- [ ] Arquivo `.env` configurado
- [ ] Stack criada no Portainer
- [ ] Containers rodando (app + db)

### Configuração Final
- [ ] Proxy configurado no NPM
- [ ] SSL ativo (cadeado verde)
- [ ] Usuário admin criado
- [ ] Login funcionando
- [ ] Configurações da empresa preenchidas

---

## 🌐 ACESSOS IMPORTANTES

| Serviço | URL | Login Padrão |
|---------|-----|--------------|
| **Portainer** | `https://SEU-IP:9443` | Criar na primeira vez |
| **Nginx Proxy Manager** | `http://SEU-IP:81` | `admin@example.com` / `changeme` |
| **Sistema de Inventário** | `https://inventario.seudominio.com` | Criar via console |

---

## 🔧 COMANDOS ÚTEIS

### Ver Status dos Containers
```bash
docker ps                           # Todos os containers
docker ps -a                        # Incluindo parados
docker stats                        # Uso de recursos em tempo real
```

### Ver Logs
```bash
docker logs portainer               # Logs do Portainer
docker logs nginx-proxy-manager     # Logs do NPM
docker logs inventory-app           # Logs da aplicação
docker logs inventory-app -f        # Seguir logs em tempo real
```

### Reiniciar Containers
```bash
docker restart portainer
docker restart nginx-proxy-manager
docker restart inventory-app
docker restart inventory-db
```

### Parar/Iniciar Containers
```bash
docker stop inventory-app
docker start inventory-app
```

### Backup do Banco de Dados
```bash
# Backup
docker exec inventory-db pg_dump -U inventory_user inventory_db > backup_$(date +%Y%m%d).sql

# Restaurar
cat backup_20250115.sql | docker exec -i inventory-db psql -U inventory_user -d inventory_db
```

### Limpar Sistema
```bash
# Remover containers parados
docker container prune -f

# Remover imagens não usadas
docker image prune -a -f

# Remover volumes não usados
docker volume prune -f

# Limpar tudo (CUIDADO!)
docker system prune -a --volumes -f
```

---

## 🚀 ADICIONAR NOVA APLICAÇÃO

### 1. Criar Stack no Portainer
```yaml
# Exemplo: WordPress
version: '3.8'
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
      - nginx-proxy-manager_proxy-network

volumes:
  wordpress_data:

networks:
  nginx-proxy-manager_proxy-network:
    external: true
```

### 2. Configurar DNS
```
blog.seudominio.com → IP da VPS
```

### 3. Configurar Proxy no NPM
- Domain: `blog.seudominio.com`
- Forward to: `wordpress:80`
- SSL: Request new certificate

**Pronto!** Nova aplicação rodando! 🎉

---

## 🔒 CONFIGURAR SSL NO NGINX PROXY MANAGER

### Passo a Passo:

1. **Acessar NPM:** `http://SEU-IP:81`

2. **Add Proxy Host:**
   - **Domain Names:** `inventario.seudominio.com`
   - **Scheme:** `http`
   - **Forward Hostname/IP:** `inventory-app`
   - **Forward Port:** `8000`
   - ✅ Block Common Exploits
   - ✅ Websockets Support

3. **Aba SSL:**
   - **SSL Certificate:** Request a new SSL Certificate
   - ✅ Force SSL
   - ✅ HTTP/2 Support
   - **Email:** seu-email@gmail.com
   - ✅ I Agree to Let's Encrypt ToS

4. **Save**

**Aguarde 30-60 segundos** para o certificado ser gerado.

---

## 👤 CRIAR USUÁRIO ADMIN DO SISTEMA

### Via Portainer Console:

1. **Containers** → `inventory-app` → **Console** → **Connect**
2. **Command:** `/bin/bash`
3. **Connect**

```bash
python run.py create-admin
```

Preencha:
- Nome Completo
- Email
- Senha
- Confirmar Senha

---

## 🐛 SOLUÇÃO DE PROBLEMAS RÁPIDA

### Container não inicia
```bash
docker logs nome-do-container
```

### Erro de conexão com banco
```bash
docker exec -it inventory-db psql -U inventory_user -d inventory_db -c "SELECT 1"
```

### SSL não funciona
```bash
# Verificar DNS
nslookup inventario.seudominio.com

# Ver logs do NPM
docker logs nginx-proxy-manager
```

### Aplicação lenta
```bash
# Ver uso de recursos
docker stats

# Aumentar workers (editar docker-compose.yml)
# Mudar: --workers 4 para --workers 8
```

### Porta já em uso
```bash
# Ver o que está usando a porta
netstat -tulpn | grep :80

# Parar o serviço conflitante
systemctl stop apache2  # ou nginx
```

### Espaço em disco cheio
```bash
# Ver uso de disco
df -h

# Limpar Docker
docker system prune -a --volumes -f

# Ver tamanho dos volumes
docker system df -v
```

---

## 📊 MONITORAMENTO

### Via Portainer
- **Dashboard:** Visão geral
- **Containers:** Status individual
- **Stats:** CPU, RAM, rede
- **Logs:** Em tempo real

### Via Linha de Comando
```bash
# Uso de recursos
htop

# Uso de disco
df -h

# Uso de memória
free -h

# Processos Docker
docker stats --no-stream
```

---

## 🔄 ATUALIZAR SISTEMA

### Atualizar Código da Aplicação
```bash
# SSH no servidor
cd /opt/inventory

# Se usar Git
git pull

# Reiniciar via Portainer ou:
docker restart inventory-app
```

### Atualizar Imagem Docker
```bash
# Parar container
docker stop inventory-app

# Remover container
docker rm inventory-app

# Recriar (via Portainer ou docker-compose)
cd /opt/inventory
docker-compose up -d
```

### Atualizar Portainer
```bash
docker stop portainer
docker rm portainer
docker pull portainer/portainer-ce:latest
# Executar comando de instalação novamente
```

---

## 📁 ESTRUTURA DE DIRETÓRIOS

```
/opt/
├── nginx-proxy-manager/
│   └── docker-compose.yml
│
└── inventory/
    ├── app/                    # Código da aplicação
    ├── docker-compose.yml      # Configuração Docker
    ├── .env                    # Variáveis de ambiente
    ├── .env.example           # Exemplo de configuração
    └── requirements.txt        # Dependências Python
```

---

## 🔐 SEGURANÇA

### Trocar Senha Root
```bash
passwd root
```

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

### Configurar Fail2Ban
```bash
apt install -y fail2ban
systemctl start fail2ban
systemctl enable fail2ban
```

---

## 📞 LINKS ÚTEIS

- **Guia Completo:** `GUIA_INSTALACAO_VPS_PORTAINER_COMPLETO.md`
- **Portainer Docs:** https://docs.portainer.io/
- **Nginx Proxy Manager:** https://nginxproxymanager.com/
- **Docker Docs:** https://docs.docker.com/
- **Let's Encrypt:** https://letsencrypt.org/

---

## 💡 DICAS IMPORTANTES

1. **Sempre faça backup** antes de atualizar
2. **Monitore o uso de recursos** regularmente
3. **Mantenha senhas fortes** e únicas
4. **Atualize o sistema** mensalmente
5. **Configure alertas** no Portainer
6. **Documente suas mudanças**
7. **Teste em ambiente de desenvolvimento** primeiro

---

## ✅ TUDO FUNCIONANDO?

Se você completou todos os itens do checklist:

- ✅ Portainer acessível via HTTPS
- ✅ Nginx Proxy Manager configurado
- ✅ Sistema de Inventário rodando
- ✅ SSL funcionando (cadeado verde)
- ✅ Login funcionando

**PARABÉNS! Seu servidor está pronto!** 🎉

Agora você pode:
- Adicionar mais aplicações
- Configurar backups automáticos
- Monitorar via Portainer
- Escalar conforme necessário

---

**Dúvidas?** Consulte o guia completo ou os logs dos containers! 🚀
