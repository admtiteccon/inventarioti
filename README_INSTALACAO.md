# 📚 Guias de Instalação - Sistema de Inventário de TI

## 🎯 Escolha o Guia Ideal Para Você

Este projeto possui múltiplos guias de instalação para diferentes cenários. Escolha o que melhor se adequa à sua situação:

---

## 🆕 NOVO! Instalação em VPS com Docker e Portainer

**Ideal para:** VPS nova, múltiplas aplicações, gerenciamento visual

### 🎯 Escolha Seu Proxy Reverso:

#### Opção A: Nginx Proxy Manager (Interface Gráfica)
- ✅ Interface web completa
- ✅ Gerenciamento visual
- ✅ Ideal para iniciantes
- ✅ Fácil de usar

#### Opção B: Traefik (Moderno e Automático)
- ✅ Configuração via código
- ✅ Auto-descoberta de containers
- ✅ Mais rápido e leve
- ✅ Ideal para DevOps

**📊 Comparação completa:** `COMPARACAO_TRAEFIK_VS_NPM.md`

---

### 📖 Guias Disponíveis:

#### 1. **GUIA_INSTALACAO_VPS_PORTAINER_COMPLETO.md** ⭐ RECOMENDADO
- 📄 **Tipo:** Guia completo passo a passo
- ⏱️ **Tempo:** 40-60 minutos
- 👥 **Nível:** Iniciante a Intermediário
- 📝 **Conteúdo:**
  - Instalação do zero em VPS limpa
  - Docker + Portainer + Nginx Proxy Manager
  - Configuração de domínio e SSL
  - Gerenciamento via interface gráfica
  - Suporte para múltiplas aplicações

