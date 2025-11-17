# 📊 Resumo Visual - Instalação VPS com Docker

## 🎯 FLUXO DE INSTALAÇÃO

```
┌─────────────────────────────────────────────────────────────┐
│  1. VPS NOVA (Ubuntu/Debian)                                │
│     • Conectar via SSH                                      │
│     • Atualizar sistema                                     │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  2. INSTALAR DOCKER                                         │
│     • curl -fsSL https://get.docker.com | sh                │
│     • apt install docker-compose                            │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  3. CONFIGURAR FIREWALL                                     │
│     • Portas: 22, 80, 443, 81, 9443                        │
│     • ufw enable                                            │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  4. INSTALAR PORTAINER (Interface Gráfica)                  │
│     • docker run portainer/portainer-ce                     │
│     • Acesso: https://IP:9443                              │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  5. INSTALAR NGINX PROXY MANAGER                            │
│     • Gerenciar domínios e SSL                             │
│     • Acesso: http://IP:81                                 │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  6. CONFIGURAR DNS                                          │
│     • inventario.seudominio.com → IP                       │
│     • portainer.seudominio.com → IP                        │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  7. DEPLOY SISTEMA DE INVENTÁRIO                            │
│     • Enviar arquivos para /opt/inventory                  │
│     • Configurar .env                                       │
│     • Deploy via Portainer                                  │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  8. CONFIGURAR SSL                                          │
│     • Via Nginx Proxy Manager                              │
│     • Let's Encrypt automático                             │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  ✅ SISTEMA FUNCIONANDO!                                    │
│     • https://inventario.seudominio.com                    │
│     • Criar usuário admin                                   │
│     • Configurar empresa                                    │
└─────────────────────────────────────────────────────────────┘
```

---

## 🗺️ ARQUITETURA DO SERVIDOR

```
┌───────────────────────────────────────────────────────────────┐
│                         INTERNET                              │
└────────────────────────┬──────────────────────────────────────┘
                         │
                         │ Porta 80/443
                         ▼
┌───────────────────────────────────────────────────────────────┐
│              NGINX PROXY MANAGER (Container)                  │
│  • Gerencia domínios                                          │
│  • SSL automático (Let's Encrypt)                            │
│  • Proxy reverso                                              │
└─────┬──────────────────┬──────────────────┬───────────────────┘
      │                  │                  │
      │ inventario.*     │ portainer.*      │ app2.*
      ▼                  ▼                  ▼
┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│  SISTEMA DE │   │  PORTAINER  │   │  OUTRAS     │
│  INVENTÁRIO │   │  (Gerência) │   │  APLICAÇÕES │
│             │   │             │   │             │
│  ┌────────┐ │   └─────────────┘   └─────────────┘
│  │  App   │ │
│  │ Flask  │ │
│  └────┬───┘ │
│       │     │
│  ┌────▼───┐ │
│  │ Postgres│ │
│  │   DB    │ │
│  └─────────┘ │
└─────────────┘

┌───────────────────────────────────────────────────────────────┐
│                    REDE DOCKER (Bridge)                       │
│  • Comunicação entre containers                               │
│  • Isolamento de rede                                         │
└───────────────────────────────────────────────────────────────┘
```

---

## 📦 CONTAINERS E PORTAS

| Container | Porta Interna | Porta Externa | Função |
|-----------|---------------|---------------|--------|
| **nginx-proxy-manager** | 80, 443, 81 | 80, 443, 81 | Proxy + SSL |
| **portainer** | 9443 | 9443 | Interface gráfica |
| **inventory-app** | 8000 | - | Aplicação Flask |
| **inventory-db** | 5432 | - | Banco PostgreSQL |

**Legenda:**
- ✅ Porta Externa = Acessível da internet
- 🔒 Sem Porta Externa = Apenas interno (mais seguro)

---

## 🔐 MATRIZ DE ACESSOS

