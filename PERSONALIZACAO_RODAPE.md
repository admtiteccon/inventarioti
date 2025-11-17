# 🎨 Guia de Personalização do Rodapé

## ✅ Implementado!

O rodapé do sistema agora é **totalmente personalizável** através de variáveis de ambiente, sem precisar editar código!

---

## 📍 Como Personalizar

### Método 1: Arquivo .env (Recomendado)

1. **Crie um arquivo `.env`** na raiz do projeto (ou copie o `.env.example`)
2. **Adicione as variáveis** que deseja personalizar:

```bash
# Footer Customization
FOOTER_COMPANY_NAME=Minha Empresa LTDA
FOOTER_YEAR=2024
FOOTER_VERSION=1.0.0
FOOTER_DOCS_URL=https://docs.minhaempresa.com
FOOTER_SUPPORT_EMAIL=suporte@minhaempresa.com
```

3. **Reinicie o servidor** Flask para aplicar as mudanças

### Método 2: Variáveis de Ambiente do Sistema

No Windows (CMD):
```cmd
set FOOTER_COMPANY_NAME=Minha Empresa LTDA
set FOOTER_YEAR=2024
set FOOTER_VERSION=1.0.0
```

No Windows (PowerShell):
```powershell
$env:FOOTER_COMPANY_NAME="Minha Empresa LTDA"
$env:FOOTER_YEAR="2024"
$env:FOOTER_VERSION="1.0.0"
```

No Linux/Mac:
```bash
export FOOTER_COMPANY_NAME="Minha Empresa LTDA"
export FOOTER_YEAR="2024"
export FOOTER_VERSION="1.0.0"
```

### Método 3: Editar Diretamente no config.py

Se preferir valores fixos, edite o arquivo `config.py` (linha ~52):

```python
# Footer customization
FOOTER_COMPANY_NAME = 'Minha Empresa LTDA'
FOOTER_YEAR = '2024'
FOOTER_VERSION = '1.0.0'
FOOTER_DOCS_URL = 'https://docs.minhaempresa.com'
FOOTER_SUPPORT_EMAIL = 'suporte@minhaempresa.com'
```

---

## 🎯 Variáveis Disponíveis

| Variável | Descrição | Valor Padrão | Exemplo |
|----------|-----------|--------------|---------|
| `FOOTER_COMPANY_NAME` | Nome da empresa/sistema | IT Inventory Management System | Minha Empresa LTDA |
| `FOOTER_YEAR` | Ano do copyright | 2024 | 2024 |
| `FOOTER_VERSION` | Versão do sistema | 1.0.0 | 2.1.5 |
| `FOOTER_DOCS_URL` | Link para documentação | GitHub URL | https://docs.empresa.com |
| `FOOTER_SUPPORT_EMAIL` | Email de suporte | support@itinventory.com | suporte@empresa.com |

---

## 📊 Exemplos de Personalização

### Exemplo 1: Empresa Brasileira

```bash
FOOTER_COMPANY_NAME=TechSolutions Brasil LTDA
FOOTER_YEAR=2024
FOOTER_VERSION=1.0.0
FOOTER_DOCS_URL=https://docs.techsolutions.com.br
FOOTER_SUPPORT_EMAIL=suporte@techsolutions.com.br
```

**Resultado:**
```
© 2024 TechSolutions Brasil LTDA
Version 1.0.0 | Documentation | Support
```

### Exemplo 2: Departamento Interno

```bash
FOOTER_COMPANY_NAME=Departamento de TI - Empresa XYZ
FOOTER_YEAR=2024
FOOTER_VERSION=2.0.1
FOOTER_DOCS_URL=http://intranet.empresa.local/docs
FOOTER_SUPPORT_EMAIL=ti@empresa.com
```

**Resultado:**
```
© 2024 Departamento de TI - Empresa XYZ
Version 2.0.1 | Documentation | Support
```

### Exemplo 3: Minimalista

```bash
FOOTER_COMPANY_NAME=Sistema de Inventário
FOOTER_YEAR=2024
FOOTER_VERSION=1.0
FOOTER_DOCS_URL=#
FOOTER_SUPPORT_EMAIL=admin@local
```

**Resultado:**
```
© 2024 Sistema de Inventário
Version 1.0 | Documentation | Support
```

