# 🖥️ Sistema de Inventário de TI

Sistema web completo para gerenciamento de inventário de hardware e software, controle de licenças, geolocalização de equipamentos e geração de relatórios automatizados.

![Python](https://img.shields.io/badge/Python-3.9+-blue.svg)
![Flask](https://img.shields.io/badge/Flask-3.0-green.svg)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

---

## ✨ Funcionalidades

### 📦 Gestão de Hardware
- ✅ Cadastro completo de equipamentos (notebooks, desktops, servidores, impressoras)
- ✅ Geolocalização automática via GPS/IP
- ✅ Visualização em mapa interativo
- ✅ Controle de garantias e manutenções
- ✅ Histórico de alterações

### 💿 Gestão de Software
- ✅ Controle de licenças (perpétuas, subscrição, OEM, volume)
- ✅ Pool de licenças com contagem automática
- ✅ Alertas de vencimento (30 dias)
- ✅ Associação software-hardware
- ✅ Rastreamento de instalações

### 👥 Gestão de Usuários
- ✅ 3 níveis de acesso (Admin, Técnico, Usuário)
- ✅ Autenticação segura (bcrypt)
- ✅ Recuperação de senha via email
- ✅ Controle de permissões granular

### 📊 Relatórios
- ✅ Exportação em PDF e Excel
- ✅ Relatórios personalizáveis
- ✅ Agendamento automático
- ✅ Envio por email

### 📥 Importação de Dados
- ✅ Upload via CSV/Excel
- ✅ Validação automática
- ✅ Templates prontos
- ✅ Feedback de erros detalhado

### 🔌 API REST
- ✅ Endpoints para agentes de coleta
- ✅ Autenticação via token
- ✅ Atualização automática de dados
- ✅ Documentação completa

### 🏢 Personalização
- ✅ Upload de logo da empresa
- ✅ Configuração de cores
- ✅ Dados da empresa completos
- ✅ Rodapé personalizável

---

## 🚀 Instalação

### Desenvolvimento Local (Windows)

```bash
# Clonar repositório
git clone https://github.com/seu-usuario/it-inventory.git
cd it-inventory

# Criar ambiente virtual
python -m venv venv
venv\Scripts\activate

# Instalar dependências
pip install -r requirements.txt

# Configurar variáveis de ambiente
copy .env.example .env
# Editar .env com suas configurações

# Inicializar banco de dados
python create_company_settings_table.py
python run.py create-admin

# Iniciar servidor
python run.py
```

Acesse: http://127.0.0.1:5000

### Produção

**🐳 Docker (Recomendado - Mais Fácil):**
```bash
docker-compose up -d
```
- 📖 [Guia de Instalação Docker](INSTALACAO_DOCKER.md)
- Instalação em 3 comandos
- Funciona em qualquer sistema
- Fácil de atualizar e fazer backup

**☁️ Azure App Service (Enterprise):**
- 📖 [Guia de Instalação Azure](INSTALACAO_AZURE.md)
- Plataforma totalmente gerenciada
- Alta disponibilidade (99.95% SLA)
- Escalabilidade automática

**🚀 VPS Linux (Automático):**
```bash
chmod +x install_linux.sh
sudo ./install_linux.sh
```
- 📖 [Guia de Instalação Automática](INSTALACAO_AUTOMATICA_LINUX.md)

**Linux (Manual):**
- 📖 [Guia Completo de Instalação Linux](INSTALACAO_VPS_LINUX.md)

**Windows Server:**
- 📖 [Guia Completo de Instalação Windows](INSTALACAO_VPS_WINDOWS.md)

**Resumo Comparativo:**
- 📖 [Guia de Instalação - Resumo](GUIA_INSTALACAO_RESUMO.md)

---

## 📋 Requisitos

### Desenvolvimento
- Python 3.9+
- SQLite (incluído)
- 1GB RAM
- 5GB disco

### Produção
- Python 3.9+
- PostgreSQL 12+
- Nginx/IIS
- 2GB RAM (Linux) / 4GB RAM (Windows)
- 20GB disco
- Domínio (opcional)

---

## 🔧 Configuração

### Variáveis de Ambiente (.env)

```bash
# Flask
SECRET_KEY=sua-chave-secreta
FLASK_ENV=development

# Banco de Dados
DATABASE_URL=postgresql://user:pass@localhost/db

# Email
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=seu-email@gmail.com
MAIL_PASSWORD=sua-senha

# Empresa
FOOTER_COMPANY_NAME=Sua Empresa
FOOTER_YEAR=2025
FOOTER_VERSION=1.0.0
```

Ver arquivo `.env.example` para configuração completa.

---

## 📚 Documentação

### Guias de Instalação
- [Instalação VPS Linux](INSTALACAO_VPS_LINUX.md)
- [Instalação VPS Windows](INSTALACAO_VPS_WINDOWS.md)
- [Resumo Comparativo](GUIA_INSTALACAO_RESUMO.md)

### Guias de Uso
- [Configurações da Empresa](CONFIGURACOES_EMPRESA.md)
- [Personalização do Rodapé](PERSONALIZACAO_RODAPE.md)
- [Templates de Importação](TEMPLATES_IMPORTACAO.md)
- [Guia de Importação](GUIA_IMPORTACAO.md)

### Guias Técnicos
- [Integração com Agentes](AGENT_INTEGRATION_GUIDE.md)
- [Tradução do Sistema](TRADUCAO_RESUMO.md)

---

## 🏗️ Arquitetura

```
it-inventory/
├── app/
│   ├── models/          # Modelos de banco de dados
│   ├── routes/          # Rotas e controllers
│   ├── services/        # Lógica de negócio
│   ├── utils/           # Utilitários
│   ├── templates/       # Templates HTML
│   └── static/          # CSS, JS, imagens
├── migrations/          # Migrações do banco
├── logs/               # Logs da aplicação
├── uploads/            # Arquivos enviados
├── config.py           # Configurações
├── run.py              # Ponto de entrada
└── requirements.txt    # Dependências
```

---

## 🔐 Segurança

- ✅ Senhas criptografadas (bcrypt)
- ✅ CSRF Protection
- ✅ SQL Injection Prevention
- ✅ XSS Protection
- ✅ HTTPS obrigatório (produção)
- ✅ Rate limiting
- ✅ Validação de inputs
- ✅ Logs de auditoria

---

## 👥 Níveis de Acesso

### Administrador
- ✅ Acesso total ao sistema
- ✅ Gerenciar usuários
- ✅ Configurar empresa
- ✅ Gerar relatórios
- ✅ Gerenciar tokens API

### Técnico
- ✅ Criar/editar ativos
- ✅ Visualizar todos os dados
- ✅ Gerar relatórios
- ✅ Importar dados

### Usuário Comum
- ✅ Visualizar ativos
- ✅ Pesquisar e filtrar
- ❌ Criar/editar
- ❌ Relatórios

---

## 📊 Tecnologias

### Backend
- **Framework:** Flask 3.0
- **ORM:** SQLAlchemy
- **Banco:** PostgreSQL / SQLite
- **Autenticação:** Flask-Login
- **Email:** Flask-Mail
- **Scheduler:** APScheduler

### Frontend
- **HTML5 / CSS3**
- **Bootstrap 5**
- **JavaScript (Vanilla)**
- **Leaflet.js** (mapas)

### Produção
- **WSGI:** Gunicorn (Linux) / Waitress (Windows)
- **Proxy:** Nginx (Linux) / IIS (Windows)
- **SSL:** Let's Encrypt
- **Supervisor:** Supervisor (Linux) / NSSM (Windows)

---

## 🧪 Testes

```bash
# Executar testes
python -m pytest

# Com cobertura
python -m pytest --cov=app

# Teste específico
python test_create_user.py
```

---

## 📈 Performance

### Métricas Esperadas
- **Tempo de resposta:** <200ms
- **Usuários simultâneos:** 50-100 (Linux 2GB)
- **Banco de dados:** 10.000+ registros
- **Upload:** Até 16MB por arquivo

---

## 🔄 Atualizações

### Verificar Versão
```bash
python -c "from app import create_app; app = create_app(); print(app.config['FOOTER_VERSION'])"
```

### Atualizar Sistema
```bash
# Backup primeiro!
git pull origin main
pip install -r requirements.txt
python run.py db upgrade
sudo supervisorctl restart inventory  # Linux
Restart-Service InventoryService      # Windows
```

---

## 🐛 Solução de Problemas

### Erro ao criar usuário
- 📖 [Solução: Criar Usuário](SOLUCAO_CRIAR_USUARIO.md)
- 📖 [Correção Aplicada](CORRECAO_CRIAR_USUARIO.md)

### Rodapé não atualiza
- Reinicie o servidor
- Limpe cache do navegador (Ctrl+F5)

### Erro de banco de dados
```bash
# Verificar conexão
python -c "from app import create_app, db; app = create_app(); app.app_context().push(); db.create_all()"
```

---

## 📝 Changelog

### v1.0.0 (2025-11-12)
- ✅ Sistema completo implementado
- ✅ Gestão de hardware e software
- ✅ Controle de licenças
- ✅ Geolocalização
- ✅ Relatórios PDF/Excel
- ✅ API REST
- ✅ Importação CSV/Excel
- ✅ Configurações da empresa
- ✅ Upload de logo
- ✅ Tradução para português
- ✅ Guias de instalação completos

---

## 🤝 Contribuindo

Contribuições são bem-vindas!

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 👨‍💻 Autor

Desenvolvido com ❤️ para facilitar a gestão de TI.

---

## 📞 Suporte

- 📧 Email: support@tiserver.sbs
- 📖 Documentação: Ver arquivos `.md` no repositório
- 🐛 Issues: GitHub Issues

---

## 🎯 Roadmap

### Próximas Funcionalidades
- [ ] Dashboard com gráficos interativos
- [ ] Notificações em tempo real
- [ ] App mobile
- [ ] Integração com Active Directory
- [ ] Suporte a múltiplas empresas (multi-tenant)
- [ ] Auditoria completa de ações
- [ ] Exportação para outros formatos
- [ ] API GraphQL

---

## ⭐ Agradecimentos

Obrigado por usar o Sistema de Inventário de TI!

Se este projeto foi útil, considere dar uma ⭐ no GitHub!

---

**Versão:** 1.0.0  
**Última Atualização:** 12/11/2025  
**Status:** ✅ Produção
