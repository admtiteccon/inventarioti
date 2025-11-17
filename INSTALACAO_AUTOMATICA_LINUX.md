# 🚀 Instalação Automática - VPS Linux

## 📋 Sobre o Script

O script `install_linux.sh` automatiza **toda a instalação** do Sistema de Inventário de TI em uma VPS Linux (Ubuntu/Debian).

**O que o script faz:**
- ✅ Instala todas as dependências
- ✅ Configura PostgreSQL
- ✅ Configura Nginx
- ✅ Configura SSL (HTTPS)
- ✅ Configura Supervisor
- ✅ Configura Firewall
- ✅ Configura Backup automático
- ✅ Inicia a aplicação

**Tempo estimado:** 10-15 minutos

---

## 🎯 Pré-requisitos

### VPS
- Ubuntu 20.04+ ou Debian 11+
- Mínimo: 1GB RAM, 10GB disco
- Acesso root via SSH

### Domínio
- Domínio apontado para o IP da VPS
- Exemplo: `inventory.seudominio.com`

### Informações Necessárias
- Nome do domínio
- Email do administrador
- Nome da empresa
- Senha para o banco de dados

---

## 📥 Passo 1: Conectar na VPS

```bash
# Conectar via SSH
ssh root@seu-servidor-ip

# Ou com usuário sudo
ssh seu-usuario@seu-servidor-ip
```

---

## 📦 Passo 2: Baixar o Projeto

**Opção A: Via Git (Recomendado)**

```bash
# Instalar git (se necessário)
apt update
apt install -y git

# Clonar repositório
cd /tmp
git clone https://github.com/seu-usuario/it-inventory.git
cd it-inventory
```

**Opção B: Via Upload (SCP)**

```bash
# No seu computador local (Windows)
scp -r C:\Users\ADM.TECCON\CODIGOS PYTHON\INVENTARIO root@seu-servidor-ip:/tmp/it-inventory

# No servidor
cd /tmp/it-inventory
```

**Opção C: Via wget (se tiver arquivo zip)**

```bash
cd /tmp
wget https://seu-servidor.com/it-inventory.zip
unzip it-inventory.zip
cd it-inventory
```

---

## 🚀 Passo 3: Executar o Script

```bash
# Tornar o script executável
chmod +x install_linux.sh

# Executar como root
sudo ./install_linux.sh
```

---

## 📝 Passo 4: Responder as Perguntas

O script irá solicitar:

```
Nome de domínio (ex: inventory.seudominio.com): inventory.minhaempresa.com
Email do administrador: admin@minhaempresa.com
Nome da empresa: Minha Empresa LTDA
Senha do banco de dados PostgreSQL: ********
Confirme a senha do banco de dados: ********

Configuração:
  Domínio: inventory.minhaempresa.com
  Email: admin@minhaempresa.com
  Empresa: Minha Empresa LTDA
  Banco: inventory_db

Continuar com a instalação? (s/n): s
```

---

## ⏳ Passo 5: Aguardar Instalação

O script executará automaticamente:

```
========================================
PASSO 1: ATUALIZAR SISTEMA
========================================
✓ Sistema atualizado

========================================
PASSO 2: INSTALAR DEPENDÊNCIAS
========================================
✓ Dependências instaladas

========================================
PASSO 3: CONFIGURAR POSTGRESQL
========================================
✓ PostgreSQL configurado

... (continua até o passo 15)
```

---

## ✅ Passo 6: Criar Usuário Administrador

Após a instalação, criar o primeiro usuário:

```bash
sudo -u inventory /home/inventory/it-inventory/venv/bin/python3 /home/inventory/it-inventory/run.py create-admin
```

Preencher:
```
Full Name: Administrador
Email: admin@minhaempresa.com
Password: ********
Confirm Password: ********

Success! Admin user created:
  Name: Administrador
  Email: admin@minhaempresa.com
  Role: admin
```

---

## 🎯 Passo 7: Acessar o Sistema

```
https://inventory.minhaempresa.com
```

Fazer login com as credenciais criadas!

---

## 📧 Passo 8: Configurar Email (Opcional)

```bash
# Editar arquivo .env
sudo nano /home/inventory/it-inventory/.env
```

Alterar:
```bash
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=seu-email@gmail.com
MAIL_PASSWORD=sua-senha-de-app
```

Reiniciar:
```bash
sudo supervisorctl restart inventory
```

---

## 🏢 Passo 9: Configurar Empresa

1. Acessar: `https://seu-dominio.com/settings/`
2. Upload do logo
3. Preencher dados da empresa
4. Salvar

---

## 🎉 Instalação Concluída!

Seu sistema está rodando com:
- ✅ HTTPS (SSL) ativo
- ✅ Banco PostgreSQL configurado
- ✅ Backup automático (diariamente às 2h)
- ✅ Firewall configurado
- ✅ Reinício automático

---

## 🔧 Comandos Úteis

### Ver Status
```bash
sudo supervisorctl status inventory
```

