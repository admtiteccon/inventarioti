# ✅ Checklist de Instalação - Sistema de Inventário

## 📋 Use este checklist para acompanhar sua instalação passo a passo

---

## 🎯 PREPARAÇÃO

### Informações Necessárias
- [ ] IP da VPS anotado: `___________________`
- [ ] Usuário SSH: `___________________`
- [ ] Senha SSH: `___________________`
- [ ] Domínio registrado: `___________________`
- [ ] Subdomínio para inventário: `inventario.___________________`
- [ ] Subdomínio para Portainer: `portainer.___________________`
- [ ] Email para SSL: `___________________`
- [ ] Email para SMTP: `___________________`
- [ ] Senha de app do Gmail: `___________________`

### Requisitos do Servidor
- [ ] RAM: Mínimo 2GB (4GB recomendado)
- [ ] Disco: Mínimo 20GB (50GB recomendado)
- [ ] CPU: Mínimo 2 cores (4 recomendado)
- [ ] Sistema: Ubuntu 20.04+ ou Debian 11+
- [ ] Acesso SSH funcionando

---

## 🔧 PARTE 1: PREPARAR VPS

### Passo 1.1: Conectar
- [ ] Conectado via SSH: `ssh root@SEU-IP`
- [ ] Certificado aceito (se primeira vez)

### Passo 1.2: Atualizar Sistema
- [ ] `apt update` executado
- [ ] `apt upgrade -y` executado
- [ ] Ferramentas instaladas: `curl wget git nano htop ufw`

### Passo 1.3: Configurar Firewall
- [ ] UFW instalado
- [ ] Porta 22 (SSH) liberada
- [ ] Porta 80 (HTTP) liberada
- [ ] Porta 443 (HTTPS) liberada
- [ ] Porta 81 (NPM) liberada
- [ ] Porta 9443 (Portainer) liberada
- [ ] UFW ativado
- [ ] Status verificado: `ufw status`

**Checkpoint 1:** ✅ VPS preparada e segura

---

## 🐳 PARTE 2: INSTALAR DOCKER

### Passo 2.1: Instalar Docker
- [ ] Script oficial baixado e executado
- [ ] Docker iniciado: `systemctl start docker`
- [ ] Docker habilitado: `systemctl enable docker`
- [ ] Versão verificada: `docker --version`

### Passo 2.2: Instalar Docker Compose
- [ ] Docker Compose instalado: `apt install docker-compose`
- [ ] Versão verificada: `docker-compose --version`

**Checkpoint 2:** ✅ Docker funcionando

---

## 🖥️ PARTE 3: INSTALAR PORTAINER

### Passo 3.1: Criar Volume
- [ ] Volume criado: `docker volume create portainer_data`

### Passo 3.2: Instalar Portainer
- [ ] Container Portainer criado e rodando
- [ ] Aguardado 10 segundos para inicialização
- [ ] Status verificado: `docker ps | grep portainer`

### Passo 3.3: Configurar Portainer
- [ ] Acessado: `https://SEU-IP:9443`
- [ ] Aviso de certificado aceito
- [ ] Usuário admin criado
  - Username: `___________________`
  - Password: `___________________` (anote!)
- [ ] Ambiente "local" conectado
- [ ] Dashboard acessível

**Checkpoint 3:** ✅ Portainer funcionando

---

## 🌐 PARTE 4: INSTALAR NGINX PROXY MANAGER

### Passo 4.1: Criar Diretório
- [ ] Diretório criado: `/opt/nginx-proxy-manager`
- [ ] Navegado para o diretório

### Passo 4.2: Criar docker-compose.yml
- [ ] Arquivo `docker-compose.yml` criado
- [ ] Conteúdo correto colado

### Passo 4.3: Iniciar NPM
- [ ] `docker-compose up -d` executado
- [ ] Aguardado 15 segundos
- [ ] Status verificado: `docker ps | grep nginx-proxy-manager`

### Passo 4.4: Configurar NPM
- [ ] Acessado: `http://SEU-IP:81`
- [ ] Login com credenciais padrão
  - Email: `admin@example.com`
  - Password: `changeme`