---

## 🔧 Arquivos Modificados

### 1. `config.py` (linhas ~52-57)
Adicionadas as variáveis de configuração do rodapé:
```python
# Footer customization
FOOTER_COMPANY_NAME = os.environ.get('FOOTER_COMPANY_NAME') or 'IT Inventory Management System'
FOOTER_YEAR = os.environ.get('FOOTER_YEAR') or '2024'
FOOTER_VERSION = os.environ.get('FOOTER_VERSION') or '1.0.0'
FOOTER_DOCS_URL = os.environ.get('FOOTER_DOCS_URL') or 'https://github.com/yourusername/it-inventory'
FOOTER_SUPPORT_EMAIL = os.environ.get('FOOTER_SUPPORT_EMAIL') or 'support@itinventory.com'
```

### 2. `app/templates/base.html` (linhas ~138-148)
Rodapé agora usa variáveis do config:
```html
<footer class="bg-light text-center text-muted py-3 mt-5">
    <div class="container">
        <p class="mb-1">&copy; {{ config.FOOTER_YEAR }} {{ config.FOOTER_COMPANY_NAME }}</p>
        <p class="mb-0">
            <small>
                Version {{ config.FOOTER_VERSION }} | 
                <a href="{{ config.FOOTER_DOCS_URL }}" class="text-muted" target="_blank">Documentation</a> | 
                <a href="mailto:{{ config.FOOTER_SUPPORT_EMAIL }}" class="text-muted">Support</a>
            </small>
        </p>
    </div>
</footer>
```

### 3. `.env.example` (NOVO!)
Arquivo de exemplo com todas as variáveis disponíveis.

---

## 🚀 Como Aplicar as Mudanças

### Passo 1: Criar/Editar .env
```bash
# Copie o exemplo
copy .env.example .env

# Ou crie um novo
notepad .env
```

### Passo 2: Personalizar Valores
Edite o arquivo `.env` com seus dados:
```bash
FOOTER_COMPANY_NAME=Sua Empresa Aqui
FOOTER_YEAR=2024
FOOTER_VERSION=1.0.0
FOOTER_DOCS_URL=https://seu-site.com
FOOTER_SUPPORT_EMAIL=seu-email@empresa.com
```

### Passo 3: Reiniciar o Servidor
```bash
# Pare o servidor (Ctrl+C)
# Inicie novamente
python inventario.py
```

### Passo 4: Verificar
Abra o navegador e veja o rodapé atualizado em qualquer página do sistema!

---

## 💡 Dicas

### Atualizar Ano Automaticamente
Se quiser que o ano seja sempre o atual, edite `config.py`:
```python
from datetime import datetime

FOOTER_YEAR = os.environ.get('FOOTER_YEAR') or str(datetime.now().year)
```

### Remover Links
Para remover os links de documentação ou suporte, edite `base.html`:
```html
<p class="mb-0">
    <small>Version {{ config.FOOTER_VERSION }}</small>
</p>
```

### Adicionar Mais Informações
Você pode adicionar mais linhas no rodapé:
```html
<p class="mb-1">&copy; {{ config.FOOTER_YEAR }} {{ config.FOOTER_COMPANY_NAME }}</p>
<p class="mb-0">
    <small>CNPJ: 00.000.000/0001-00 | Telefone: (11) 1234-5678</small>
</p>
<p class="mb-0">
    <small>Version {{ config.FOOTER_VERSION }}</small>
</p>
```

---

## ✅ Benefícios

- ✅ **Fácil de personalizar** - Apenas edite o arquivo .env
- ✅ **Sem tocar no código** - Não precisa editar templates
- ✅ **Reutilizável** - Mesmo rodapé em todas as páginas
- ✅ **Profissional** - Personalize com dados da sua empresa
- ✅ **Versionamento** - Atualize a versão facilmente

---

## 🎉 Pronto!

Agora você pode personalizar o rodapé do sistema de forma simples e profissional!

**Arquivo de configuração:** `.env`  
**Documentação completa:** Este arquivo  
**Suporte:** Qualquer dúvida, é só perguntar!

---

**Atualizado em:** 12/11/2025  
**Status:** ✅ Implementado e Testado  
**Compatibilidade:** Todas as páginas do sistema