| Serviço | URL | Porta | Login Inicial | Após Configurar |
|---------|-----|-------|---------------|-----------------|
| **Portainer** | `https://IP:9443` | 9443 | Criar na 1ª vez | `https://portainer.seudominio.com` |
| **NPM** | `http://IP:81` | 81 | `admin@example.com` / `changeme` | Trocar na 1ª vez |
| **Inventário** | Via NPM | 8000 | Criar via console | `https://inventario.seudominio.com` |

---

## 📁 ESTRUTURA DE ARQUIVOS

```
/opt/
│
├── nginx-proxy-manager/
│   ├── docker-compose.yml          # Configuração do NPM
│   └── (volumes gerenciados pelo Docker)
│
└── inventory/
    ├── app/                         # Código da aplicação
    │   ├── __init__.py
    │   ├── models/                  # Modelos do banco
    │   ├── routes/                  # Rotas da API
    │   ├── templates/               # Templates HTML
    │   └── static/                  # CSS, JS, imagens
    │       └── uploads/             # Logos e arquivos
    │
    ├── docker-compose.yml           # Configuração dos containers
    ├── .env                         # Variáveis de ambiente (SECRETO!)
    ├── .env.example                 # Exemplo de configuração
    ├── requirements.txt             # Dependências Python
    ├── run.py                       # Arquivo principal
    └── config.py                    # Configurações da app
```

---

## 🔄 COMANDOS ESSENCIAIS

### Gerenciamento de Containers

```bash
# Ver containers rodando
docker ps

# Ver todos (incluindo parados)
docker ps -a

# Iniciar container
docker start nome-container

# Parar container
docker stop nome-container

# Reiniciar container
docker restart nome-container

# Remover container
docker rm nome-container

# Ver logs
docker logs nome-container

# Seguir logs em tempo real
docker logs -f nome-container

# Acessar terminal do container
docker exec -it nome-container bash
```

### Gerenciamento de Imagens

```bash
# Listar imagens
docker images

# Baixar imagem
docker pull nome-imagem:tag

# Remover imagem
docker rmi nome-imagem

# Limpar imagens não usadas
docker image prune -a
```

### Gerenciamento de Volumes

```bash
# Listar volumes
docker volume ls

# Criar volume
docker volume create nome-volume

# Remover volume
docker volume rm nome-volume

# Limpar volumes não usados
docker volume prune
```

### Docker Compose

```bash
# Iniciar serviços
docker-compose up -d

# Parar serviços
docker-compose down

# Ver logs
docker-compose logs

# Reiniciar serviços
docker-compose restart

# Recriar containers
docker-compose up -d --force-recreate
```

---

## 🚨 TROUBLESHOOTING RÁPIDO

| Problema | Comando para Diagnosticar | Solução Comum |
|----------|---------------------------|---------------|
| Container não inicia | `docker logs nome-container` | Verificar .env e dependências |
| Porta em uso | `netstat -tulpn \| grep :80` | Parar serviço conflitante |
| Sem espaço em disco | `df -h` | `docker system prune -a` |
| Banco não conecta | `docker exec -it inventory-db psql -U inventory_user -d inventory_db` | Verificar senha no .env |
| SSL não funciona | `nslookup dominio.com` | Aguardar propagação DNS |
| App lenta | `docker stats` | Aumentar workers ou RAM |

---

## 📊 MONITORAMENTO

### Via Portainer (Interface Gráfica)

```
Dashboard → Containers → Selecionar Container

┌─────────────────────────────────────┐
│  📊 Stats                           │
│  • CPU: 15%                         │
│  • RAM: 512MB / 2GB                 │
│  • Network: ↓ 1.2MB ↑ 0.8MB        │
│  • Disk: 2.5GB                      │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  📋 Logs (tempo real)               │
│  [2025-01-15 10:30:15] INFO: ...   │
│  [2025-01-15 10:30:16] DEBUG: ...  │
└─────────────────────────────────────┘
```

### Via Linha de Comando

```bash
# Uso de recursos em tempo real
docker stats

# Resultado:
CONTAINER ID   NAME           CPU %   MEM USAGE / LIMIT   NET I/O
abc123         inventory-app  15.2%   512MB / 2GB         1.2MB / 0.8MB
def456         inventory-db   5.1%    256MB / 1GB         0.5MB / 0.3MB
```