- [ ] Email trocado para: `___________________`
- [ ] Senha trocada (anote!)
- [ ] Dashboard acessível

**Checkpoint 4:** ✅ Nginx Proxy Manager funcionando

---

## 📦 PARTE 5: PREPARAR SISTEMA DE INVENTÁRIO

### Passo 5.1: Criar Diretório
- [ ] Diretório criado: `/opt/inventory`
- [ ] Navegado para o diretório

### Passo 5.2: Enviar Arquivos
Escolha um método:

**Opção A: Via SCP**
- [ ] PowerShell aberto no PC
- [ ] Navegado até pasta do projeto
- [ ] Comando SCP executado
- [ ] Arquivos verificados no servidor

**Opção B: Via WinSCP**
- [ ] WinSCP instalado
- [ ] Conectado na VPS
- [ ] Arquivos arrastados para `/opt/inventory/`

**Opção C: Via Git**
- [ ] Repositório clonado
- [ ] Arquivos verificados

### Passo 5.3: Verificar Arquivos
- [ ] `ls -la /opt/inventory/` executado
- [ ] Arquivos Python presentes
- [ ] Pasta `app/` presente
- [ ] Arquivo `requirements.txt` presente
- [ ] Arquivo `run.py` presente

**Checkpoint 5:** ✅ Arquivos no servidor

---

## 🔧 PARTE 6: CONFIGURAR SISTEMA

### Passo 6.1: Criar docker-compose.yml
- [ ] Arquivo criado em `/opt/inventory/docker-compose.yml`
- [ ] Conteúdo correto colado
- [ ] Arquivo salvo

### Passo 6.2: Criar .env
- [ ] Arquivo `.env` criado
- [ ] Senha do banco gerada/definida: `___________________`
- [ ] Secret key gerada/definida: `___________________`
- [ ] Email SMTP configurado: `___________________`
- [ ] Senha de app configurada: `___________________`
- [ ] Nome da empresa configurado: `___________________`
- [ ] Arquivo salvo

### Passo 6.3: Verificar Configurações
- [ ] Arquivo `.env` revisado
- [ ] Todas as variáveis preenchidas
- [ ] Senhas fortes definidas

**Checkpoint 6:** ✅ Sistema configurado

---

## 🚀 PARTE 7: FAZER DEPLOY

### Passo 7.1: Deploy via Portainer
- [ ] Portainer acessado
- [ ] Menu "Stacks" → "Add stack"
- [ ] Nome definido: `inventory-system`
- [ ] Método: "Upload" ou "Web editor"
- [ ] docker-compose.yml carregado
- [ ] Variáveis do .env carregadas
- [ ] "Deploy the stack" clicado
- [ ] Aguardado 2-3 minutos

### Passo 7.2: Verificar Containers
- [ ] Menu "Containers" acessado
- [ ] Container `inventory-app` rodando (verde)
- [ ] Container `inventory-db` rodando (verde)
- [ ] Logs verificados (sem erros críticos)

**Checkpoint 7:** ✅ Sistema deployado

---

## 🌐 PARTE 8: CONFIGURAR DNS

### Passo 8.1: Adicionar Registros DNS
No painel do seu provedor de domínio:

- [ ] Registro A criado:
  - Nome: `inventario`
  - Tipo: A
  - Valor: `SEU-IP-VPS`
  - TTL: 3600

- [ ] Registro A criado:
  - Nome: `portainer`
  - Tipo: A
  - Valor: `SEU-IP-VPS`
  - TTL: 3600

### Passo 8.2: Verificar Propagação
- [ ] Aguardado 5-30 minutos
- [ ] Testado: `nslookup inventario.seudominio.com`
- [ ] Retornou IP correto
- [ ] Testado: `nslookup portainer.seudominio.com`
- [ ] Retornou IP correto

**Checkpoint 8:** ✅ DNS configurado

---

## 🔒 PARTE 9: CONFIGURAR SSL

### Passo 9.1: SSL para Sistema de Inventário
No Nginx Proxy Manager (`http://SEU-IP:81`):