### Reiniciar Aplicação
```bash
sudo supervisorctl restart inventory
```

### Ver Logs
```bash
# Logs da aplicação
tail -f /home/inventory/it-inventory/logs/gunicorn-error.log

# Logs do Nginx
tail -f /var/log/nginx/inventory-error.log
```

### Backup Manual
```bash
/home/inventory/backup.sh
```

### Ver Informações da Instalação
```bash
cat /home/inventory/install_info.txt
```

---

## 📊 Estrutura Criada

```
/home/inventory/
├── it-inventory/           # Aplicação
│   ├── app/               # Código da aplicação
│   ├── venv/              # Ambiente virtual
│   ├── logs/              # Logs
│   ├── .env               # Configurações
│   └── gunicorn_config.py # Config Gunicorn
├── backups/               # Backups automáticos
├── backup.sh              # Script de backup
└── install_info.txt       # Informações da instalação
```

---

## 🐛 Solução de Problemas

### Script falha durante instalação

```bash
# Ver onde parou
cat /var/log/syslog | grep inventory

# Executar novamente
sudo ./install_linux.sh
```

### Aplicação não inicia

```bash
# Ver logs
tail -f /home/inventory/it-inventory/logs/supervisor-error.log

# Verificar status
sudo supervisorctl status inventory

# Reiniciar
sudo supervisorctl restart inventory
```

### Erro de SSL

```bash
# Verificar se domínio aponta para o IP
nslookup seu-dominio.com

# Tentar obter SSL novamente
sudo certbot --nginx -d seu-dominio.com
```

### Erro de banco de dados

```bash
# Verificar se PostgreSQL está rodando
sudo systemctl status postgresql

# Testar conexão
sudo -u postgres psql -c "\l"
```

---

## 🔄 Atualizar Sistema

```bash
# Parar aplicação
sudo supervisorctl stop inventory

# Atualizar código
cd /home/inventory/it-inventory
sudo -u inventory git pull origin main

# Atualizar dependências
sudo -u inventory /home/inventory/it-inventory/venv/bin/pip install -r requirements.txt

# Reiniciar
sudo supervisorctl start inventory
```

---

## 🗑️ Desinstalar

```bash
# Parar serviços
sudo supervisorctl stop inventory
sudo systemctl stop nginx

# Remover arquivos
sudo rm -rf /home/inventory
sudo rm /etc/supervisor/conf.d/inventory.conf
sudo rm /etc/nginx/sites-available/inventory
sudo rm /etc/nginx/sites-enabled/inventory

# Remover banco
sudo -u postgres psql -c "DROP DATABASE inventory_db;"
sudo -u postgres psql -c "DROP USER inventory_user;"

# Remover usuário
sudo userdel -r inventory
```

---

## 📋 Checklist Pós-Instalação

- [ ] Sistema acessível via HTTPS
- [ ] Login funcionando
- [ ] Usuário admin criado
- [ ] Configurações da empresa preenchidas
- [ ] Logo da empresa enviado
- [ ] Email configurado e testado
- [ ] Backup testado
- [ ] Firewall ativo
- [ ] SSL válido

---

## 💡 Dicas

### Performance
- Use VPS com SSD
- Mínimo 2GB RAM para melhor performance
- Configure CDN para arquivos estáticos (opcional)

### Segurança
- Use senhas fortes
- Mantenha sistema atualizado
- Monitore logs regularmente
- Configure fail2ban (opcional)

### Backup
- Teste restauração de backup
- Considere backup externo (S3, Dropbox)
- Mantenha múltiplas cópias

---

## 🆘 Suporte

**Problemas com o script?**
1. Verifique os logs
2. Consulte o guia manual: [INSTALACAO_VPS_LINUX.md](INSTALACAO_VPS_LINUX.md)
3. Execute os comandos manualmente

**Logs importantes:**
- `/home/inventory/it-inventory/logs/gunicorn-error.log`
- `/var/log/nginx/inventory-error.log`
- `/var/log/syslog`

---

## 📈 Próximos Passos

1. **Configurar empresa** - Upload logo e dados
2. **Criar usuários** - Adicionar técnicos e usuários
3. **Importar dados** - Se tiver inventário existente
4. **Configurar email** - Para alertas e notificações
5. **Testar backup** - Garantir que está funcionando
6. **Monitorar** - Verificar logs e performance

---

## ✨ Vantagens do Script Automático

- ✅ **Rápido:** 10-15 minutos vs 2-3 horas manual
- ✅ **Sem erros:** Configuração testada e validada
- ✅ **Completo:** Tudo configurado automaticamente
- ✅ **Seguro:** Firewall e SSL incluídos
- ✅ **Backup:** Já configurado e agendado
- ✅ **Fácil:** Apenas responder perguntas

---

**Instalação automática concluída!** 🎉

Seu sistema está pronto para uso em produção com todas as melhores práticas aplicadas.

**Acesse:** https://seu-dominio.com
