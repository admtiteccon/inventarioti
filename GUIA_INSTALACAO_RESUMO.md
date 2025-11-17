# 📚 Guia de Instalação - Resumo Comparativo

## 🎯 Escolha Seu Sistema Operacional

### 🐧 Linux (Ubuntu/Debian)
**Recomendado para:** Produção, performance, custo-benefício

**Vantagens:**
- ✅ Mais leve e rápido
- ✅ Menor custo (VPS mais baratas)
- ✅ Melhor performance
- ✅ Comunidade maior
- ✅ Mais seguro por padrão

**Desvantagens:**
- ❌ Requer conhecimento de linha de comando
- ❌ Menos familiar para usuários Windows

**Guia Completo:** [INSTALACAO_VPS_LINUX.md](INSTALACAO_VPS_LINUX.md)

---

### 🪟 Windows Server
**Recomendado para:** Ambientes corporativos Windows, familiaridade

**Vantagens:**
- ✅ Interface gráfica familiar
- ✅ Integração com Active Directory
- ✅ Ferramentas visuais (IIS Manager)
- ✅ Suporte Microsoft

**Desvantagens:**
- ❌ Mais caro (licenças)
- ❌ Mais pesado (requer mais recursos)
- ❌ Configuração mais complexa

**Guia Completo:** [INSTALACAO_VPS_WINDOWS.md](INSTALACAO_VPS_WINDOWS.md)

---

## 📊 Comparação Rápida

| Aspecto | Linux | Windows |
|---------|-------|---------|
| **Custo VPS** | $5-10/mês | $15-30/mês |
| **RAM Mínima** | 1GB | 2GB |
| **Facilidade** | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Performance** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Segurança** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Manutenção** | ⭐⭐⭐⭐ | ⭐⭐⭐ |

---

## 🚀 Instalação Rápida

### Linux (5 comandos principais)

```bash
# 1. Atualizar sistema
sudo apt update && sudo apt upgrade -y

# 2. Instalar dependências
sudo apt install -y python3 python3-pip python3-venv postgresql nginx supervisor

# 3. Configurar banco
sudo -u postgres psql -c "CREATE DATABASE inventory_db;"
sudo -u postgres psql -c "CREATE USER inventory_user WITH PASSWORD 'senha';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE inventory_db TO inventory_user;"

# 4. Instalar aplicação
cd /home/inventory
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# 5. Iniciar
sudo supervisorctl start inventory
```

### Windows (5 passos principais)

```powershell
# 1. Instalar Python, PostgreSQL, IIS
# (Via instaladores gráficos)

# 2. Configurar banco
# (Via SQL Shell)

# 3. Instalar aplicação
cd C:\inetpub\inventory
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt

# 4. Criar serviço
nssm install InventoryService python.exe start_server.py

# 5. Iniciar
Start-Service InventoryService
```

---

## 📋 Checklist de Instalação

### Antes de Começar
- [ ] VPS contratada e acessível
- [ ] Domínio configurado (opcional)
- [ ] Acesso root/admin
- [ ] Backup dos dados atuais (se houver)

### Durante Instalação
- [ ] Sistema operacional atualizado
- [ ] Python 3.9+ instalado
- [ ] PostgreSQL configurado
- [ ] Aplicação instalada
- [ ] Banco de dados inicializado
- [ ] Usuário admin criado
- [ ] Servidor web configurado (Nginx/IIS)
- [ ] SSL configurado (HTTPS)
- [ ] Firewall configurado
- [ ] Backup automático configurado

### Após Instalação
- [ ] Sistema acessível via navegador
- [ ] Login funcionando
- [ ] Upload de arquivos funcionando
- [ ] Email configurado e testado
- [ ] Backup testado
- [ ] Logs verificados
- [ ] Performance testada

---

## 🔧 Componentes Principais

### Ambos os Sistemas

| Componente | Linux | Windows |
|------------|-------|---------|
| **Python** | 3.9+ | 3.9+ |
| **Banco de Dados** | PostgreSQL | PostgreSQL |
| **Servidor WSGI** | Gunicorn | Waitress |
| **Servidor Web** | Nginx | IIS |
| **Gerenciador de Processos** | Supervisor | NSSM |
| **SSL** | Certbot | Win-ACME |