- [ ] "Hosts" → "Proxy Hosts" → "Add Proxy Host"

**Aba Details:**
- [ ] Domain Names: `inventario.seudominio.com`
- [ ] Scheme: `http`
- [ ] Forward Hostname/IP: `inventory-app`
- [ ] Forward Port: `8000`
- [ ] ✅ Block Common Exploits
- [ ] ✅ Websockets Support

**Aba SSL:**
- [ ] SSL Certificate: "Request a new SSL Certificate"
- [ ] ✅ Force SSL
- [ ] ✅ HTTP/2 Support
- [ ] Email Address: `___________________`
- [ ] ✅ I Agree to Let's Encrypt ToS
- [ ] "Save" clicado
- [ ] Aguardado 30-60 segundos
- [ ] Certificado gerado com sucesso

### Passo 9.2: SSL para Portainer
- [ ] "Add Proxy Host" novamente

**Aba Details:**
- [ ] Domain Names: `portainer.seudominio.com`
- [ ] Scheme: `https`
- [ ] Forward Hostname/IP: `portainer`
- [ ] Forward Port: `9443`
- [ ] ✅ Block Common Exploits
- [ ] ✅ Websockets Support

**Aba SSL:**
- [ ] SSL Certificate: "Request a new SSL Certificate"
- [ ] ✅ Force SSL
- [ ] ✅ HTTP/2 Support
- [ ] Email Address: `___________________`
- [ ] ✅ I Agree
- [ ] "Save" clicado
- [ ] Certificado gerado com sucesso

**Checkpoint 9:** ✅ SSL configurado

---

## 👤 PARTE 10: CRIAR USUÁRIO ADMIN

### Passo 10.1: Acessar Console
No Portainer:
- [ ] "Containers" → `inventory-app` clicado
- [ ] "Console" → "Connect" clicado
- [ ] Command: `/bin/bash` selecionado
- [ ] "Connect" clicado
- [ ] Terminal aberto

### Passo 10.2: Criar Admin
- [ ] Comando executado: `python run.py create-admin`
- [ ] Nome completo preenchido: `___________________`
- [ ] Email preenchido: `___________________`
- [ ] Senha criada: `___________________` (anote!)
- [ ] Senha confirmada
- [ ] Mensagem de sucesso exibida

**Checkpoint 10:** ✅ Usuário admin criado

---

## ✅ PARTE 11: TESTAR SISTEMA

### Passo 11.1: Acessar Sistema
- [ ] Navegador aberto
- [ ] URL acessada: `https://inventario.seudominio.com`
- [ ] Página de login carregada
- [ ] Cadeado verde (SSL) visível
- [ ] Sem avisos de segurança

### Passo 11.2: Fazer Login
- [ ] Email digitado
- [ ] Senha digitada
- [ ] "Entrar" clicado
- [ ] Dashboard carregado
- [ ] Menu visível
- [ ] Sem erros

### Passo 11.3: Configurar Empresa
- [ ] Menu → "Sistema" → "Configurações da Empresa"
- [ ] Nome da empresa preenchido
- [ ] CNPJ preenchido (se aplicável)
- [ ] Endereço preenchido
- [ ] Telefone preenchido
- [ ] Email preenchido
- [ ] Logo enviado (opcional)
- [ ] "Salvar" clicado
- [ ] Mensagem de sucesso exibida

### Passo 11.4: Testar Funcionalidades
- [ ] Criar usuário teste
- [ ] Cadastrar hardware teste
- [ ] Cadastrar software teste
- [ ] Gerar relatório teste
- [ ] Todas as funcionalidades OK

**Checkpoint 11:** ✅ Sistema funcionando 100%

---

## 🔍 PARTE 12: VERIFICAÇÕES FINAIS

### Verificar Containers
- [ ] `docker ps` executado
- [ ] 4 containers rodando:
  - [ ] portainer
  - [ ] nginx-proxy-manager
  - [ ] inventory-app
  - [ ] inventory-db