**Quando usar:**
- ✅ Você tem uma VPS nova sem nada instalado
- ✅ Quer gerenciar tudo via interface gráfica (Portainer)
- ✅ Planeja instalar outras aplicações no mesmo servidor
- ✅ Quer SSL automático (Let's Encrypt)
- ✅ Tem um domínio registrado
- ✅ Prefere interface visual para gerenciar domínios

---

#### 2. **GUIA_INSTALACAO_TRAEFIK_COMPLETO.md** ⭐ ALTERNATIVA MODERNA
- 📄 **Tipo:** Guia completo com Traefik
- ⏱️ **Tempo:** 30-45 minutos
- 👥 **Nível:** Intermediário
- 📝 **Conteúdo:**
  - Instalação com Traefik (proxy moderno)
  - Configuração via código (Infrastructure as Code)
  - Auto-descoberta de containers
  - SSL automático
  - Performance superior
  - Middlewares avançados

**Quando usar:**
- ✅ Você prefere configuração via código
- ✅ Quer Infrastructure as Code (versionável)
- ✅ Precisa de performance máxima
- ✅ Quer automação avançada
- ✅ Gosta de ter controle total
- ✅ Planeja usar CI/CD

---

#### 3. **GUIA_RAPIDO_INSTALACAO.md**
- 📄 **Tipo:** Referência rápida
- ⏱️ **Tempo:** 5-10 minutos (consulta)
- 👥 **Nível:** Todos
- 📝 **Conteúdo:**
  - Checklist de instalação
  - Comandos essenciais
  - Troubleshooting rápido
  - Dicas de monitoramento
  - Como adicionar novas aplicações

**Quando usar:**
- ✅ Você já instalou e precisa de referência rápida
- ✅ Quer consultar comandos específicos
- ✅ Precisa resolver problemas comuns
- ✅ Quer adicionar mais aplicações

---

#### 4. **COMANDOS_COPIAR_COLAR.md** / **COMANDOS_TRAEFIK.md**
- 📄 **Tipo:** Lista de comandos prontos
- ⏱️ **Tempo:** Variável
- 👥 **Nível:** Todos
- 📝 **Conteúdo:**
  - Comandos prontos para copiar
  - Instalação em sequência
  - Configurações completas
  - Manutenção e troubleshooting

**Quando usar:**
- ✅ Quer instalar rapidamente sem ler muito
- ✅ Prefere copiar e colar comandos
- ✅ Já tem experiência com Linux
- ✅ Quer automatizar a instalação

---

#### 5. **RESUMO_VISUAL_INSTALACAO.md**
- 📄 **Tipo:** Diagramas e fluxos visuais
- ⏱️ **Tempo:** 5 minutos (leitura)
- 👥 **Nível:** Todos
- 📝 **Conteúdo:**
  - Fluxograma de instalação
  - Arquitetura do sistema
  - Matriz de acessos
  - Comandos essenciais
  - Checklist de segurança

**Quando usar:**
- ✅ Quer entender a arquitetura antes de instalar
- ✅ Prefere visualizar o processo
- ✅ Quer imprimir e ter à mão
- ✅ Precisa de referência visual rápida

---

#### 6. **install-vps-completo.sh** / **install-traefik-completo.sh**
- 📄 **Tipo:** Script de instalação automática
- ⏱️ **Tempo:** 10-15 minutos
- 👥 **Nível:** Intermediário
- 📝 **Conteúdo:**
  - Instalação automatizada
  - Docker + Portainer + NPM
  - Configuração de firewall
  - Preparação do ambiente

**Quando usar:**
- ✅ Quer automatizar a instalação base
- ✅ Tem experiência com scripts bash
- ✅ Quer economizar tempo
- ✅ Prefere instalação não-interativa

**Como usar:**

**Com Nginx Proxy Manager:**
```bash
curl -fsSL https://raw.githubusercontent.com/seu-repo/install-vps-completo.sh -o install.sh
chmod +x install.sh
./install.sh
```

**Com Traefik:**
```bash
curl -fsSL https://raw.githubusercontent.com/seu-repo/install-traefik-completo.sh -o install.sh
chmod +x install.sh
./install.sh
```

---

## 📊 Comparação dos Guias

| Guia | Detalhamento | Tempo | Melhor Para |
|------|--------------|-------|-------------|
| **Completo (NPM)** | ⭐⭐⭐⭐⭐ | 40-60 min | Primeira instalação (visual) |
| **Completo (Traefik)** | ⭐⭐⭐⭐⭐ | 30-45 min | Primeira instalação (código) |
| **Rápido** | ⭐⭐⭐ | 5-10 min | Referência e consulta |
| **Comandos** | ⭐⭐ | Variável | Instalação rápida |
| **Visual** | ⭐⭐⭐⭐ | 5 min | Entender arquitetura |
| **Script** | ⭐ | 10-15 min | Automação |
| **Comparação** | ⭐⭐⭐⭐ | 10 min | Escolher entre Traefik/NPM |

---

## 🗺️ Outros Guias de Instalação

### Instalação Docker Básica

#### **INSTALACAO_DOCKER.md**
- Docker Compose simples
- Sem Portainer
- Sem gerenciamento de domínios
- Ideal para: Testes locais, desenvolvimento

#### **INSTALACAO_DOCKER_PORTAINER.md**
- Docker + Portainer
- Sem Nginx Proxy Manager
- Ideal para: Servidor único, sem múltiplas aplicações

---

### Instalação em VPS (Sem Docker)

#### **INSTALACAO_VPS_LINUX.md**
- Instalação manual em Linux
- Sem containers
- Nginx + Gunicorn + PostgreSQL
- Ideal para: Quem não quer usar Docker

#### **INSTALACAO_AUTOMATICA_LINUX.md**
- Script de instalação automática
- Sem Docker
- Ideal para: Instalação rápida tradicional

#### **install_linux.sh**
- Script bash para instalação
- Configuração automática
- Ideal para: Automação

---

### Instalação em Windows

#### **INSTALACAO_VPS_WINDOWS.md**
- Windows Server
- IIS + Python
- Ideal para: Ambiente Windows corporativo

---

### Instalação em Cloud

#### **INSTALACAO_AZURE.md**
- Azure App Service
- Banco de dados gerenciado
- Ideal para: Cloud Azure

---

### Deployment e Empacotamento

#### **GUIA_DEPLOYMENT_ZIP.md**
- Criar pacote ZIP
- Deploy em qualquer servidor
- Ideal para: Distribuição

#### **create_deployment_package.py**
- Script Python para empacotar
- Gera ZIP pronto para deploy

---

## 🎯 Fluxo de Decisão

```
Você tem uma VPS nova?
│
├─ SIM → Quer usar Docker?
│   │
│   ├─ SIM → Quer interface gráfica?
│   │   │
│   │   ├─ SIM → Quer múltiplas aplicações?
│   │   │   │
│   │   │   ├─ SIM → 📖 GUIA_INSTALACAO_VPS_PORTAINER_COMPLETO.md ⭐
│   │   │   └─ NÃO → 📖 INSTALACAO_DOCKER_PORTAINER.md
│   │   │
│   │   └─ NÃO → 📖 INSTALACAO_DOCKER.md
│   │
│   └─ NÃO → 📖 INSTALACAO_VPS_LINUX.md
│
└─ NÃO → Já tem servidor configurado?
    │
    ├─ SIM → Quer apenas comandos?
    │   └─ 📖 COMANDOS_COPIAR_COLAR.md
    │
    └─ NÃO → Está no Windows?
        │
        ├─ SIM → 📖 INSTALACAO_VPS_WINDOWS.md
        └─ NÃO → Está na Azure?
            │
            ├─ SIM → 📖 INSTALACAO_AZURE.md
            └─ NÃO → 📖 GUIA_DEPLOYMENT_ZIP.md
```

---

## 🚀 Início Rápido (Recomendado)

### Para VPS Nova com Docker e Portainer:

1. **Leia primeiro:** `RESUMO_VISUAL_INSTALACAO.md` (5 min)
2. **Siga o guia:** `GUIA_INSTALACAO_VPS_PORTAINER_COMPLETO.md` (40-60 min)
3. **Tenha à mão:** `COMANDOS_COPIAR_COLAR.md` (para copiar comandos)
4. **Referência:** `GUIA_RAPIDO_INSTALACAO.md` (para consultas futuras)

### Para Instalação Rápida Automatizada:

```bash
# 1. Conectar na VPS
ssh root@SEU-IP

# 2. Executar script
curl -fsSL https://raw.githubusercontent.com/seu-repo/install-vps-completo.sh | bash

# 3. Seguir instruções na tela
```

---

## 📋 Checklist Geral

Antes de começar qualquer instalação:

- [ ] VPS ou servidor acessível
- [ ] Acesso SSH (Linux) ou RDP (Windows)
- [ ] Domínio registrado (opcional mas recomendado)
- [ ] Email para SSL (se usar HTTPS)
- [ ] Backup de dados existentes (se houver)
- [ ] Portas necessárias liberadas no firewall
- [ ] Requisitos mínimos atendidos:
  - [ ] 2GB RAM (mínimo) / 4GB (recomendado)
  - [ ] 20GB disco (mínimo) / 50GB (recomendado)
  - [ ] 2 CPU cores (mínimo) / 4 (recomendado)

---

## 🆘 Suporte e Troubleshooting

### Problemas Comuns:

1. **Container não inicia**
   - Ver: `GUIA_RAPIDO_INSTALACAO.md` → Seção "Solução de Problemas"
   - Comando: `docker logs nome-container`

2. **SSL não funciona**
   - Ver: `COMANDOS_COPIAR_COLAR.md` → Seção "Troubleshooting"
   - Verificar DNS: `nslookup seudominio.com`

3. **Aplicação lenta**
   - Ver: `RESUMO_VISUAL_INSTALACAO.md` → Seção "Monitoramento"
   - Comando: `docker stats`

4. **Erro de conexão com banco**
   - Ver: `GUIA_RAPIDO_INSTALACAO.md` → Seção "Comandos Úteis"
   - Comando: `docker logs inventory-db`

---

## 📞 Recursos Adicionais

### Documentação do Sistema:
- `README.md` - Visão geral do projeto
- `SISTEMA_COMPLETO.md` - Funcionalidades completas
- `TRADUCAO_RESUMO.md` - Informações sobre tradução
- `CONFIGURACOES_EMPRESA.md` - Personalização

### Documentação Técnica:
- `AGENT_INTEGRATION_GUIDE.md` - Integração com agentes
- `TEMPLATES_IMPORTACAO.md` - Importação de dados
- `PERSONALIZACAO_RODAPE.md` - Customização

### Comparações:
- `COMPARACAO_INSTALACAO.md` - Comparar métodos de instalação

---

## 🎓 Níveis de Experiência

### Iniciante
**Recomendado:**
1. `RESUMO_VISUAL_INSTALACAO.md` (entender primeiro)
2. `GUIA_INSTALACAO_VPS_PORTAINER_COMPLETO.md` (seguir passo a passo)
3. `GUIA_RAPIDO_INSTALACAO.md` (ter como referência)

### Intermediário
**Recomendado:**
1. `COMANDOS_COPIAR_COLAR.md` (instalação rápida)
2. `GUIA_RAPIDO_INSTALACAO.md` (referência)
3. `install-vps-completo.sh` (automação)

### Avançado
**Recomendado:**
1. `install-vps-completo.sh` (script automático)
2. Customizar conforme necessário
3. Integrar com CI/CD

---

## 🔄 Atualizações

Este README e os guias são atualizados regularmente. Verifique sempre a versão mais recente.

**Última atualização:** Janeiro 2025

---

## 📝 Contribuindo

Encontrou algum erro ou tem sugestões de melhoria?
- Abra uma issue
- Envie um pull request
- Entre em contato

---

## ✅ Próximos Passos Após Instalação

1. **Configurar empresa** → Sistema → Configurações
2. **Criar usuários** → Usuários → Novo Usuário
3. **Importar dados** → Templates → Download → Importar
4. **Cadastrar hardware** → Hardware → Novo
5. **Cadastrar software** → Software → Novo
6. **Gerar relatórios** → Relatórios
7. **Configurar backup** → Ver guia de backup
8. **Adicionar mais aplicações** → Via Portainer

---

## 🎉 Conclusão

Você tem todos os recursos necessários para instalar e configurar o Sistema de Inventário de TI em qualquer ambiente!

**Escolha o guia adequado ao seu cenário e comece agora!** 🚀

---

**Dúvidas?** Consulte os guias específicos ou a documentação oficial do Docker, Portainer e Nginx Proxy Manager.

**Bom trabalho!** 💪