---

## 💰 Estimativa de Custos

### Linux VPS
```
VPS (2GB RAM, 50GB SSD): $10/mês
Domínio: $12/ano
SSL: Gratuito (Let's Encrypt)
Total: ~$11/mês
```

### Windows VPS
```
VPS (4GB RAM, 80GB SSD): $25/mês
Licença Windows Server: Incluída ou $15/mês
Domínio: $12/ano
SSL: Gratuito (Let's Encrypt)
Total: ~$26-41/mês
```

---

## ⏱️ Tempo de Instalação

### Linux
- **Experiência:** 1-2 horas
- **Primeira vez:** 3-4 horas

### Windows
- **Experiência:** 2-3 horas
- **Primeira vez:** 4-6 horas

---

## 🎓 Nível de Conhecimento Necessário

### Linux
- **Básico:** Comandos de terminal
- **Intermediário:** Configuração de servidores
- **Avançado:** Não necessário

### Windows
- **Básico:** Interface Windows
- **Intermediário:** IIS e serviços
- **Avançado:** Não necessário

---

## 🆘 Suporte e Documentação

### Documentação Oficial
- **Flask:** https://flask.palletsprojects.com/
- **PostgreSQL:** https://www.postgresql.org/docs/
- **Nginx:** https://nginx.org/en/docs/
- **IIS:** https://docs.microsoft.com/iis/

### Guias Específicos
- **Linux Completo:** [INSTALACAO_VPS_LINUX.md](INSTALACAO_VPS_LINUX.md)
- **Windows Completo:** [INSTALACAO_VPS_WINDOWS.md](INSTALACAO_VPS_WINDOWS.md)
- **Configurações:** [CONFIGURACOES_EMPRESA.md](CONFIGURACOES_EMPRESA.md)

---

## 🔒 Segurança

### Ambos os Sistemas
- ✅ Firewall configurado
- ✅ HTTPS obrigatório
- ✅ Senhas fortes
- ✅ Backup automático
- ✅ Logs de acesso
- ✅ Atualizações regulares

### Linux Adicional
- ✅ Fail2Ban (proteção contra ataques)
- ✅ UFW (firewall simplificado)
- ✅ Usuário sem privilégios root

### Windows Adicional
- ✅ Windows Defender
- ✅ Windows Firewall
- ✅ Políticas de grupo

---

## 📈 Performance Esperada

### Linux (VPS 2GB RAM)
- **Usuários simultâneos:** 50-100
- **Tempo de resposta:** <200ms
- **Uso de RAM:** 500MB-1GB
- **Uso de CPU:** 10-30%

### Windows (VPS 4GB RAM)
- **Usuários simultâneos:** 30-50
- **Tempo de resposta:** <300ms
- **Uso de RAM:** 1.5GB-2.5GB
- **Uso de CPU:** 20-40%

---

## 🎯 Recomendação Final

### Escolha Linux se:
- ✅ Quer melhor custo-benefício
- ✅ Prioriza performance
- ✅ Tem conhecimento básico de terminal
- ✅ Quer gastar menos com VPS

### Escolha Windows se:
- ✅ Já tem infraestrutura Windows
- ✅ Prefere interface gráfica
- ✅ Precisa integração com AD
- ✅ Equipe familiarizada com Windows

---

## 📞 Próximos Passos

1. **Escolher sistema operacional**
2. **Contratar VPS**
3. **Seguir guia específico:**
   - [Linux](INSTALACAO_VPS_LINUX.md)
   - [Windows](INSTALACAO_VPS_WINDOWS.md)
4. **Configurar empresa:** [CONFIGURACOES_EMPRESA.md](CONFIGURACOES_EMPRESA.md)
5. **Criar usuários**
6. **Começar a usar!**

---

## ✅ Suporte

**Problemas durante instalação?**
- Consulte os guias específicos
- Verifique os logs do sistema
- Revise as configurações

**Dúvidas?**
- Documentação completa nos guias
- Exemplos de configuração incluídos
- Troubleshooting detalhado

---

**Boa instalação!** 🚀

Escolha seu sistema e siga o guia correspondente para uma instalação completa e segura.