### Verificar Logs
- [ ] Logs do app verificados: `docker logs inventory-app`
- [ ] Sem erros críticos
- [ ] Logs do banco verificados: `docker logs inventory-db`
- [ ] Sem erros críticos

### Verificar Acessos
- [ ] Portainer: `https://portainer.seudominio.com` ✅
- [ ] NPM: `http://SEU-IP:81` ✅
- [ ] Sistema: `https://inventario.seudominio.com` ✅

### Verificar SSL
- [ ] Cadeado verde em todos os acessos HTTPS
- [ ] Certificados válidos
- [ ] Sem avisos de segurança

### Verificar Recursos
- [ ] `docker stats` executado
- [ ] Uso de CPU normal (< 50%)
- [ ] Uso de RAM normal (< 80%)
- [ ] Uso de disco verificado: `df -h`

**Checkpoint 12:** ✅ Tudo verificado

---

## 🎉 INSTALAÇÃO CONCLUÍDA!

### ✅ Checklist Final

- [ ] VPS preparada e segura
- [ ] Docker instalado e funcionando
- [ ] Portainer acessível e configurado
- [ ] Nginx Proxy Manager funcionando
- [ ] DNS configurado e propagado
- [ ] Sistema deployado
- [ ] SSL ativo (HTTPS)
- [ ] Usuário admin criado
- [ ] Login funcionando
- [ ] Configurações da empresa preenchidas
- [ ] Todas as funcionalidades testadas

---

## 📝 INFORMAÇÕES PARA GUARDAR

### Acessos
```
Portainer:
URL: https://portainer.seudominio.com
Usuário: ___________________
Senha: ___________________

Nginx Proxy Manager:
URL: http://SEU-IP:81
Email: ___________________
Senha: ___________________

Sistema de Inventário:
URL: https://inventario.seudominio.com
Email Admin: ___________________
Senha: ___________________

SSH:
IP: ___________________
Usuário: ___________________
Senha: ___________________
```

### Senhas Importantes
```
DB_PASSWORD: ___________________
SECRET_KEY: ___________________
MAIL_PASSWORD: ___________________
```

### Arquivos Importantes
```
Docker Compose NPM: /opt/nginx-proxy-manager/docker-compose.yml
Docker Compose App: /opt/inventory/docker-compose.yml
Variáveis de Ambiente: /opt/inventory/.env
```

---

## 🔄 PRÓXIMOS PASSOS

### Configuração Inicial
- [ ] Criar usuários para equipe
- [ ] Importar dados via Excel
- [ ] Cadastrar departamentos
- [ ] Configurar categorias

### Segurança
- [ ] Configurar backup automático
- [ ] Instalar Fail2Ban
- [ ] Criar usuário não-root
- [ ] Desabilitar login root SSH

### Monitoramento
- [ ] Configurar alertas no Portainer
- [ ] Agendar backups diários
- [ ] Configurar monitoramento de recursos

### Expansão
- [ ] Adicionar outras aplicações
- [ ] Configurar mais domínios
- [ ] Escalar recursos se necessário

---

## 📞 SUPORTE

Se algo não funcionou:

1. **Consulte os guias:**
   - `GUIA_INSTALACAO_VPS_PORTAINER_COMPLETO.md`
   - `GUIA_RAPIDO_INSTALACAO.md`
   - `COMANDOS_COPIAR_COLAR.md`

2. **Verifique logs:**
   ```bash
   docker logs inventory-app
   docker logs inventory-db
   docker logs nginx-proxy-manager
   ```

3. **Troubleshooting:**
   - Ver seção de problemas comuns nos guias
   - Verificar firewall e DNS
   - Reiniciar containers se necessário

---

## 🎊 PARABÉNS!

Você completou a instalação do Sistema de Inventário de TI!

**Seu servidor está:**
- ✅ Seguro (firewall + SSL)
- ✅ Escalável (Docker + Portainer)
- ✅ Gerenciável (interface gráfica)
- ✅ Pronto para produção

**Aproveite seu novo sistema!** 🚀

---

**Data da Instalação:** ___/___/______  
**Instalado por:** ___________________  
**Tempo total:** _______ minutos