---

## 🔐 CHECKLIST DE SEGURANÇA

- [ ] Firewall configurado (UFW)
- [ ] Portas desnecessárias fechadas
- [ ] Senhas fortes no .env
- [ ] SSL ativo (HTTPS)
- [ ] Backup automático configurado
- [ ] Fail2Ban instalado
- [ ] Usuário não-root criado
- [ ] Login root via SSH desabilitado
- [ ] Atualizações automáticas configuradas
- [ ] Monitoramento ativo

---

## 📈 ESCALABILIDADE

### Adicionar Mais Workers

```yaml
# docker-compose.yml
command: gunicorn --workers 8 ...  # Era 4, agora 8
```

### Adicionar Mais RAM ao Container

```yaml
# docker-compose.yml
services:
  app:
    deploy:
      resources:
        limits:
          memory: 4G  # Era 2G
```

### Adicionar Réplicas

```yaml
# docker-compose.yml
services:
  app:
    deploy:
      replicas: 3  # 3 instâncias da aplicação
```

---

## 🎯 PRÓXIMAS APLICAÇÕES

### Exemplo: Adicionar WordPress

```yaml
# /opt/wordpress/docker-compose.yml
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

**Depois:**
1. Deploy via Portainer
2. Configurar DNS: `blog.seudominio.com`
3. Adicionar Proxy no NPM
4. Configurar SSL

---

## 💾 BACKUP AUTOMÁTICO

### Script de Backup

```bash
#!/bin/bash
# /root/backup.sh

BACKUP_DIR="/root/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Criar diretório
mkdir -p $BACKUP_DIR

# Backup do banco
docker exec inventory-db pg_dump -U inventory_user inventory_db > \
  $BACKUP_DIR/db_$DATE.sql

# Backup dos uploads
docker run --rm -v inventory_uploads_data:/data \
  -v $BACKUP_DIR:/backup alpine \
  tar czf /backup/uploads_$DATE.tar.gz -C /data .

# Manter apenas últimos 7 dias
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "Backup concluído: $DATE"
```

### Agendar com Cron

```bash
# Editar crontab
crontab -e

# Adicionar linha (backup diário às 2h da manhã)
0 2 * * * /root/backup.sh >> /var/log/backup.log 2>&1
```

---

## 📞 CONTATOS E RECURSOS

### Documentação Oficial
- **Docker:** https://docs.docker.com/
- **Portainer:** https://docs.portainer.io/
- **Nginx Proxy Manager:** https://nginxproxymanager.com/guide/
- **PostgreSQL:** https://www.postgresql.org/docs/

### Comunidades
- **Docker Community:** https://forums.docker.com/
- **Stack Overflow:** https://stackoverflow.com/questions/tagged/docker
- **Reddit:** r/docker, r/selfhosted

### Ferramentas Úteis
- **WinSCP:** Transferir arquivos (Windows)
- **PuTTY:** Cliente SSH (Windows)
- **Portainer:** Interface gráfica Docker
- **ctop:** Monitoramento de containers (terminal)

---

## ✅ VALIDAÇÃO FINAL

### Tudo Funcionando?

```bash
# 1. Verificar containers
docker ps
# Deve mostrar: portainer, nginx-proxy-manager, inventory-app, inventory-db

# 2. Verificar portas
netstat -tulpn | grep -E ':(80|443|81|9443|8000|5432)'
# Deve mostrar todas as portas em LISTEN

# 3. Verificar DNS
nslookup inventario.seudominio.com
# Deve retornar o IP da VPS

# 4. Testar HTTPS
curl -I https://inventario.seudominio.com
# Deve retornar: HTTP/2 200

# 5. Testar login
# Abrir navegador e fazer login
```

### Se Tudo OK:

✅ Containers rodando  
✅ Portas abertas  
✅ DNS configurado  
✅ SSL funcionando  
✅ Login OK  

**PARABÉNS! Sistema 100% operacional!** 🎉🚀

---

**Imprima este guia e tenha sempre à mão!** 📄✨
