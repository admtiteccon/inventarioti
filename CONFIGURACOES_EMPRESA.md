# 🏢 Configurações da Empresa - Guia Completo

## ✅ Funcionalidade Implementada!

Agora você pode cadastrar os dados da sua empresa e fazer upload do logo diretamente pelo sistema!

---

## 🎯 Como Acessar

### Passo 1: Login como Administrador
```
http://127.0.0.1:5000/auth/login
```

### Passo 2: Ir para Configurações
```
Menu: Admin → Configurações da Empresa
ou
http://127.0.0.1:5000/settings/
```

---

## 📋 Dados que Você Pode Configurar

### 1. Logo da Empresa
- **Upload de imagem** (PNG, JPG, JPEG, GIF, SVG)
- **Tamanho recomendado:** 200x60px
- **Aparece em:** Navbar (menu superior) e relatórios
- **Remover logo:** Botão disponível se já houver logo

### 2. Informações da Empresa
- **Nome da Empresa** * (obrigatório)
- **Razão Social**
- **CNPJ/CPF**
- **Nome do Sistema** (aparece no navbar)

### 3. Informações de Contato
- **Email**
- **Telefone**
- **Website**

### 4. Endereço Completo
- **Logradouro**
- **Número**
- **Complemento**
- **Bairro**
- **Cidade**
- **Estado**
- **CEP**
- **País** (padrão: Brasil)

### 5. Personalização Visual
- **Cor Principal** (seletor de cor)
- **Texto do Rodapé** (texto adicional no footer)

---

## 🎨 O Que Muda no Sistema

### Navbar (Menu Superior)
**Antes:**
```
[ícone] Inventário TI
```

**Depois (com logo):**
```
[SEU LOGO] Sistema de Inventário de TI
```

### Rodapé
**Antes:**
```
© 2025 IT Inventory Management System
Version 1.0.0 | Documentation | Support
```

**Depois:**
```
© 2025 Sua Empresa LTDA
Texto personalizado do rodapé
Version 1.0.0 | Documentation | Support
```

### Relatórios (Futuro)
- Logo aparecerá no cabeçalho dos relatórios PDF
- Dados da empresa nos relatórios

---

## 📸 Exemplo de Uso

### Configuração Completa:

```
Logo: [upload de logo.png]
Cor Principal: #0d6efd (azul)

=== Informações da Empresa ===
Nome da Empresa: TechSolutions Brasil LTDA
Razão Social: TechSolutions Tecnologia LTDA
CNPJ: 12.345.678/0001-90
Nome do Sistema: Sistema de Inventário TI

=== Contato ===
Email: contato@techsolutions.com.br
Telefone: (11) 3456-7890
Website: https://www.techsolutions.com.br

=== Endereço ===
Logradouro: Avenida Paulista
Número: 1000
Complemento: Sala 501
Bairro: Bela Vista
Cidade: São Paulo
Estado: SP
CEP: 01310-100
País: Brasil

=== Personalização ===
Texto do Rodapé: Soluções em TI desde 2020
```

---

## 🔧 Funcionalidades Técnicas

### Upload de Logo
- ✅ Validação de formato (apenas imagens)
- ✅ Nome seguro do arquivo
- ✅ Timestamp para evitar conflitos
- ✅ Remove logo antigo ao fazer novo upload
- ✅ Armazenado em: `app/static/uploads/logos/`

### Banco de Dados
- ✅ Tabela: `company_settings`
- ✅ Singleton pattern (apenas 1 registro)
- ✅ Criação automática de configurações padrão
- ✅ Timestamps de criação e atualização

### Segurança
- ✅ Apenas administradores podem acessar
- ✅ CSRF protection ativo
- ✅ Validação de tipos de arquivo
- ✅ Nomes de arquivo seguros

---

## 📁 Estrutura de Arquivos

```
app/
├── models/
│   └── company.py              # Modelo de configurações
├── routes/
│   └── settings.py             # Rotas de configurações
├── templates/
│   └── settings/
│       └── company_settings.html  # Formulário
└── static/
    └── uploads/
        └── logos/              # Logos enviados
            └── logo_20251112_215500.png
```

---

## 🎯 Passo a Passo Completo

### 1. Acessar Configurações
1. Faça login como admin
2. Menu: Admin → Configurações da Empresa

### 2. Upload do Logo
1. Clique em "Escolher arquivo"
2. Selecione sua imagem (PNG, JPG, etc.)
3. Veja o preview (se já houver logo)

### 3. Preencher Dados
1. Preencha os campos desejados
2. Campos com * são obrigatórios
3. Use o seletor de cor para personalizar

### 4. Salvar
1. Clique em "Salvar Configurações"
2. Aguarde mensagem de sucesso
3. Veja as mudanças imediatamente

### 5. Verificar
1. Olhe o navbar (logo aparece)
2. Role até o rodapé (nome da empresa)
3. Navegue pelas páginas (tudo atualizado)

---

## 🔄 Atualizar Configurações

Para atualizar qualquer informação:
1. Acesse: Admin → Configurações da Empresa
2. Altere os campos desejados
3. Clique em "Salvar Configurações"
4. Pronto! Mudanças aplicadas imediatamente

---

## 🗑️ Remover Logo

Se quiser remover o logo:
1. Acesse as configurações
2. Clique em "Remover Logo" (abaixo do logo atual)
3. Confirme a remoção
4. O ícone padrão volta a aparecer

---

## 💡 Dicas

### Logo Ideal
- **Formato:** PNG com fundo transparente
- **Tamanho:** 200x60px (proporção 10:3)
- **Peso:** Menos de 500KB
- **Cores:** Contraste com fundo azul do navbar

### Preenchimento
- Preencha todos os campos para relatórios completos
- Use o endereço completo para documentos oficiais
- Mantenha contatos atualizados

### Personalização
- Escolha uma cor que combine com seu logo
- Use texto do rodapé para informações importantes
- Nome do sistema aparece no navbar

---

## 🐛 Solução de Problemas

### Logo não aparece
1. Verifique se o upload foi bem-sucedido
2. Limpe o cache do navegador (Ctrl+F5)
3. Verifique se o arquivo é uma imagem válida

### Erro ao salvar
1. Verifique se preencheu o nome da empresa (obrigatório)
2. Verifique o formato do arquivo de logo
3. Tente novamente

### Mudanças não aparecem
1. Pressione Ctrl+F5 para forçar atualização
2. Feche e abra o navegador
3. Verifique se salvou as configurações

---

## 📊 Dados Armazenados

Todas as configurações são salvas no banco de dados:
- **Tabela:** `company_settings`
- **Localização:** `dev_inventory.db`
- **Backup:** Incluído no backup do banco

---

## 🎉 Pronto para Usar!

**Acesse agora:**
```
http://127.0.0.1:5000/settings/
```

**Configure sua empresa e personalize o sistema!**

---

**Criado em:** 12/11/2025  
**Status:** ✅ Implementado e Funcionando  
**Acesso:** Apenas Administradores  
**Compatibilidade:** Todas as páginas do sistema
